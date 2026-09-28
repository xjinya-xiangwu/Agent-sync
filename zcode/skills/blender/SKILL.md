---
name: blender
description: Blender 插件标准总入口。当用户提到 Blender、3D 建模、资产、材质、动画、渲染、导出、安装或连接问题时使用；先加载 blender-bridge，再按任务路由到对应工作流。
---

# Blender

这是插件的规范化主入口，不重复领域操作细节。

1. 先读取 `../blender-bridge/SKILL.md`；原生工具面已就绪时直接进入任务，仅在首次使用或连接异常时检查环境。
2. 按 `blender-bridge` 的路由加载最窄的领域 Skill。
3. 用户明确的具名、有限写入、删除和覆盖直接执行；只有目标不清或需要扩大范围时询问一次，批次结束后复查。未知进程不强制关闭。
