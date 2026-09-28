---
name: new-provider-relay-mimo
description: Boyue 中转(new-provider) 配置位置与 mimo-v2.6-pro max_tokens 上限 131072 的坑
metadata:
  node_type: memory
  type: reference
  originSessionId: sess_6bb64fde-b0c4-4dec-bf90-b5ed51030c1e
---

ZCode 自定义供应商 `new-provider`（显示名 "Boyue"，new-api 类中转，baseURL `http://35.220.164.252:3888`）配置在 `~/.zcode/v2/provider_config.json`，`api.type=anthropic-messages`（/v1/messages 对该中转完全可用，无需切 OpenAI 模式）。模型：glm-5.3 / glm-5.3-flash / mimo-v2.6-pro。

2026-09-23 诊断：mimo-v2.6-pro 真实对话 400 "Param Incorrect" 而连通性测试成功 —— 根因是模型配置里 `optionSpecs.maxOutputTokens.max=320000` 超过上游硬上限；二分实测 max_tokens>131072 一律 400，≤131072 正常。修复 = 把该模型"最大输出 tokens"降到 ≤131072。连通性测试只发小 max_tokens 的最小请求，暴露不了这类参数问题。

另见：切换会话模型时日志报 `session.model_selection.persist_failed / FOREIGN KEY constraint failed`（本地会话库外键问题，独立小 bug）。
