---
name: blender-production-recipes
description: 使用 Blender 官方 MCP 完成确定性的本地模型导入接管、已有对象移动/旋转/缩放、具名对象网格阵列或复制、对象级材质覆盖、PBR 材质、已有贴图节点替换和本地 HDRI 世界环境。用户要求导入 GLB/FBX/OBJ/USD、统一比例并落地、挪动/批量摆放、换材质或贴图、设置 HDR/EXR 环境时使用；通过 scripts/blender_recipe.py 生成可审阅代码，不依赖 Sid 的第二套 MCP Server。
---

# Blender Production Recipes

> **运行目录**：以下命令中的 `scripts/...` 为相对路径，请在插件根目录（`kimi.plugin.json` 所在目录）下执行，或改用绝对路径；skill 目录内没有 `scripts/` 子目录。

用 `scripts/blender_recipe.py` 把高频生产操作编译成有界 `bpy` 程序，再通过 Blender Lab
官方 `execute_blender_code` 执行。脚本本身只生成计划和代码，不连接 Blender、不修改文件。

## 精简流程

1. 先运行 `python3 scripts/blender_recipe.py catalog` 选择 Recipe。
2. 用官方只读工具确认精确对象名、材质名和场景现状。
3. 运行对应命令生成 JSON 计划；检查 `payload`、`summary`、`risk` 和 `codeSha256`。
4. 写操作按 `blender-safe-ops` 说明代码摘要、目标和副作用；用户明确的具名、有限普通写入不再额外确认。
5. 只调用一次 `execute_blender_code(code=<原样代码>)`，不要改写或拼接生成结果。
6. 从 `stdout` 解析唯一一行 `KIMI_BLENDER_RESULT=<json>`；缺少该行就视为未证实。
7. 按计划里的 `verification` 做结构化读取和视觉复查；用户明确要求保存或覆盖具名文件时直接执行，只有目标不清或需要扩大范围时询问一次。

## 能力

### 深度检查

```bash
python3 scripts/blender_recipe.py inspect-object --object Chair
```

补充官方对象摘要：读取 world-space AABB、Transform、父子关系、Collection、Modifiers、
材质槽和 Mesh 统计。虽然代码只读，`execute_blender_code` 仍需展示代码。

### 移动、旋转、缩放现有对象

```bash
python3 scripts/blender_recipe.py transform \
  --object Chair --location 2 0 0 --rotation-deg 0 0 90 --scale 1 1 1
```

只修改精确对象；未提供的 Transform 分量保持不变。写后重新运行 `inspect-object`，不要把
“代码没有报错”当作位置正确。

### 显式网格阵列

```bash
python3 scripts/blender_recipe.py grid \
  --object Chair_A --object Chair_B --object Chair_C \
  --columns 2 --spacing-x 1.5 --spacing-y 1.5 --origin 0 0 0 --ground-z 0
```

对象必须逐个具名，最多 64 个；不接受通配符或“场景全部对象”。`--ground-z` 使用每个
Mesh 的世界 AABB 最低点落地，不做碰撞求解。

若用户只有一个源对象并要求复用，使用：

```bash
python3 scripts/blender_recipe.py duplicate-grid \
  --source Chair --prefix ChairCopy --count 12 --columns 4 \
  --spacing-x 1.5 --spacing-y 1.5 --origin 0 0 0 --ground-z 0 --linked-data
```

`--linked-data` 让副本共享 Mesh Data，适合复用静态道具；不加时为每个副本复制独立
Mesh Data。只复制源 Mesh 对象本身，不递归复制其子层级，最多 64 个，并在写前拒绝任何
计划名称冲突。

### 本地模型导入后接管

```bash
python3 scripts/blender_recipe.py import-takeover \
  --path "/absolute/path/chair.glb" \
  --collection KIMI_Imports --target-max-dim 1.2 --x 0 --y 0 --ground-z 0
```

支持 `.glb/.gltf/.fbx/.obj/.usd/.usda/.usdc/.abc`。只接管导入前后对象身份差集，保留
内部层级，在新 Empty 容器上统一缩放；按组合 Mesh 的 world AABB 居中和落地。导入器
不可用、没有 Mesh、容器重名或零尺寸时停止，不扩大到旧对象。

### 对象级材质覆盖

```bash
python3 scripts/blender_recipe.py assign-material \
  --object Chair --material MI_Chair --slot 0
```

把目标 slot 切换为 `OBJECT` link，避免改变共享 Mesh Data 上其他实例的材质。

### 从本地贴图创建 PBR 材质

```bash
python3 scripts/blender_recipe.py pbr-material \
  --object Chair --material KIMI_Chair_Wood --slot 0 \
  --base-color "/absolute/path/wood_basecolor.png" \
  --roughness "/absolute/path/wood_roughness.png" \
  --normal "/absolute/path/wood_normal.png"
```

- Base Color 使用 sRGB；Roughness、Metallic、Normal、AO、Height、ARM 使用 Non-Color。
- 支持 ARM 打包贴图，并按 Blender 4+ 的 `Separate Color` API 分支处理。
- 材质名已存在时拒绝覆盖；新材质以对象级 slot 覆盖绑定。
- 贴图只从用户给出的本地绝对路径加载；Recipe 不下载、打包或保存外部文件。

### 替换已有材质中的贴图节点

```bash
python3 scripts/blender_recipe.py replace-image-texture \
  --material Wood --node "Base Color" \
  --path "/absolute/path/new_wood.png" --colorspace sRGB
```

材质和 Image Texture 节点必须精确具名；目标不是 `ShaderNodeTexImage` 时停止。该操作会
影响该材质的全部 users，计划结果会报告 `materialUsers`。Mask/Normal 等数据图明确使用
`--colorspace Non-Color`。

### 从本地 HDRI 创建世界环境

```bash
python3 scripts/blender_recipe.py hdri-world \
  --path "/absolute/path/studio.exr" --world KIMI_Studio \
  --strength 0.8 --rotation-deg 45
```

只接受 `.hdr/.exr`，创建新的 World 节点树并绑定当前 Scene；同名 World 存在时拒绝
覆盖。HDRI 必须是用户提供的本地绝对路径；本插件不搜索或下载远端 HDRI。

### 相机、转台与交付导出

相机对准、简单转台关键帧和具名对象 GLB/glTF/FBX/USD 导出由
`blender-delivery-workflow` 负责；仍使用本脚本的 `camera-shot`、`turntable` 和
`export-selection` Recipe。它们分别拒绝错误相机类型、已有 Action 和已存在的输出文件。

## 实现边界

迁移 world AABB、导入差集、组合层级缩放、生成后落地、PBR 通道语义和前后视觉复查。
不安装第二套 socket server，不复制任意 Python 通道，也不在 Blender 代码里联网。
资产输入只接受用户提供的本地文件；本插件不搜索、生成或下载远端资产。

## 失败边界

- `codeSha256` 变化意味着代码被改写；重新检查摘要和目标。若仍在用户明确授权范围内直接执行；只有范围扩大或出现未明确的外部副作用时询问一次。
- 运行中断或 MCP 断线时先只读复查，不盲目重试写操作。
- AABB 落地不等于物理稳定、法线正确或没有穿插；视觉与结构化复查缺一不可。
- Recipe 不保存 `.blend`、不删除旧对象、不联网、不调用 Shell。
