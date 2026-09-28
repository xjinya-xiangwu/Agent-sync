---
name: blender-bridge
description: Blender 统一入口路由。当用户提到 Blender、3D 建模、场景(Scene)、材质、渲染、Blender 报错时使用，按意图路由到对应子 skill；只在首次使用、工具面缺失或连接失败时检查环境。“怎么用/怎么装/第一次用”类问题路由到 blender-setup-guide。
---

# Blender Bridge — 统一入口与路由

> **运行目录**：以下命令中的 `scripts/...` 为相对路径，请在插件根目录（`kimi.plugin.json` 所在目录）下执行，或改用绝对路径；skill 目录内没有 `scripts/` 子目录。

单通道插件：官方 MCP（Blender Lab `blender-mcp`，stdio）→ 官方插件（Blender 进程内，9876 端口）→ bpy。官方 server 自带 `_for_cli` 后台执行工具，批处理无需第二通道。

## 通道说明

1. **优先使用 Kimi 原生 MCP 工具**：插件安装后，工具名形如 `mcp__plugin-blender_blender__get_*` / `execute_blender_code` 的原生工具直接可用。
2. 原生工具不可用时，先跑 `python3 scripts/blender_health.py --json` 定位断在哪一层，不要硬闯。
3. 官方 server 由 `scripts/blender_mcp_launcher.py` 以固定版本 tag 拉起；不要手动 `uvx` 起第二个实例。

## 连接检查

```bash
python3 scripts/blender_health.py --skip-mcp --json
```

仅在首次使用、宿主工具面缺失、连接失败或状态发生变化时执行；如果原生 MCP 已在工具快照中且第一次只读调用成功，直接进入任务，不重复 preflight。

检查内容仍包括：Blender 5.1+、官方插件、9876 端口和原生工具面。

任何一层不满足 → 路由 `blender-setup-guide`，不把报错甩给用户。

## 意图路由

| 用户意图 | 去哪个 skill |
|---|---|
| 怎么装/怎么用/第一次用/连不上 | blender-setup-guide |
| 全面检查 / 诊断哪层断了 | blender-health-check |
| 看场景里有什么 / 对象详情 / 截图 | 直接用官方只读工具（get_objects_summary / get_object_detail_summary / get_screenshot_of_*） |
| 创建/修改/删除对象、材质、灯光、相机、渲染设置 | blender-safe-ops（明确请求直接执行；批后一次复查） |
| 精确移动/旋转/缩放已有对象、具名对象网格阵列或复制 | blender-production-recipes → blender-safe-ops |
| 从本地模型导入并统一比例/居中/落地 | blender-production-recipes 的 import-takeover → blender-safe-ops |
| 给单个对象换材质、创建 PBR、替换贴图节点、设置本地 HDRI | blender-production-recipes → blender-safe-ops |
| 搭一个 XX 场景 / 打个影棚光 / 批量改名 | blender-scene-playbook 出守则 → blender-safe-ops 执行 |
| 导入本地模型/贴图/HDRI、接管刚导入资产 | blender-asset-workflow → blender-safe-ops 执行 |
| 相机对准/产品镜头、转台动画、GLB/FBX/USD 导出 | blender-delivery-workflow → blender-safe-ops 执行 |
| 分析场景性能 / 解释几何节点 / 文档查询 | 直接用官方工具（get_blendfile_summary_* / get_python_api_docs） |

## 执行原则

- 用户明确请求本身就是授权：具名、有限的创建、修改、删除、覆盖、保存和导出直接执行，不再等待“确认/可以/执行”
- 连续同类操作尽量批处理；完成后做一次结构化复查和必要的视觉复查
- 原生 MCP 工具面已就绪时不先跑 Bash health，也不把诊断脚本冒充原生 MCP
- 写操作仍按 Blender/Game Thread 能力串行执行，失败保留原始错误，不盲目重试
- 不凭记忆猜工具名和参数；同一会话首次成功发现后复用工具/schema，只有工具错误、列表变化或进入新领域时重新发现
- `execute_blender_code` 只向用户说明代码摘要、目标对象和副作用；不粘贴完整代码或逐调用确认
- 高频导入/变换/材质任务优先用 `scripts/blender_recipe.py` 生成有界代码，不临场拼接无界 bpy
- 只有目标/路径/数量不清或需要扩大范围时询问一次；未知进程不强制关闭
- 失败时保留原始错误输出，不伪造成功
- Blender 版本 < 5.1：不硬闯，引导升级
