---
name: ifind-widgets-widgets
description: "当用户问某只证券的 K线/行情/走势/技术分析，或想快速看懂一家公司（基本面概览、股东、主营构成）时，用 iFinD 预设卡片渲染展示（runPluginWidget）。行情/公司类可视化问题的首选入口。仅当当前会话能读到 automation skill（具备 Blueprint/AutomationControl 能力）时使用；否则改用 ifind skill 的文字数据流程回答。"
---

<!-- PluginBuilder: widgets-v2 begin -->
# 同花顺iFinD金融数据 Widgets

Read the author's usage guidance for the selected Widget before choosing a tool. Conversation, Canvas, or both are recommendations; the user's explicit request takes precedence. Reading this Skill never authorizes running a Widget or creating a persistent Automation. Verify the plugin is installed before using either action; registration alone does not install it.

## 能力门控（先判断再用）

仅当当前会话的技能列表中能读到 `automation` skill（即宿主具备 Blueprint 能力，`AutomationControl.runPluginWidget` / `Canvas.addPluginWidgets` 可用）时，才使用本 skill 的卡片渲染流程。

读不到 `automation` skill 时：不要尝试 `runPluginWidget`、`addPluginWidgets` 或任何 Widget/Automation 调用（这些工具在当前环境不存在，调用必然失败）；改用 `ifind` skill 的 Workflow 数据查询流程，查到数据后直接以文字回答。

### `stock-quote-card` — 个股K线工作台
个股 K 线工作台（浅色/深色双主题）：红涨绿跌蜡烛图叠加主图成交量与支撑阻力，默认 MA20/MA60（MA5/MA10 可在均线设置中开启），头部 OHLC 读数跟随十字光标，底部周期选择（全部/120/60/20日），最新价虚线与轴标签；右侧实时行情（换手率按流通股本口径展示）、风险指标与关键结论（RSI 超买超卖，正负向配色）。
Automation template: `./automations/quote-source` (code).
<!-- PluginBuilder: author widget stock-quote-card begin -->
用途：会话内临时调用。用户想看某只证券的 K 线技术分析（蜡烛图、主图成交量、均线、支撑阻力、MACD、波动率/换手率/风险摘要）时用 runPluginWidget 直接展示；支持 A 股（.SH/.SZ/.BJ）、港股（.HK）、美股（.US）代码，runInput 传 {"ticker": "代码"}。卡片支持浅色/深色双主题（跟随客户端切换，仅换外观不重取数）、十字光标（头部 OHLC 读数联动）、底部周期选择（全部/120/60/20日）、滚轮缩放、拖拽平移，MACD 副图默认关闭、可按需开启；右轴为 TradingView 风格：规则刻度 + 最新价标签 + 最新成交量标签（红涨绿跌实心底，刻度固定、标签微调避让）。会话中的卡片是数据快照，卡片内不能换标的；用户想换标的时直接用自然语言给新代码，再次调用本卡即可。数据来自 iFinD 数据源，需本机已配置 agent-gw 凭证（与本插件的 iFinD 数据查询相同）；成交额与换手率为估算值，相对表现基准固定为沪深300。
<!-- PluginBuilder: author widget stock-quote-card end -->
Automation input contract:
```json
{
  "kind": "json",
  "schema": {
    "additionalProperties": false,
    "properties": {
      "ticker": {
        "description": "证券代码，如 600519.SH、000001.SZ、0700.HK、AAPL.US",
        "type": "string"
      }
    },
    "required": [
      "ticker"
    ],
    "type": "object"
  },
  "defaultInput": {
    "ticker": "600519.SH"
  }
}
```
Pass `runInput` directly as a JSON object. Never stringify or JSON-encode that object.
For a conversation request, call AutomationControl with:
```json
{
  "action": "runPluginWidget",
  "pluginId": "ifind",
  "widgetId": "stock-quote-card",
  "runInput": {
    "ticker": "600519.SH"
  }
}
```
For a Canvas request, call Canvas with:
```json
{
  "action": "addPluginWidgets",
  "pluginId": "ifind",
  "widgetIds": [
    "stock-quote-card"
  ],
  "canvasId": "<target canvas ID>"
}
```

### `company-profile-card` — 公司信息卡
公司信息卡（浅色/深色双主题）：单面板看懂一家公司——一句话简介、四张核心财务卡（含同比）、营收与一致预期图（历史柱+预期柱、净利率%折线、左右轴，营收/净利润/净利率分系列悬浮显示数值）、主营构成甜甜圈图（悬浮显示份额）与股东结构（控股股东+身份标签+三段式所有权条）；纯 iFinD 数据。
Automation template: `./automations/company-profile-source` (code).
<!-- PluginBuilder: author widget company-profile-card begin -->
用途：会话内临时调用。用户想快速看懂一家公司（主营业务、一句话简介、营收/净利润/毛利率/ROE 及近四年趋势、未来财年一致预期、净利率走势、主营构成、股东结构、财务同比风险提示）时用 runPluginWidget 直接展示，runInput 传 {"ticker": "A股代码"}。营收图为历史柱+一致预期柱（浅色）叠加净利率%折线；主营构成为甜甜圈图（<2% 并入其他，毛利率在悬浮提示）。卡片支持浅色/深色双主题。全部数据来自 iFinD；一致预期来自 ifind_get_forecast（仅 A 股，缺失时自动省略预测柱）。注意：应用户要求本卡不含公告板块——iFinD 公告接口（ifind_get_stock_announcement）实测持续返回 EMPTY_DATA 不可用，待接口恢复再考虑加回。风险提示为财务同比规则派生，不是人工研判。会话中的卡片是数据快照；用户想换公司时直接用自然语言给新代码再次调用。
<!-- PluginBuilder: author widget company-profile-card end -->
Automation input contract:
```json
{
  "kind": "json",
  "schema": {
    "additionalProperties": false,
    "properties": {
      "ticker": {
        "description": "A 股证券代码，如 600519.SH",
        "type": "string"
      }
    },
    "required": [
      "ticker"
    ],
    "type": "object"
  },
  "defaultInput": {
    "ticker": "600519.SH"
  }
}
```
Pass `runInput` directly as a JSON object. Never stringify or JSON-encode that object.
For a conversation request, call AutomationControl with:
```json
{
  "action": "runPluginWidget",
  "pluginId": "ifind",
  "widgetId": "company-profile-card",
  "runInput": {
    "ticker": "600519.SH"
  }
}
```
For a Canvas request, call Canvas with:
```json
{
  "action": "addPluginWidgets",
  "pluginId": "ifind",
  "widgetIds": [
    "company-profile-card"
  ],
  "canvasId": "<target canvas ID>"
}
```

After a successful conversation call the Widget is already displayed. The entire agent response is limited to 2000 characters and includes only status and optional agentSummary. Full rendering data remains in the Widget. If summaryUnavailable is true, do not infer facts from the omitted data. If summaryTruncated is true, the summary is incomplete. For deeper analysis use the plugin ordinary data tools; do not read the cleaned-up temporary Automation. Confirm briefly without rebuilding it or deploying it to Canvas unless the user requested that. Report errors and use the plugin's ordinary Skill workflow for other tasks.

<!-- PluginBuilder: widgets-v2 end -->
