# Beginner-Friendly Onboarding Playbook

Use these scripts when the user is not technical or seems unsure. Keep each message short. Do not mention all providers, all ports, or CLI commands until the user reaches that step.

## Tone Rules

- Lead with the next action, not a protocol explanation.
- Use "授权码/应用专用密码" instead of "credential" or "secret" in user-facing Chinese.
- Say "IMAP 是读信/收信，SMTP 是发信" only if the user asks why both are needed.
- Avoid saying "配置服务器" first. Say "先去邮箱里开通第三方客户端访问".
- After giving a link, stop and ask the user to tell you when they are done.
- Never ask for the normal mailbox login password, OAuth code, recovery code, or 2FA code.
- When asking for an authorization code/app password, ask for the full mailbox address at the same time unless it is already known.
- Do not save or test a bare authorization code/app password without a mailbox address.

## Opening

If the user has not named a mailbox yet:

```text
可以，我一步一步带你绑定邮箱。

我会先看看有没有已经保存过的邮箱授权；如果没有，就是第一次绑定。

你先告诉我：要绑定哪个邮箱？发邮箱服务名或后缀就行，比如 QQ邮箱、163、Gmail、Outlook、企业邮箱，或者 example.com。
```

If the user already named a provider or gave an address, do not ask again. Immediately give the matching link:

```text
收到，我先按 {provider} 来带你开通。

先打开这个页面：
{provider_link}

然后按这个路径找：
{click_path}

目标是生成一个“授权码/应用专用密码”。这个码是给第三方客户端用的，不是你的登录密码。生成后告诉我“好了”。

等会儿绑定时需要两样东西：完整邮箱地址 + 刚生成的授权码/应用专用密码。授权码必须和邮箱地址绑定在一起，不能只给码。
```

## Provider Quick Links

Use these as the first response after the user names a mailbox provider:

| User says | Link to give first | Click path / instruction |
|---|---|---|
| QQ邮箱 / qq.com / foxmail.com | https://wx.mail.qq.com/account | 账号与安全 -> 安全设置 -> POP3/IMAP/SMTP/Exchange/CardDAV 服务 -> 开启服务 -> 生成授权码 |
| 163邮箱 / 163.com | https://mail.163.com/ | 设置 -> POP3/SMTP/IMAP -> 开启 IMAP/SMTP -> 生成授权码 |
| 126邮箱 / 126.com | https://mail.126.com/ | 设置 -> POP3/SMTP/IMAP -> 开启 IMAP/SMTP -> 生成授权码 |
| yeah.net | https://www.yeah.net/ | 设置 -> POP3/SMTP/IMAP -> 开启 IMAP/SMTP -> 生成授权码 |
| 网易企业邮箱 / 网易云企业邮箱 / 北大邮箱 | user webmail host, or `https://<webmail-host>/static/commonweb/authcode.html` after login | 优先找：顶部 设置 -> 账号与安全 -> 客户端设置 -> 进入设置 -> 专属授权密码；找不到再试：顶部 客户端、系统设置 -> 客户端设置、授权码管理 |
| Gmail | https://mail.google.com/ then https://myaccount.google.com/security | Gmail 设置 -> 转发和 POP/IMAP -> 启用 IMAP；Google 账号安全 -> 应用专用密码 |
| Google Workspace | https://mail.google.com/ | Same as Gmail, but admin may need to allow IMAP/app passwords |
| Outlook / Hotmail | https://outlook.live.com/mail/ | Settings -> Mail -> Sync email / IMAP, if available |
| Microsoft 365 | https://outlook.office.com/mail/ | Admin may need to allow IMAP/SMTP AUTH; prefer OAuth if product supports it |
| 腾讯企业邮箱 / Tencent Exmail | https://exmail.qq.com/ | 设置 -> 客户端设置 / POP3/IMAP/SMTP 服务 -> 客户端专用密码/授权码 |
| 阿里邮箱 / Aliyun Mail | https://mail.aliyun.com/ or https://qiye.aliyun.com/ | Webmail settings -> account/security/client login password |
| Zoho | https://mail.zoho.com/ | Mail Settings -> Mail Accounts -> IMAP Access |
| Fastmail | https://app.fastmail.com/settings/security | Settings -> Privacy & Security -> App passwords |
| iCloud | https://account.apple.com/ | Sign-In and Security -> App-Specific Passwords |
| Yahoo | https://login.yahoo.com/account/security | Account Security -> Generate app password |
| Proton | https://proton.me/mail/bridge | Install Proton Mail Bridge; use Bridge's local IMAP/SMTP settings |
| Tuta / Tutanota | https://app.tuta.com/ | Standard IMAP/SMTP is unsupported |

## QQ Mail

```text
QQ邮箱先打开这个页面：
https://wx.mail.qq.com/account

然后点：
账号与安全 -> 安全设置 -> POP3/IMAP/SMTP/Exchange/CardDAV 服务

把 IMAP/SMTP 服务开启，然后生成授权码。生成后告诉我“好了”。
如果这个 agent 要直接帮你连邮箱，你再把完整 QQ 邮箱地址和授权码一起发给我；不要发 QQ 登录密码，也不要发短信验证码。
```

After the user has the authorization code:

```text
好，QQ邮箱的连接信息是：
IMAP（读信）：imap.qq.com，993，SSL
SMTP（发信）：smtp.qq.com，465，SSL

现在把完整邮箱地址和授权码填到绑定页面里。没有输入框、需要这个 agent 直接操作邮箱的话，可以把邮箱地址和授权码一起发给我；我会按邮箱地址加密保存到 Email 插件的鉴权目录里，不会复述或记录到普通日志。
```

## NetEase 163 / 126 / yeah

```text
网易邮箱先登录网页版邮箱：
163：https://mail.163.com/
126：https://mail.126.com/
yeah：https://www.yeah.net/

然后找：
设置 -> POP3/SMTP/IMAP

把 IMAP 和 SMTP 打开，并生成“授权码”。生成后告诉我“好了”。

下一步需要同时提供完整邮箱地址和授权码，邮箱地址用来确认这条授权码绑定到哪一个邮箱。
```

## NetEase Enterprise / NetEase Cloud Mail

```text
网易企业邮箱先登录你的企业/学校邮箱网页版。

如果是北大邮箱或新版网易企业邮箱，优先按这个路径找：
顶部“设置” -> 左侧“账号与安全” -> “客户端设置” -> “进入设置”

这里通常会让你给 Outlook、手机邮件 App 这类客户端设置收取时间和“专属授权密码”。这个专属授权密码就是后面 IMAP/SMTP 要用的授权码，不是邮箱登录密码。

如果这个路径没有，继续试这几个位置：
- 顶部“客户端”
- 设置 -> 系统设置 -> 客户端设置
- 搜索或菜单里找“授权码管理”
- 搜索“客户端设置”“专属授权密码”“IMAP/POP/SMTP”

有些网易企业邮箱登录后可以直接打开：
https://<你的webmail域名>/static/commonweb/authcode.html

例如你的邮箱页面是 mailshz.qiye.163.com，就打开：
https://mailshz.qiye.163.com/static/commonweb/authcode.html

不要复制带 sid、uid 的长链接，那些是登录会话参数。

生成后，把完整邮箱地址和专属授权密码/授权码一起用于绑定。
```

## Gmail / Google Workspace

```text
Gmail 先打开：
https://mail.google.com/

在 Gmail 里确认：
设置 -> 查看所有设置 -> 转发和 POP/IMAP -> 启用 IMAP

然后打开 Google 账号安全页：
https://myaccount.google.com/security

如果能看到“应用专用密码”，生成一个给邮箱客户端用的密码。很多账号需要先开启两步验证。

下一步绑定时需要同时提供 Gmail 地址和应用专用密码。
```

For Workspace:

```text
如果这是公司/学校 Google Workspace，管理员可能禁用了 IMAP 或应用专用密码。你如果看不到相关入口，下一步需要找管理员确认是否允许第三方邮件客户端。
```

## Outlook / Microsoft 365

```text
Outlook 先登录：
个人邮箱：https://outlook.live.com/mail/
公司邮箱：https://outlook.office.com/mail/

很多 Microsoft 邮箱更推荐 OAuth 登录。如果这里只能用 IMAP/SMTP，可能需要管理员允许 IMAP/SMTP AUTH。

你先看设置里有没有“同步电子邮件 / IMAP / POP / SMTP”相关入口。看不到的话告诉我邮箱是个人 Outlook 还是公司 Microsoft 365。
```

## Tencent Exmail / WeCom Mail

```text
腾讯企业邮箱先打开：
https://exmail.qq.com/

在网页版邮箱里找：
设置 -> 客户端设置 / POP3/IMAP/SMTP 服务

需要生成“客户端专用密码”或“授权码”。如果看不到入口，可能是企业管理员关闭了第三方客户端访问。

生成后，把完整企业邮箱地址和客户端专用密码/授权码一起用于绑定。
```

## Custom Domain

```text
这是自定义域名邮箱，我需要先判断它背后是哪家服务。

你知道它用的是哪家吗？比如 Google Workspace、Microsoft 365、腾讯企业邮箱、网易企业邮箱、阿里邮箱、Zoho、公司自建邮箱。

不知道也没关系，你可以把邮箱后缀发我，比如 example.com。我会先按常见企业邮箱路径排查。
```

## Proton / Tuta

Proton:

```text
Proton 不能直接用普通 IMAP 地址登录，需要 Proton Mail Bridge。
先打开：
https://proton.me/mail/bridge

安装 Bridge 并登录后，Bridge 会显示本地 IMAP/SMTP 地址、端口和专用密码。把 Bridge 显示的那套信息用于绑定。
```

Tuta:

```text
Tuta/Tutanota 不支持标准 IMAP/SMTP。这个邮箱不能按普通 IMAP 方式绑定，只能用 Tuta 官方 App/Web，除非产品有专门的 Tuta 集成。
```

## When The User Has The Code

```text
好了。下一步是连接测试。

如果页面里有输入框，把完整邮箱地址和刚生成的授权码一起填进去。
如果是我这个 agent 直接帮你连邮箱，你可以把完整邮箱地址和授权码一起发给我；我会按邮箱地址加密保存到 Email 插件的鉴权目录，后续新会话可以恢复使用。不要发登录密码、短信验证码、2FA code 或恢复码。
```

When storing credentials for direct mailbox operation:

```text
我会把这一个邮箱地址和它的授权码单独保存。多个邮箱会分开管理，比如 QQ、163、Gmail 各自一条，不会混用。
如果只有授权码、没有邮箱地址，我不能保存或连接；需要先知道这条授权码属于哪个邮箱。
```

At the start of a new conversation:

```text
我先看看之前有没有保存过邮箱授权。
会优先检查 Email 插件的鉴权目录：/mnt/agents/.user/auth/email 和 ~/.kimi-work/auth/email。
保存过的话，可以直接选邮箱继续，不用重新生成授权码；两个目录都没有可用授权时，就是第一次绑定。
```

When the user asks to disconnect:

```text
可以，我会删除这个邮箱保存的授权码。删掉后，如果以后还要用这个邮箱，需要重新去邮箱里生成授权码。
```

When the user asks to uninstall or clear the Email plugin:

```text
可以。卸载插件本身不一定会自动执行清理脚本，所以我会先清空 Email 插件的鉴权目录；这里面保存的所有邮箱授权码都会一起删除。
```

## Connection Test Result Scripts

Success:

```text
连上了。IMAP 读信正常，SMTP 发信也可以继续测。
```

Authentication failed:

```text
认证失败，通常是用了登录密码，或者授权码复制错了。
你重新生成一个授权码，再试一次。注意不要用邮箱登录密码。
```

IMAP disabled:

```text
邮箱能登录，但 IMAP 没开。回到邮箱设置里确认 IMAP/SMTP 服务已经开启。
```

SMTP failed:

```text
读信可能正常，但发信服务器没连上。请确认 SMTP 服务已开启，并且 SMTP 也使用同一个授权码/应用专用密码。
```

Enterprise blocked:

```text
这个错误像是企业管理员限制了第三方客户端。需要管理员打开 IMAP/SMTP 或允许客户端专用密码。
```
