---
name: china_public_data
description: "中国政府开放数据查询。核心能力:(1)国家统计局(NBS)宏观指标语义查询(china_nbs_query)与指标发现(china_nbs_indicators),覆盖11,789个全国/省/市指标;(2)国家公共数据资源登记平台(china_nda_registry_search/access)目录检索与获取方式路由;(3)已接入省级开放平台目录检索(china_nda_province_search)。查询结果以CSV文件形式返回。"
---

# china_public_data —— 中国政府开放数据查询

通过 `scripts/china_public_data_tool.py` 调用 **big-py data_source** 服务查询中国政府开放数据。dispatcher 是 agent-gw 数据源服务之上的薄转发层，不直接访问统计局或数据局网站。

> **运行目录**：以下命令中的 `scripts/...` 为相对路径，请在插件根目录（`kimi.plugin.json` 所在目录）下执行，或改用绝对路径。skill 目录内没有 `scripts/` 子目录。
>
> ```bash
> cd <plugin-root>
> python3 scripts/china_public_data_tool.py ...
> ```

## Routing —— 何时使用本插件

用户提出以下需求时，将本插件作为首选数据源，**实际运行 dispatcher，不要凭记忆回答数据**：

- 查 GDP、CPI、PPI、工业增加值、固定资产投资、社零、进出口、失业率、居民收入、人口、M2、PMI 等中国宏观经济统计数据（全国/省/市）；
- 查"国家数据局登记了哪些数据资源"、某条登记资源如何获取；
- 查已接入 13 个区域码的省级开放平台数据目录。

用户不需要说出"国家统计局""NBS"或任何 API 名称。"2026 上半年 CPI 涨幅""云南有哪些扶贫相关登记数据"都应触发本插件。

**以下需求本插件无法直接满足，应如实告知并改用其他来源**：

- CPI/PPI 等指数的**环比**口径（NBS 端仅有"上年同月=100"同比口径）；
- 未接入省份（除 13 个区域码外）的省级开放平台目录；
- 细分民生指标（贫困发生率、建档立卡等）不在 NBS 指标库时。

## 核心能力

插件内部对接两个 datasource（脚本常量 `AGENT_GW_SOURCES`，仅此两个）：

- **`china_nda`** —— 国家数据局体系。
  - `china_nda_registry_search`：国家公共数据资源登记平台(`sjdj.nda.gov.cn`)目录检索，结果写入 CSV 文件。
  - `china_nda_registry_access`：解析登记资源的访问方式（开放 URL、授权运营机构或用数申请指引）。
  - `china_nda_provinces`：列出 `china_nda_province_search` 支持的所有省份/区域码。
  - `china_nda_province_search`：已接入省级开放平台目录检索（按 `province_code` 路由），结果写入 CSV 文件。
  - 已接入 13 个区域码：海南 460000、江西 360000、山东 370000、广东 440000、北京 110000、福建 350000、安徽 340000、湖南 430000、湖北 420000、内蒙古 150000、四川 510000、广西 450000、哈尔滨市 230100。

- **`china_nbs`** —— 国家统计局(`data.stats.gov.cn`)。
  - `china_nbs_query`：宏观指标语义查询，支持 18 个常用精选指标以及 `china_nbs_indicators` 返回的任意指标，结果写入 CSV 文件。当前精选指标覆盖：GDP（年度全国/省/市、季度全国/省）、CPI（月度全国/省/主要城市）、PPI（月度/年度全国）、工业增加值、固定资产投资、零售、进出口、失业率、可支配收入、人口、M2（年度/月度全国）、房地产投资、制造业 PMI、外汇储备、发电量、工业企业利润等。
  - `china_nbs_indicators`：指标发现，支持按关键词搜索 11,789 个全国/省/市指标的名称、类别和目录路径，返回指标元数据及支持的 `scope`/`frequency`。

## 命令形态

```bash
# 1. 查看聚合后的数据源文档
python3 scripts/china_public_data_tool.py describe

# 2. 调用具体 API
python3 scripts/china_public_data_tool.py call \
  --data-source <china_nda|china_nbs> \
  --api-name <api> \
  --params-json '{...}'
```

- `search`/`query` 类 API 会**把结果写入 `filepath` 指定的 CSV 文件**，脚本 stdout 打印摘要/文件路径。
- `indicators` / `provinces` / `registry_access` 类 API 直接返回文本/JSON 到 stdout。
- 参数也可以用 `--params-file <path.json>` 传入（与 `--params-json` 二选一）。参数含中文、JSON 较长或 `filepath` 路径含空格时，优先用 `--params-file` 避免 shell 引号/转义问题：

  ```bash
  python3 scripts/china_public_data_tool.py call \
    --data-source china_nbs \
    --api-name china_nbs_query \
    --params-file /tmp/china_nbs_params.json
  ```

## NBS 工作流（先 indicators 再 query）

不同指标支持的地区/频率不同。18 个常用精选指标（GDP、CPI、PPI 等）可直接 query，但仍需确保 `region`/`frequency` 在该指标支持范围内；对于 `china_nbs_indicators` 返回的非常用指标，**必须先 indicators 再 query**，否则容易因 scope/frequency 不匹配报 `PARAMETER_ERROR`。

1. **指标发现**：用 `china_nbs_indicators` 按关键词搜索指标，查看返回的 `scope`（支持地区层级）和 `frequency`（支持频率）。
2. **语义查询**：用 `china_nbs_query` 查询具体指标，`region`/`frequency` 必须与 indicators 返回的支持范围一致。

`china_nbs_indicators` 返回示例：

```json
{
  "total": 1, "page": 1, "page_size": 50,
  "indicators": [{
    "name": "CPI", "unit": "上年同月=100",
    "frequency": "monthly", "scope": ["city", "national"], "path": ""
  }]
}
```

- `frequency`：该指标支持的频率。多数指标只支持单一频率，传不支持的频率会报 `PARAMETER_ERROR`（如 CPI 传 `annual`）；PPI、M2、GDP 等精选指标已支持多频率，以下方「当前精选指标与支持的 `scope`/`frequency`」表为准。
- `scope`：支持的地区层级。仅含 `national` 的指标不能传省名。

当前精选指标与支持的 `scope`/`frequency`：

> 注意：PPI 年度 / M2 月度 / GDP 季度省级 / CPI 月度省级等能力依赖 big-py china_nbs MR !532 部署后生效；如返回 `PARAMETER_ERROR` 说明 datasource 尚未部署，请改用已有能力或如实告知用户。

| 指标 | 支持频率 | 支持 scope | 说明 |
|------|---------|-----------|------|
| GDP | annual, quarterly | national, province, city | 季度只支持全国/省；季度历史范围可能 partial coverage |
| CPI | monthly | national, province, city | 省级按年份分段自动选择指标 ID |
| PPI | monthly, annual | national | 年度需用 `PPI + frequency=annual` 或别名 `ppi_annual` |
| M2 | annual, monthly | national | 月度为同比增速 |
| 其他精选指标（工业增加值、固定资产投资、零售、进出口、失业率、可支配收入、人口、房地产投资、制造业 PMI、外汇储备、发电量、工业企业利润等） | 按指标默认 | 以 indicators 返回为准 | 非常用指标必须先查 `china_nbs_indicators` 确认范围 |

### `year` 参数决策

`china_nbs_query` 省略 `year` 时的返回量**分频率**：annual 返回最近 10 年；quarterly 返回最近若干季度；**monthly 只返回最近 1 期**。问"上半年变化""近几个月走势"等趋势类问题却只拿到 1 行数据，必然二次调用返工——先判断意图再发起查询：

```text
china_nbs_query 的 year 参数 —— 按提问意图决定
├─ 问"最新一期"（如"最新 CPI/PPI 同比"）
│   → 省略 year，返回最近 1 期即可
└─ 问"趋势/区间"（如"上半年变化""近几个月走势"）
    ├─ monthly → 显式传 year（如 "year":"2026"）或年份范围（如 "year":"2021-2025"）
    │   └─ 返回对应年份全部 12 个月槽位，未到月份 value 为空，客户端过滤空行
    └─ annual  → 省略 year 返回最近 10 年，客户端截取所需区间
```

### 示例：查 2026 年上半年全国 CPI 走势（monthly 端到端）

```bash
# monthly 趋势查询必须显式传 year,否则只返回最近 1 期;可传单年份或年份范围
python3 scripts/china_public_data_tool.py call \
  --data-source china_nbs \
  --api-name china_nbs_query \
  --params-json '{"indicator":"CPI","region":"全国","frequency":"monthly","year":"2026","filepath":"/tmp/china_nbs_cpi_2026.csv"}'
# 返回 2026 年 1-12 月槽位:已公布月份有值,未到月份 value 为空,读取 CSV 时过滤空行。
# 口径为"上年同月=100",当月同比涨幅 = value − 100。
```

### 示例：查 PPI 年度涨幅（datasource 已支持年度直接查询）

NBS 指标库里有 4 个同名年度指标都叫"工业生产者出厂价格指数 (上年=100)"，分属不同目录。旧版 `china_nbs_query` 按名称匹配会报歧义，当前 datasource 已给 canonical 年度 PPI 提供别名支持：

```bash
# 方式 1：显式用年度 PPI 别名（推荐，语义清晰）
python3 scripts/china_public_data_tool.py call \
  --data-source china_nbs \
  --api-name china_nbs_query \
  --params-json '{"indicator":"ppi_annual","region":"全国","year":"2021-2025","filepath":"/tmp/china_nbs_ppi_annual.csv"}'

# 方式 2：直接用 PPI + frequency=annual
python3 scripts/china_public_data_tool.py call \
  --data-source china_nbs \
  --api-name china_nbs_query \
  --params-json '{"indicator":"PPI","region":"全国","frequency":"annual","year":"2021-2025","filepath":"/tmp/china_nbs_ppi_annual.csv"}'
```

返回的 `value` 为"上年=100"的年度指数，涨幅 = `value - 100`（如 108.1 表示 +8.1%）。

### 示例：查 M2 月度同比增速

```bash
python3 scripts/china_public_data_tool.py call \
  --data-source china_nbs \
  --api-name china_nbs_query \
  --params-json '{"indicator":"M2","region":"全国","frequency":"monthly","year":"2025","filepath":"/tmp/china_nbs_m2_2025.csv"}'
```

### 示例：查广东季度 GDP

```bash
python3 scripts/china_public_data_tool.py call \
  --data-source china_nbs \
  --api-name china_nbs_query \
  --params-json '{"indicator":"GDP","region":"广东","frequency":"quarterly","year":"2025","filepath":"/tmp/china_nbs_gdp_gd_2025q.csv"}'
```

> 季度数据目前只返回最近若干季度，请求历史季度范围时可能返回 partial coverage warning。

### 示例：查人均可支配收入（先确认指标支持的 scope）

```bash
# 1. 先发现指标
python3 scripts/china_public_data_tool.py call \
  --data-source china_nbs \
  --api-name china_nbs_indicators \
  --params-json '{"keyword":"居民人均可支配收入"}'

# 2. 根据返回的 scope 决定 region
#    如果 indicators 返回该指标支持 province，可传具体省名；若只支持 national，则传 "全国"
python3 scripts/china_public_data_tool.py call \
  --data-source china_nbs \
  --api-name china_nbs_query \
  --params-json '{"indicator":"居民人均可支配收入","region":"全国","filepath":"/tmp/china_nbs_income.csv"}'
```

## NDA 工作流（重要）：registry_search → registry_access 参数衔接

`china_nda` 的典型用法是**两步闭环**：先查目录，再查获取方式。两步之间的参数传递规则如下：

1. **`registry_search` 返回的 CSV 中带有 `access_*` 四列**：`access_code`、`access_province_code`、`access_data_type`、`access_platform_code`。
2. **这四列就是 `registry_access` 的入参，按列直接透传即可**：
   - `code` ← `access_code`
   - `province_code` ← `access_province_code`
   - `data_type` ← `access_data_type`
   - `platform_code` ← `access_platform_code`（CSV 中该列有值时务必带上；虽然接口标注可选，带上能保证路由到正确的平台）
3. 不要凭名称猜参数：CSV 中同时存在 `dataRegistCode` 等原始列，**优先使用 `access_*` 列**而不是自行从其他列拼凑。
4. `registry_access` 返回的是**获取方式**而非数据本身：
   - `method: "open"` → 给出 `openPlatformUrl`，可直接访问下载；
   - `method: "authorized_operation"` → 返回授权运营机构，需联系该机构；
   - `method: "apply"` → 非公开，需通过『用数申请』向持有单位申请。

### 示例：查医保登记资源并解析获取方式

```bash
# 1. 目录检索（结果写入 CSV）
python3 scripts/china_public_data_tool.py call \
  --data-source china_nda \
  --api-name china_nda_registry_search \
  --params-json '{"keyword":"医保","province_code":"130000","page":1,"page_size":10,"filepath":"/tmp/china_nda_registry.csv"}'

# 2. 从 CSV 读取目标行的 access_* 四列，透传给 registry_access
python3 scripts/china_public_data_tool.py call \
  --data-source china_nda \
  --api-name china_nda_registry_access \
  --params-json '{"code":"1393264726771781632103","province_code":"130000","data_type":"1","platform_code":"13000"}'
# 返回示例：{"access":{"method":"apply","institutionName":"卢龙县医疗保障局",
#           "guidance":"非公开，需通过『用数申请』向持有单位『卢龙县医疗保障局』申请获取。"}}
```

## 查询决策树：用户问题 → API 选择

```text
用户问题
├─ 宏观统计数值（GDP/CPI/收入/人口…）
│    └─ china_nbs 体系
│         1. china_nbs_indicators(keyword)  → 确认指标存在、scope、frequency
│         2. china_nbs_query(indicator, region, frequency, year)
│              ├─ region/frequency 必须在 indicators 返回的支持范围内
│              ├─ annual 省略 year → 最近 10 年
│              ├─ quarterly 省略 year → 最近若干季度（超出窗口可能返回 partial coverage warning）
│              └─ monthly 省略 year → 最近 1 期；趋势/区间查询显式传 year 或 year 范围
├─ "登记了哪些数据资源" / "某资源怎么获取"
│    └─ china_nda 体系
│         1. china_nda_registry_search(keyword, province_code)
│              ├─ 命中 → 用返回的 access_* 四列接力 registry_access
│              └─ 无结果 → 换近义短词（贫困/扶贫/脱贫/低保…）重试
│         2. china_nda_registry_access(code, province_code, data_type, platform_code)
│              → 开放型给 URL；授权运营型给机构；申请型提示用数申请
└─ "某省开放平台有哪些数据"
     └─ china_nda_province_search(province_code)
          ├─ 省码在 13 个已接入列表内 → 正常检索
          └─ 不在 → 用 china_nda_provinces 核对；告知用户走该省官网
```

## Stable API Contract

### `china_nbs_indicators`（指标发现）

可选参数：

- `keyword`：按指标名称、类别或目录路径过滤。
- `frequency`：`annual`、`quarterly`、`monthly`。
- `scope`：`national`、`province`、`city`。
- `page`：页码，从 1 开始，默认 1。
- `page_size`：每页条数，默认 50，最大 200。

返回字段：`name`、`unit`、`frequency`、`scope`、`path`。

### `china_nbs_query`（语义查询）

必填：

- `indicator`：精选指标别名（GDP/CPI/PPI/收入/人口等）或 `china_nbs_indicators` 返回的任意指标名称。
- `filepath`：目标 CSV 文件路径。

可选：

- `region`：默认"全国"；具体可用范围以 indicators 返回的 `scope` 为准。不认识的地区名会报 `PARAMETER_ERROR`，不会静默按全国返回。
- `frequency`：默认按指标而定；具体可用范围以 indicators 返回的 `frequency` 为准。
- `year`：单年份或年份范围，如 `2026`、`2021-2025`。省略时：annual 返回最近 10 年，monthly 返回最近 1 期。趋势/区间类 monthly 查询建议显式传 year 或 year 范围。quarterly 目前只返回最近若干季度，历史范围可能返回 partial coverage warning。

### `china_nda_registry_search`（登记目录检索）

必填：`filepath`。

可选：

- `keyword`：**精确子串匹配**（非分词），建议用短词。
- `province_code`：省级行政区划码，如 130000=河北。
- `industry_code`：行业编码。
- `data_type`：1=公共数据资源、2=产品和服务、3=开放数据。
- `page` / `page_size`：分页，默认 1 / 10。

输出 CSV 除资源元数据外，还包含 **`access_code`、`access_province_code`、`access_data_type`、`access_platform_code` 四列**，是 `registry_access` 的直接入参。

### `china_nda_registry_access`（获取方式解析）

必填：

- `code`：来自 `registry_search` CSV 的 `access_code` 列。
- `province_code`：来自 `registry_search` CSV 的 `access_province_code` 列。
- `data_type`：来自 `registry_search` CSV 的 `access_data_type` 列（1/2/3）。

可选：

- `platform_code`：来自 `registry_search` CSV 的 `access_platform_code` 列；**该列有值时建议带上**，确保路由到正确的登记平台。

返回的 `access.method` 三种取值：`open`（开放，给 `openPlatformUrl`）、`authorized_operation`（授权运营，给机构名）、`apply`（用数申请指引）。

### `china_nda_provinces` / `china_nda_province_search`

- `provinces` 无参数，返回已接入区域码列表。
- `province_search` 必填 `province_code`（限 13 个区域码）+ `filepath`，可选 `keyword`（部分省支持）、`page`/`page_size`。

## 核心能力边界（必读）

- **脚本只暴露 `china_nda` 和 `china_nbs` 两个 datasource**（见脚本 `AGENT_GW_SOURCES`）。早期的 `<source> <action>` 入口形态及 guizhou/chongqing/zhejiang/shanghai/shandong 地方直联 source 为**历史设计，当前版本不可用**，以本文件为准。
- **`china_nbs_indicators` 覆盖 11,789 个指标**，可按名称/类别/路径关键词搜索；但**不是所有指标都支持任意地区或频率**。
- **`china_nbs_query` 必须先确认指标支持的 scope/frequency**。例如 `居民人均可支配收入` 只支持 `national`，传 `云南` 会报 `PARAMETER_ERROR`。
- **`search`/`query` 类 API 必须提供 `filepath`**，结果会写入该路径的 CSV 文件。
- **`china_nda` 的 `registry_access` 返回的是获取方式**，不是原始数据；开放型返回 `openPlatformUrl`，授权运营型返回运营机构，申请型提示走用数申请。
- **`china_nda_province_search` 只接入 13 个区域码**，未覆盖全国（不含浙江、江苏、上海等）；未接入省份请走其他渠道（如该省政务数据开放平台官网）。
- **registry `keyword` 是精确子串匹配**，不是全文分词；长词如 `2020鄂州CPI` 可能查不到，应改为短词 `鄂州CPI` 或 `CPI`。
- **国家登记平台覆盖各省极不均**；某省 registry 查不到不等于没有，可尝试该省自有平台（若已接入）。
- **monthly 省略 `year` 只返回最近 1 期**；趋势/区间查询建议显式传 `year` 或年份范围（如 `2021-2025`）。annual 省略 year 返回最近 10 年。
- **quarterly 目前只返回最近若干季度**；请求历史季度范围时可能返回 partial coverage warning 或部分数据为空。
- **指数类指标只有同比口径**：CPI/PPI 为"上年同月=100"，涨幅 = value − 100；环比需改用国家统计局发布稿。
- **PPI 年度查询已支持**：NBS 指标库中 4 个目录下都有同名"工业生产者出厂价格指数 (上年=100)"，datasource 已给 canonical 年度 PPI 提供别名 `ppi_annual` / `PPI_年度` / `年度ppi` / `工业生产者出厂价格指数_年度`，也支持 `PPI` + `frequency=annual` 直接查询。
- **M2 月度查询已支持**：`M2` 现在支持 `frequency=monthly` 查询全国同比增速；年度查询仍可用。
- **GDP 季度省级查询已支持**：`GDP` 现在支持 `frequency=quarterly` 查询省级数据。
- **CPI 月度省级查询已支持**：`CPI` 现在支持 `frequency=monthly` 查询省级数据（按年份自动分段选择正确指标 ID）。

## 常见错误及修正

| 错误现象 | 原因 | 修正 |
|----------|------|------|
| `can't open file '.../skills/china_public_data/scripts/china_public_data_tool.py'` | 以 skill 目录为工作目录执行；脚本在**插件根目录** `scripts/` 下 | 先 `cd <plugin-root>`（插件根目录，即 `kimi.plugin.json` 所在目录）再执行 |
| `PARAMETER_ERROR - Missing required parameters: filepath` | `search`/`query` 类 API 没传 `filepath` | 在 `params-json` 中加入 `"filepath":"/tmp/xxx.csv"` |
| `PARAMETER_ERROR - Indicator ... does not support scope/frequency ...` | region/frequency 不在该指标支持范围内 | 先用 `china_nbs_indicators` 查看 `scope` / `frequency` |
| `PARAMETER_ERROR - Unsupported region ...` | region 不是全国/省级名/36 个主要城市之一 | 改用 `全国`、规范的省级名（如 `云南`），或改用其他来源 |
| monthly 查询省略 `year` 只返回 1 行 | monthly 省略 `year` 默认只给最近一期 | 趋势/区间类查询显式传 `"year":"2026"` 或 `"year":"2021-2025"`；返回含未来月份空值行，过滤即可 |
| `china_nbs_indicators` 返回 `NOT_FOUND` | 关键词没匹配到指标 | 换关键词，或减少/更换过滤条件 |
| 搜索 `2020鄂州CPI` 无结果 | registry keyword 是精确子串匹配 | 改为短词 `鄂州CPI` 或 `CPI` |
| `registry_access` 参数不对/路由失败 | 手工从 CSV 其他列拼参数 | 直接使用 CSV 的 `access_code` / `access_province_code` / `access_data_type` / `access_platform_code` 四列透传 |
| `china_nda` registry 查某省数据无结果 | 该省未在国家平台登记 | 转向该省自有平台（若已接入） |
| `china_nda_province_search` 报"未接入的省/区域码" | province_code 不在 13 个已接入列表中 | 用 `china_nda_provinces` 查可用编码；未接入省份走其官方开放平台 |
| 年度 PPI 查询报指标歧义/找不到 | NBS 有 4 个同名"工业生产者出厂价格指数 (上年=100)"，旧接口无法按目录区分 | datasource 已支持年度 PPI：用别名 `ppi_annual` 或 `PPI` + `frequency=annual` 查询 |
| quarterly 查询历史年份返回 partial coverage warning 或部分为空 | NBS 季度接口只返回最近若干季度 | 请求范围尽量限定在最近季度内；历史季度数据改用年度指标或搜索类 API 补充 |

**重试纪律**：相同参数的相同错误最多原样重试一次。遇到 `EMPTY_DATA` / `NOT_FOUND`，先按上表调整关键词、指标、地区或查询范围，再决定重试还是改用搜索类 API 补充；换用其他数据来源时，在回答中明确标注。

## Compliance

- 仅使用本文档记载的 agent-gw 数据源 API。
- 失败时报告错误信息；**不得编造指标数值、登记目录、获取方式**。
- 答案中保留数据来源（国家统计局/国家数据局登记平台）、指标口径（同比/累计）、地区与时间范围；`registry_access` 结果必须注明"仅为获取指引，非原始数据"。

## Setup（鉴权依赖）

调用前先确认环境，避免运行到一半才发现问题：

1. 工作目录是插件根目录（`kimi.plugin.json` 所在目录），`scripts/china_public_data_tool.py` 存在；
2. `agent_gw` Python SDK 可导入，仅在未安装时执行安装：

   ```bash
   python3 -c "import agent_gw" || python3 -m pip install "$(curl -s https://cdn.kimi.com/agentgw/pysdk/manifest.json | python3 -c 'import json,sys; print(json.load(sys.stdin)["latest"]["url"])')"
   ```

3. 已配置鉴权：`KIMI_API_KEY` 环境变量或 `~/.kimi/agent-gw.json` 至少其一存在。
