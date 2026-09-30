# credentials/ — 凭证加密同步分区（M-S2）

纪律（先读，sync-plane-design §3 为准）：

- 本分区只收 **age 加密件**：`*.enc` + `*.enc.sha256`。**任何明文凭证禁止进入本分区/本仓库**（含"片段"）。
- `recipients.txt`：age 公钥（可入库）；私钥**永不入库**，新设备经一次性渠道带入。
- `inventory.md`：凭证清单（名称/用途/所在配置/过期时间）——只记元数据，永无值。
- 流程：`sync.ps1 seal`（本地明文暂存 → 加密 → push → 暂存即删）/ `sync.ps1 open`（解密 → 填充占位符）/ `sync.ps1 doctor`（连通体检）。
- 私人层 P 数据（SIAE §4.0）不进入本分区。
