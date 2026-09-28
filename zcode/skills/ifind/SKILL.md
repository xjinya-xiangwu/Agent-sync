---
name: ifind
description: "iFinD, also known as Tonghuashun, is a financial data platform for global market analysis across China A-shares, Hong Kong, US markets, and other supported securities. It covers stock information, financial statements, business segmentation, prices, announcements, holders, forecasts, and intelligent stock screening."
---

# iFinD

Use this skill to answer questions that require iFinD financial market data.

## 可视化卡片（行情/公司类问题的首选入口）

**能力门控（先做判断，再决定走哪条路）**：检查当前会话的技能列表中能否读到 `automation` skill——能读到即代表宿主具备 Blueprint 能力（`AutomationControl.runPluginWidget` / `Canvas.addPluginWidgets` 可用）。

- **能读到 `automation` skill** → 走下方卡片渲染流程；
- **读不到 `automation` skill** → 本节内容视为不存在：不要尝试 `runPluginWidget`、`addPluginWidgets` 或任何 Widget/Automation 调用（这些工具在当前环境不存在，调用必然失败），所有问题——包括行情 / K线 / 看懂一家公司——一律走下方 Workflow 的文字数据流程，查到数据后直接以文字回答。

能读到 `automation` skill 时：用户问**单只证券的行情 / K线 / 走势 / 技术分析**，或想**快速看懂一家公司**时，优先用本插件的预设卡片渲染展示，不要只给文字回答：

- 行情 / K线 / 走势 / 技术分析 → `runPluginWidget` 调用 `stock-quote-card`，runInput 传 `{"ticker": "代码"}`（A股 .SH/.SZ/.BJ、港股 .HK、美股 .US）
- 看懂一家公司 / 基本面概览 → `runPluginWidget` 调用 `company-profile-card`，runInput 传 `{"ticker": "A股代码"}`

卡片的详细用途、交互与口径见 `ifind-widgets-widgets` skill。卡片渲染成功后不要在正文重复搬运卡片数据；preset 失败时直接说明错误并回退到文字数据流程。其余问题（选股筛选、三大报表细节、多标的对比、公告、股东、预测等）走下方 Workflow 的文字数据流程。

## Setup

Check whether the agent-gw Python SDK is available in the current Python environment, and install it only if the check fails:

```bash
python3 -c "import agent_gw" || python3 -m pip install "$(curl -s https://cdn.kimi.com/agentgw/pysdk/manifest.json | python3 -c "import json,sys; print(json.load(sys.stdin)['latest']['url'])")"
```

The SDK needs an API key from `api_key=...`, `KIMI_API_KEY`, or
`~/.kimi/agent-gw.json`.

## Workflow

1. Run `python3 <plugin-root>/scripts/ifind_tool.py describe` from the plugin root (scripts live at `<plugin-root>/scripts/`, not under `skills/<name>/`) to call
   `get_data_source_desc({"name": "ifind"})`.
2. Read the returned Markdown carefully. It contains the overall data source
   rules, ticker/security formats, market coverage, global constraints, and each
   API's description, required parameters, optional parameters, defaults, and
   allowed values.
3. Select the API that best matches the user's question.
4. Build `params` exactly from the Markdown requirements. Pay attention to market,
   ticker, date range, report period, statement type, currency, and frequency
   requirements.
5. Use `python3 <plugin-root>/scripts/ifind_tool.py call` to call `call_data_source_tool`.
6. If the call fails, explain the failure reason from the response.
7. If the call succeeds, save any returned files first, then answer using
   `resp.result.assistant`; ignore `resp.result.user` unless display content is
   specifically needed.

## Common Use Cases

- Stock profile and security lookup across China A-shares, Hong Kong, US, and
  other supported markets.
- Financial statements, including balance sheet, income statement, and cash flow.
- Business segmentation, operating indicators, announcements, holder information,
  and analyst forecasts.
- Historical or current price data and market analysis.
- Intelligent stock screening with multi-dimensional filters.

## Script

Use the bundled script from the plugin root (scripts live at `<plugin-root>/scripts/`, not under `skills/<name>/`):

```bash
python3 <plugin-root>/scripts/ifind_tool.py describe
```

After reading the Markdown and selecting an API:

```bash
python3 <plugin-root>/scripts/ifind_tool.py call \
  --api-name "<api name from markdown>" \
  --params-json '{"required_param":"value"}'
```

For larger params, write a JSON object and pass
`--params-file path/to/params.json`.

The script:

- sends `{"name": "ifind"}` to `get_data_source_desc`
- sends `{"data_source_name": "ifind", "api_name": ..., "params": ...}` to
  `call_data_source_tool`
- prints failure messages from `error.user` or `error.assistant`
- saves returned files to each `files[].name` path returned by the data source
- prints the joined `result.assistant` texts on success

Expected `call_data_source_tool` response shape:

```python
{
    "is_success": bool,
    "result": {"user": list[str], "assistant": list[str]} | None,
    "error": {"user": list[str], "assistant": list[str]} | None,
    "files": [{"name": str, "content": str}],
}
```

When files are returned, `name` is the file path or name to write. The path is
usually dictated by the selected API's params in the Markdown docs. If an API
does not need files, the response normally has no files to save.
