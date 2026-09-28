---
name: testing-platform-parallel-work
description: testing-platform 工作树曾并行承载题库代码（2026-09-22 已全部提交推送至 main）；保留「按明确路径暂存、git status 先行」的约定
metadata:
  node_type: memory
  type: project
  originSessionId: sess_54bc33e8-126e-4097-b8c9-26e25a4ba906
---

历史情况（已解决）：2026-09-21 该工作树并行存在另一会话的题库代码与网关重构改动。2026-09-22 题库模块已由本会话按明确路径暂存提交（08c141e "Build question-bank module into the data center"）并推送 main，GitHub Pages 部署成功（含四轮全部功能：双视角页签、修正建议回流、冻结记录、授权过滤等）。工作树当前干净。

**Why:** 并行开发期间曾因此出现非任务文件的 tsc/vitest 失败与 locale 文件被合并历史覆盖的现象；按路径暂存避免了误提交他人改动。

**How to apply:** 约定继续有效——在本工作区永远不 `git add -A` / `git commit -a`，提交前先 `git status --short` 核对归属；对非任务文件的测试失败先怀疑并行改动或既有问题（可用 git stash 基线复跑验证），而非回归。

Related: [[testing-platform-gateway-refactor]], [[question-bank-module-prd]]
