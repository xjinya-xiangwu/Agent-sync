---
name: blender-asset-workflow
description: Blender 本地资产的“导入后接管”工作流。用户要求导入本地模型、贴图或 HDRI，接管刚导入的对象，统一比例、落地、检查穿插或丢失贴图时使用。基于 Blender Lab 官方 MCP，只处理用户提供的本地文件。
---

# Blender Asset Workflow — 本地导入后接管

> **运行目录**：以下命令中的 `scripts/...` 为相对路径，请在插件根目录（`kimi.plugin.json` 所在目录）下执行，或改用绝对路径；skill 目录内没有 `scripts/` 子目录。

这是 Blender Lab 官方 MCP 上的本地资产工作流，不是第二套 MCP server。
插件不提供远端资产搜索、生成或下载能力，也不接收第三方服务凭据。

## 1. 输入边界

只处理用户明确提供的本地文件绝对路径：

- 模型：`.glb/.gltf/.fbx/.obj/.usd/.usda/.usdc/.abc`；
- 图片与贴图：`.png/.jpg/.jpeg/.tif/.tiff/.exr/.hdr/.webp`；
- `.blend` 文件需要先说明 Link 还是 Append。

路径不存在、不是普通文件、格式不支持或用户没有指定目标文件时停止，不自行搜索替代素材，
也不在 Blender Python 代码中发起网络请求。

## 2. 导入前快照

先用实时只读工具记录：

- `get_objects_summary` 的对象名称、类型和数量；
- 当前活动对象、模式、集合和场景单位；
- `get_blendfile_summary_missing_files` 的缺失外部文件；
- 一张可用的视图预览。官方 v1.0.0 的 image screenshot 若返回 JSON 错误，
  改用 `render_viewport_to_path`，不要把工具故障误判为场景故障。

这份 before-state 用于精确识别新对象，不能用“场景里看起来最新”猜测范围。

## 3. 有界导入

用户给出绝对路径和目标 collection 后，先列计划，再进入 `blender-safe-ops`。

对于 `.glb/.gltf/.fbx/.obj/.usd/.usda/.usdc/.abc`，优先加载
`blender-production-recipes` 并运行 `scripts/blender_recipe.py import-takeover`。它会在官方
`execute_blender_code` 上执行对象身份差集、共同 Empty 容器、组合 world AABB、统一比例、
XY 居中和 Z 落地；不要重复手写同一套导入代码。

- `.blend`：说明 Link 还是 Append；
- `.glb/.gltf`、`.fbx`、`.obj`：说明对应 import operator；
- 图片/HDRI：说明是导入为 Image、材质纹理还是 World Environment；
- 不覆盖同名 datablock，预先给出命名策略。

官方 server 没有相应结构化 import 工具时，可用 `execute_blender_code`，向用户说明代码摘要、
目标和副作用即可；不粘贴完整 bpy 代码或重复确认已明确的普通导入。代码只读取已校验的本地路径。

本地 PBR 贴图绑定优先使用 `blender-production-recipes` 的 `pbr-material`；已有材质的单对象
覆盖使用 `assign-material`。二者都设置对象级材质槽，避免无意修改共享 Mesh Data。

## 4. 只接管差集

导入后重新读对象清单，以 `after object names - before object names` 得到新对象集合。
如果导入器复用了旧对象名、重载了整个文件或差集为空，停止并让用户指定对象/集合；
不要扩大到全场景。

对每个新 Mesh 计算 world-space AABB（8 个 `bound_box` 角乘
`matrix_world`），记录：

- min/max、dimensions、中心、最低 Z；
- object scale、rotation、parent、collection；
- 共享 mesh/material datablock；
- 缺失文件、贴图色彩空间和材质槽。

## 5. 比例、落地与空间关系

用户已给目标真实尺寸时直接按“最大边目标长度 / 当前最大边”计算统一缩放；未给尺寸且无法从任务语义可靠推断时询问一次，不根据物体名字猜尺寸。多对象资产优先移动共同父对象或临时根节点，避免破坏内部关系。

落地以 world AABB 的最低 Z 对齐目标地面 Z；这只是几何包围盒对齐，不等于碰撞、
布料或刚体求解。随后检查：

- 应分离的对象 AABB 是否相交；
- 接触对象是否有明显悬空；
- 相机 near/far clip 与资产尺度是否合理；
- 旋转、原点和法线是否符合后续编辑需要。

任何 transform 写入先记录 before/after 数值；用户明确的具名、有限变换直接执行，只有范围不清或需要扩大范围时询问一次。

## 6. 双重验收

1. 数值复查：重新读取新对象、AABB、transform、材质槽和 missing files；
2. 视觉复查：从能覆盖资产与邻近环境的角度渲染预览；
3. 输出接管回执：本地导入文件、创建对象、最终尺寸、移动/缩放和未验证项；
4. 保存 `.blend` 是独立高影响步骤，用户没有明确要求就保持 Dirty，不自动保存。

导入差集、层级 world bounds、归一化/落地、PBR 通道约定和视觉验证的工作流思想参考
AhujaSid/blender-mcp；运行时只使用 Blender Lab 官方 MCP 与本插件的本地 Recipe。
