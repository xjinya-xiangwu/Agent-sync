---
name: china_standards
description: "查询中国国家标准、行业标准、地方标准和团体标准。通过 agent-gw 统一接入,支持 search 检索、detail 元信息、fetch 全文访问元数据。"
---

# china_standards —— 国家及行业标准查询

通过 `scripts/china_standards_tool.py` 查询**中国标准**:国家标准(GB 国标)、行业标准(行标)、地方标准(地标)、团体标准(团标)。所有查询通过 `agent-gw` 数据源工具统一接入。

## 覆盖范围

`china_standards` 数据源内部按 `standard_type` 区分四类标准:

| `standard_type` | 标准类型 | 标准号示例 |
|----------------|---------|-----------|
| `gb` | 国家标准(GB 国标) | `GB 19083`、`GB/T 22927` |
| `hb` | 行业标准(行标) | `QC/T 1293`、`YY 0469` |
| `db` | 地方标准(地标) | `DB51/T 3367`、`DB33/…` |
| `tt` | 团体标准(团标) | `T/CAS …`、`T/ZHHX 011` |

> 企业标准、国际/国外标准暂不在本插件范围内。

## 命令形态

```bash
python3 scripts/china_standards_tool.py describe
python3 scripts/china_standards_tool.py call \
  --api-name <api> \
  --params-json '{"required":"value"}'
```

- `describe`: 打印 `china_standards` 数据源的完整 API 文档(Available APIs + Required Parameters)。
- `call`: 调用指定 API,`payload` 包含 `data_source_name`(`china_standards`)、`api_name`、`params`。
- `--data-source` 默认为 `china_standards`;单数据源场景下通常不需要显式指定。

## Setup

检查 `agent-gw` Python SDK 是否已安装,仅在未安装时执行安装:

```bash
python3 -c "import agent_gw" || python3 -m pip install "$(curl -s https://cdn.kimi.com/agentgw/pysdk/manifest.json | python3 -c 'import json,sys; print(json.load(sys.stdin)["latest"]["url"])')"
```

SDK 使用 `KIMI_API_KEY` 环境变量或 `~/.kimi/agent-gw.json` 鉴权。

## Workflow

1. 运行 `python3 scripts/china_standards_tool.py describe` 获取 `china_standards` 的 API 文档。
2. 仔细阅读返回的 Markdown,确认每个 API 的必填参数和可选项。
3. 根据用户需求选择 API:
   - `china_standards_search`: 按标准号或关键词检索。
   - `china_standards_detail`: 用 `search` 返回的 `standard_id` 取完整元信息。
   - `china_standards_fetch`: 获取 GB 或 TT 标准的全文访问元数据(非本地文件)。
4. 构造 `params`。`standard_type` 必填,取值为 `gb`/`hb`/`db`/`tt`。
5. 调用 `call_data_source_tool`。脚本发送 `{"data_source_name": "china_standards", "api_name": <api>, "params": {...}}`:
   ```bash
   python3 scripts/china_standards_tool.py call \
     --api-name china_standards_search \
     --params-json '{"standard_type":"gb","query":"GB 19083","page_size":5}'
   ```
6. 若调用失败,根据返回的错误信息向用户说明原因。
7. 若调用成功,读取 `resp.result.assistant` 中的文本作答。脚本会把返回的文本内容直接打印到 stdout。

## 标准号 → standard_type 决策

- 标准号带 **`GB`/`GB/T`** 前缀,或问「国家标准 / 国标」 → `standard_type=gb`。
- 标准号是**行业代号**(如 `QC/T`、`YY`、`JT`、`SL`、`NY`、`JB`…),或问「行业标准 / 行标」 → `standard_type=hb`。
- 标准号带 **`DB`+ 地区码**(如 `DB51` 四川、`DB33` 浙江),或问「地方标准 / 地标」 → `standard_type=db`。
- 标准号带 **`T/`** 前缀(团体代号,如 `T/CAS`、`T/CSTM`),或问「团体标准 / 团标」 → `standard_type=tt`。
- 只给主题词、不确定归属,或跨类型 → 可分别用不同 `standard_type` 多次 `search`,再汇总作答。

## 示例

```bash
# 1. 查看 API 文档
python3 scripts/china_standards_tool.py describe

# 2. 检索国标
python3 scripts/china_standards_tool.py call \
  --api-name china_standards_search \
  --params-json '{"standard_type":"gb","query":"口罩","page_size":5}'

# 3. 取单条详情(用 search 返回的 standard_id)
python3 scripts/china_standards_tool.py call \
  --api-name china_standards_detail \
  --params-json '{"standard_type":"gb","standard_id":"0B330DE79FDFCE9DE06397BE0A0AEFB0"}'

# 4. 获取全文访问元数据
python3 scripts/china_standards_tool.py call \
  --api-name china_standards_fetch \
  --params-json '{"standard_type":"gb","standard_id":"0B330DE79FDFCE9DE06397BE0A0AEFB0"}'
```

## 重要注意

- **全文不要编造**:标准正文/条款/PDF 在官方详情页或 `openstd` 全文页,插件只给到入口元数据。**不要臆造条款号、数值或全文内容**。
- **查不到 ≠ 不存在**:某 `standard_type` 无结果,可能是选错了标准类型或关键词太长。换 `standard_type` 或改用更短的子串再试。
- **保留 nature / status 口径**:回答时保留 `强制性`/`推荐性` 与 `现行`/`废止`/`即将实施`;这些直接影响标准是否仍适用。
- **失败处理**:接口报错或返回空,如实说明,不要编造数据或链接。
