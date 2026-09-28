---
name: blender-delivery-workflow
description: Blender 镜头、简单动画和交付导出工作流。用户要求相机对准模型、产品构图、等距/三分之四镜头、转台动画、把具名对象导出为 GLB/glTF/FBX/USD，或检查导出结果时使用。基于官方 MCP，通过 scripts/blender_recipe.py 生成可审阅的有界代码；不覆盖已有 Action 或导出文件。
---

# Blender Delivery Workflow

> **运行目录**：以下命令中的 `scripts/...` 为相对路径，请在插件根目录（`kimi.plugin.json` 所在目录）下执行，或改用绝对路径；skill 目录内没有 `scripts/` 子目录。

先读取场景、精确对象名、相机、动画和输出状态，再使用确定性 Recipe；实际执行仍遵守
`blender-safe-ops`。Recipe 只生成完整 `bpy` 代码，不连接 Blender。

## 相机构图

```bash
python3 scripts/blender_recipe.py camera-shot \
  --camera Camera --target Product --location 4 -4 3 --lens 55
```

- 只操作已存在且类型为 Camera 的对象，不隐式创建或替换相机；
- 位置为显式世界坐标，镜头沿本地 `-Z` 对准目标对象原点，`Y` 为 up；
- 写后读取 Camera Transform/lens，并用相机视图或渲染检查裁切、遮挡和留白；
- “对准”不等于产品自动充满画面。目标体积差异大时先读 world bounds；用户已明确构图意图时据此计算位置并执行，只有构图目标不清时询问一次。

## 转台动画

```bash
python3 scripts/blender_recipe.py turntable \
  --object Product --axis Z --start-frame 1 --end-frame 121 --degrees 360
```

- 目标已有 Action 时拒绝执行，绝不合并或覆盖用户动画；
- 仅创建两个线性旋转关键帧，最多 3600°，不改场景 FPS 或帧范围；
- 运行后复查 Action/FCurve，并查看起始、中间、结束帧；
- 360° 的首尾视觉相同，正式循环输出时通常渲染 `start..end-1`，避免重复帧。

复杂角色绑定、NLA 混合、约束烘焙、物理缓存不属于本 Recipe；应先给计划并使用官方实时
工具或 Editor 手工路线，不能把它们塞进一次任意代码调用。

## 具名对象导出

```bash
python3 scripts/blender_recipe.py export-selection \
  --object Product --object ProductStand \
  --path "/absolute/output/product.glb"
```

- 支持 `.glb/.gltf/.fbx/.usd/.usda/.usdc`；
- 只导出逐个点名的对象，最多 64 个，不用当前 Selection 或通配符扩张范围；
- 输出父目录必须存在，目标文件必须不存在，绝不覆盖；
- 临时修改 Selection/Active Object 后会恢复；不保存 `.blend`；
- 导出成功必须同时满足文件存在且非空，再把产物重新导入空场景验证层级、材质、单位、
  朝向和动画。导出成功不代表下游引擎显示正确。

## 固定执行闭环

1. 用官方只读工具确认对象、相机、Action、帧范围和缺失文件；
2. 生成 Recipe JSON，展示 `summary`、`payload`、完整 `code` 和 `codeSha256`；
3. 用户明确的镜头、转台、导出或覆盖具名输出直接调用一次 `execute_blender_code`；只有目标或范围不清时询问一次；
4. 要求返回唯一的 `KIMI_BLENDER_RESULT=` 结构化结果；
5. 做数值复查和视觉复查；
6. 保存 `.blend`、渲染动画、覆盖旧导出文件都是新的独立决定。
