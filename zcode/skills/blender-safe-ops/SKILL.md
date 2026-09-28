---
name: blender-safe-ops
description: 安全地修改 Blender 场景：用户明确要求的具名、有限创建、修改、删除、覆盖、保存和导出直接执行并在批次结束后复查；仅在目标不清或扩大范围时询问一次。
---

# Blender Safe Ops — 写操作安全流程

官方安全警告：MCP 会在 Blender 中执行 LLM 生成的代码，**没有任何护栏**。本技能就是护栏。

## 精简执行合同

1. **读上下文**：用只读工具核对目标对象、材质、场景状态和范围；用户明确请求本身就是授权，包括具名、有限的删除、覆盖、保存和导出。
2. **执行**：按实时 schema 进行串行或有界批量调用；不复述计划或索取确认。只有目标/路径/数量不清或需要扩大范围时询问一次。失败即停并保留原始错误。
3. **复查与预览**：整个逻辑批次完成后做一次结构化复查。视觉任务选择主要变更对象，用 `jump_to_view3d_object_by_name` 或等价实时工具在 Blender 内聚焦，再用 `render_viewport_to_path` 或相机渲染生成一次更新预览；不在每个微调用后截图，也不使用 OS 盲按强抢前台。

## 实测契约（2026-08-14，官方 server v1.0.0 + Blender 5.2 本机实测）

- **`get_screenshot_of_*_as_image` 当前不可用**：返回 "Unterminated string" JSON 解析错误（官方 server 端 bug，v1.0.0 实测）。截图/复查改用：
  - `render_viewport_to_path(output_path)`：视口渲染写文件。**插件沙箱会把输出重定向到临时目录**（返回的 `filepath` 形如 `…/T/blender_xxx/blender_mcp/名字.png`），用返回值里的实际路径读图
  - 要完全可控的画面：`execute_blender_code` 摆相机 + `bpy.ops.render.render(write_still=True)`（写真实路径，不重定向）
- `jump_to_view3d_object_by_name` 参数名是 `name`（不是 object_name）
- `execute_blender_code` 返回里 `result` 常为空，`print` 输出在 `stdout` 字段——成功判定看 stdout
- 视口取景代码（view3d.view_selected）不影响 `render_viewport_to_path` 的画面（它用自己的视口状态）；想控制构图就走相机渲染
- 材质节点按 `type == "BSDF_PRINCIPLED"` 查找，不要按名字 "Principled BSDF"（多语言 UI 下名字会变）

### Blender 5.2 API 契约（2026-08-14 特效五连发实测）

- **渲染引擎枚举是 `BLENDER_EEVEE`**，不是 `BLENDER_EEVEE_NEXT`（枚举只有 `BLENDER_EEVEE / BLENDER_WORKBENCH / CYCLES`）。赋错值抛 TypeError——别用 try/except 静默吞，之前因此一直用默认引擎而不知情
- `image_settings.file_format` 已移除 `FFMPEG`（5.x 视频输出重构）：动画输出走 PNG 序列；本插件不负责视频合成
- `action.fcurves` 已移除（5.x 分层动作）：别碰 fcurves，关键帧默认贝塞尔插值即可
- **刚体模拟必须逐帧驱动**：`frame_set(70)` 若当前已在 70 帧是**空操作**，模拟不会跑。正确姿势：`frame_set(1)` 后 `for f in range(2, N+1): frame_set(f)`。地面/台面必须都有 PASSIVE 刚体，否则 ACTIVE 体穿透后无限下坠（z 变负）
- **几何节点实例在 evaluated mesh 里数不出顶点**：`ev.data.vertices == 0` 不代表 GN 失效（实例未实现化）；验证用 `ev.to_mesh()` 计数，或在组内加 `GeometryNodeRealizeInstances`
- GN `GeometryNodeObjectInfo` 源物体：`hide_render=True` 不影响实例化；`hide_viewport=True` 会。密度参数按平面面积换算（density ≈ 目标数量 / 面积 m²），直接给小数会得到 0 个点
- **流体便捷操作符已移除**：`bpy.ops.fluid.domain_add / flow_add` 在 5.2 不存在（AttributeError）。Mantaflow 本体还在：手工 `modifiers.new("Fluid", "FLUID")` → `fluid_type = "DOMAIN"/"FLOW"`，domain 设 `resolution_max / cache_frame_start/end / cache_type="MODULAR"`，`bpy.ops.fluid.bake_data()` 可烘焙
- **烘焙烟雾 EEVEE 和 Cycles 都能渲染**（2026-08-14 复核，推翻早前"EEVEE 拾取不到"的错误结论）：标准材质链 `ShaderNodeAttribute("density") → Math(×5-10) → Principled Volume.Density`。若 bake 后什么都渲不出来，先怀疑 **grid 是空的**（假烘焙）而不是引擎：`bake_data()` 秒回（<3s）+ 缓存目录只有 config 文件 = 发射器没生效，重建 domain/emitter（发射器抬高、远离遮挡物）重 bake 即可。参考耗时：res 48×48 帧 ≈ 2s，res 96×72 帧 ≈ 17s（本机），均为真烘焙
- **真粒子系统在 5.2 可用**：`bpy.ops.object.particle_system_add()` + `settings.render_type="OBJECT"` + `instance_object`（实例对象放远处并 hide_render/hide_viewport 隐藏本体）。粒子随帧求值，跳转帧前同样需要逐帧驱动
- 蓬松烟雾的替代（免烘焙、任何引擎稳渲）：UV 球 + Principled Volume（Noise→ColorRamp→Density），EEVEE/Cycles 都稳定
- **Cycles 远距 AREA 灯能量要够大**：照 130m 外的发射台需要 ~2×10⁵ W 量级（平方反比），几千 W 几乎不可见；夜景场地灯 ~2×10⁴ W 即可，6×10⁴ 会把地面打过曝
- Cycles 48-64 采样 + 降噪、max_bounces=4、960×540/600：本机 CPU 单张 1-3 分钟可完成（含体积雾/体积球）

## execute_blender_code（高权限）

- 调用前向用户说明代码摘要、精确对象/资产范围和副作用；不要求粘贴完整 bpy 代码或再次确认已经明确的普通范围
- 优先用官方结构化工具（summary/screenshot/render/jump_to_*）；能用结构化工具就不用裸代码
- 代码里出现 `bpy.ops.object.delete`、批量循环修改、`bpy.data.*.remove`：内部核对其目标没有超出用户明确范围；范围明确时直接执行
- `urllib`、`requests` 等网络 API 始终禁止；本地保存/导出只使用用户明确的路径或插件生成的不覆盖临时路径

## 其他约束

- 用户未指定渲染输出时使用不覆盖已有文件的临时/时间戳路径和合理预览分辨率；用户明确要求覆盖具名输出时直接执行，只有目标路径不清时询问一次
- 复杂操作使用有界批次或 Recipe；不要按步骤拆成多轮确认
- Blender 正忙（渲染中/模态操作）时暂停调用，等恢复
- 操作失败且场景可能处于中间态：如实告知用户，建议 Ctrl+Z 撤销，不擅自连环补救
- MCP 断连：停止写操作，转 blender-health-check；不得重试轰炸
