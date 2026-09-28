---
name: blender-scene-playbook
description: 自然语言 → Blender 场景操作守则。当用户说「搭一个 XX 场景」「做个低多边形小岛」「打个影棚光」「批量改个名」「给这个模型上材质」等搭建类需求时使用。负责注入 Blender 心智模型（右手系 Z-up）并把模糊需求翻译成编号守则；执行走 blender-safe-ops 的精简执行合同。
---

# Blender Scene Playbook — 自然语言 → 场景操作守则

## 职责与边界

- **只做翻译，不做执行**：把模糊需求转成编号守则，交给 blender-safe-ops 的精简执行合同执行
- 拿不准 API 时用官方 `get_python_api_docs` 查询（文档内置在官方 server 里），不凭记忆编造 bpy 调用
- 守则中的代码块最终都经 execute_blender_code 执行；向用户说明摘要和范围，不要求粘贴完整代码或重复确认明确的普通任务

## Blender 心智模型（翻译时必须遵守）

### 坐标系——和 Unity/UE 相反，最易错

- **右手系，Z-up**：+X 右、+Y 里（远离观察者）、**+Z 向上**。地面是 XY 平面（z=0）
- 旋转用弧度制（`math.radians` 转换）；相机/灯光朝向用 `Track To` 约束或手动计算欧拉角
- 单位默认米；人高 ≈1.8、门高 ≈2

### 对象与数据

- Object（场景中的实例）与 Data（网格/材质等数据块）分离；同一 Data 可被多 Object 共享——改 Data 影响全部实例
- 创建图元用 `bpy.ops.mesh.primitive_*_add(location=(x, y, z))`；**z 是高度**
- 命名规范：守则产物统一前缀 `BP_`，方便整体选中、撤销、清理

### 材质

- 节点材质：`mat.use_nodes = True` 后按
  `next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")` 定位节点；禁止
  按英文显示名索引或 `.get()` 节点，因为显示名会随 UI 语言变化。
  Socket 优先按稳定 `identifier`（Base Color / Metallic / Roughness）查找，不依赖节点显示名。
- 赋材质：`obj.data.materials.append(mat)`；确认对象有 data（空物体没有）

### 灯光与相机

- 三灯套路：主光（Area，大柔光）+ 补光（Area，弱）+ 轮廓光（Spot/Area 从后方）
- 影棚感：世界背景调暗灰 + 大 Area 灯自上而下
- 相机对准目标的标准做法：`Track To` 约束指向空物体

### 复查闭环

- 每个守则收尾：只读枚举新建对象 + 可用的视觉工具给用户看效果。官方 v1.0.0 的
  `get_screenshot_of_*_as_image` 若返回 JSON 解析错误，改用
  `render_viewport_to_path`，不要重复轰炸同一故障工具
- 视觉不对优先调参重截，不连环大改

## 守则格式

```text
PB-<编号> <名称>
目标：<一句话说清最终画面>
步骤：
[1] <意图> → bpy 代码草案 → 预期结果
[2] ...
收尾复查：
- get_objects_summary 确认对象清单
- 选择/聚焦主要变更对象后由 agent 获取一次更新预览并复查（v1.0.0 image screenshot 失败时用 render_viewport_to_path），不等待用户确认
```

编写规则：每守则 5–10 步；全部给具体数值；统一 `BP_` 前缀；删除步骤单独标注。

## 内置守则模板（数值是起点，用户可改）

### PB-01 基础场景（地平面 + 光 + 相机）

- [1] 清空默认场景可选：用户明确要求清空/重建时直接删除默认 Cube，并保留或重建 Camera/Light；未说明是否保留现有对象时先询问一次
- [2] 地面：`primitive_plane_add(size=20, location=(0,0,0))`，命名 `BP_Ground`
- [3] 主光：`primitive_...` 不用 ops——灯光用 `bpy.data.lights.new("BP_Key", 'AREA')`，energy=1000，挂到对象于 (4,-4,6)
- [4] 相机：对准原点（Track To 指向 `BP_Focus` 空物体），位置 (8,-8,5)
- [5] 复查：截图

### PB-02 低多边形场景（小岛/小品）

- [1] 执行 PB-01 打底
- [2] 岛体：`primitive_ico_sphere_add(subdivisions=2)` 压扁（scale z≈0.4），`BP_Island`
- [3] 植被：3–6 个 `primitive_cone_add`（绿材质），错落放置，z 落在岛面上
- [4] 水：大平面 + 蓝色 Principled（roughness≈0.1），z 略低于岛面
- [5] 材质全部用纯色低饱和；收尾截图

### PB-03 影棚打光

- [1] 确认被摄对象（选中项或指定名）
- [2] 世界：Background strength 0.1
- [3] 三灯：Key Area(1000, 前侧 45°) / Fill Area(400, 另一侧) / Rim Area(800, 后方高角度)
- [4] 相机对准对象中心（Track To）
- [5] `render_viewport_to_path` 出预览图（路径带时间戳，不覆盖已有文件）

### PB-04 批量数据块改名

- [1] 只读列出将全部改名的对象清单（数量 + 前后对照表）；用户明确要求该批次时直接执行，数量或范围不清、需要超出原请求时询问一次
- [2] 生成 rename 映射（如加前缀/修拼写），逐条 `obj.name = ...`
- [3] 复查：重新枚举，对照表逐项确认

## 与其他技能的分工

| 阶段 | 技能 |
|---|---|
| 需求 → 守则 | blender-scene-playbook（本技能） |
| 守则 → 执行 → 复查（明确请求直接执行） | blender-safe-ops |
| API 拿不准 | 官方 get_python_api_docs |
| 通道不通 | blender-health-check / blender-setup-guide |
