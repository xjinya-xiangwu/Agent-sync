---
name: email-imap-onboarding
description: Use IMAP/SMTP to read, search, fetch, send, move, mark, and manage user mail across one or more mailboxes. Use when a user wants provider links, authorization-code/app-password setup, multiple mailbox credential handling, CLI connection tests, unsupported-provider checks, or troubleshooting for Gmail, Google Workspace, Outlook, Microsoft 365, Yahoo, iCloud, QQ, 163/126/yeah, Tencent Exmail, Aliyun Mail, Sina, Sohu, Zoho, Fastmail, Proton Bridge, GMX, mail.com, AOL, Yandex, Mail.ru, ISP mail, hosted mail, and custom domains.
---

# Email IMAP / SMTP Onboarding

## Core Behavior

Onboard the user into mailbox access for one or more accounts. Use IMAP for reading/searching/managing mail and SMTP for sending mail. A user can have multiple mailbox authorization codes; keep each code tied to its mailbox/provider and treat every code as password-equivalent secret material.

The mailbox password, app password, client password, or authorization code must enter the executing product/runtime somehow. Prefer a secure secret input, credential form, local secret store, or environment variable. If the product only supports chat handoff, treat any pasted authorization code as a secret: do not echo it, summarize it, write it to files, include it in logs, or ask for it again unless the previous value failed.

For Kimi main-site sandbox runs, use the encrypted plugin auth store when credentials must persist across conversations: `/mnt/agents/.user/auth/email`. The subdirectory name must match the plugin manifest name `email`, so platform or product cleanup can target all persisted Email authorization files. Detect this sandbox by checking whether `/mnt/agents/.user/auth` exists, as in the CLI plugin auth convention. For Kimi Work/local runs, use the product's credential store when available; otherwise use the bundled CLI default `~/.kimi-work/auth/email`.

CLI location note: in an Email plugin install, first try the easy plugin-root launcher `plugins/managed/email/scripts/mail_cli.py`. If it is absent, try the bundled skill script `plugins/managed/email/skills/email-imap-onboarding/scripts/mail_cli.py`. Desktop/package caches can expose the same layout under `plugin-packages/email`. In Kimi Work/local Desktop, if shell quoting around `Application Support` paths is unreliable, also try the no-space mirror `~/.kimi-work/plugins/managed/email/scripts/mail_cli.py` when it exists. If `plugins/managed/email` is missing but this `SKILL.md` is loaded, resolve `scripts/mail_cli.py` relative to the loaded skill folder before concluding the CLI is unavailable. Do not stop after checking only one location. Plugin file location and auth store location are separate checks.

Do not assume plugin uninstall automatically runs this skill's bundled script. The current plugin package has no manifest lifecycle hook. The script deletes credentials only when `scripts/mail_cli.py auth-clear --confirm-delete yes` (or `auth-delete`) is explicitly called, or when the host platform separately deletes `/mnt/agents/.user/auth/email`. If a user asks to uninstall, disconnect, or clear Email credentials, perform that cleanup step before or during uninstall.

Default to beginner mode. Do not start by dumping server tables, raw CLI commands, or protocol details. Ask one question, give one link, and tell the user exactly what to click next. Explain IMAP as "收信/读信" and SMTP as "发信" only when it helps.

Before treating the user as first-time setup, check for saved Email credentials. Run `scripts/mail_cli.py auth-check` when CLI access is available; it only reads metadata and file existence, does not decrypt secrets, does not migrate, and does not write files. If direct filesystem inspection is available, check metadata existence under both possible auth directories without printing secrets: `/mnt/agents/.user/auth/email` and `~/.kimi-work/auth/email`. If a usable saved mailbox exists, offer that mailbox first. If no usable saved mailbox exists, treat this as first-time binding. Run `auth-restore` only when intentionally migrating/repairing legacy metadata or verifying stored secret decryptability.

After the saved-account check, identify the mailbox provider unless the user already gave it:

```text
你需要绑定哪个邮箱？发邮箱服务名或邮箱后缀即可，比如 Gmail、Outlook、QQ邮箱、163、企业邮箱，或者 example.com。
```

If the user gives a full address, infer the provider from the domain. If the domain is custom or enterprise, ask which backend it uses when needed: Google Workspace, Microsoft 365, Zoho, Tencent Exmail, Aliyun Mail, Coremail, cPanel/hosting mail, Rackspace, IONOS, or "not sure".

## Beginner-Friendly Flow

Use this flow before showing technical settings:

1. Check saved accounts first with `auth-check` or by inspecting the two Email auth directories' non-secret metadata.
2. If saved accounts exist, ask which saved mailbox to use instead of asking for a new authorization code.
3. Ask which mailbox they want to bind only if the provider is missing.
4. Once the user says a provider or email domain, immediately give that provider's login/settings link and one short click path.
5. Ask them to generate an app password, authorization code, client password, or Bridge password.
6. When asking for a generated secret, always collect the full mailbox address at the same time unless it is already known. The address is the key that ties one authorization code to one mailbox.
7. Tell them what to do with the generated secret and address:
   - If the product has a credential input box, tell them to enter both the mailbox address and the authorization code/app password there.
   - If this agent must operate the mailbox directly and a persistent auth store is available, save only the generated code with `scripts/mail_cli.py auth-save --email <mailbox>`; it stores metadata in `accounts.json` and the authorization code in an encrypted secret file.
   - If chat handoff is unavoidable, ask them to send the full mailbox address plus the generated code, not the normal login password or any 2FA code.
   - If the user sends only an authorization code/app password with no mailbox address, do not store it or test it. Ask for the mailbox address first.
8. Only after the mailbox address and secret are available, run or suggest the CLI connection test.
9. Translate failures into plain next steps, such as "重新生成授权码" or "确认 IMAP/SMTP 已开启".

Read `references/onboarding-playbook.md` for copy-ready beginner scripts.

## Provider Link First

When the user has already named a provider, do not ask "which mailbox?" again. Immediately respond with the matching link and next click path:

- QQ -> `https://wx.mail.qq.com/account`, path `账号与安全 -> 安全设置 -> POP3/IMAP/SMTP/Exchange/CardDAV 服务 -> 开启服务 -> 生成授权码`.
- 163 -> `https://mail.163.com/`, path `设置 -> POP3/SMTP/IMAP`.
- 126 -> `https://mail.126.com/`, path `设置 -> POP3/SMTP/IMAP`.
- yeah.net -> `https://www.yeah.net/`, path `设置 -> POP3/SMTP/IMAP`.
- NetEase Enterprise/网易企业邮箱/北大邮箱 -> user's webmail host. Primary path for PKU/new NetEase enterprise UI: `顶部 设置 -> 账号与安全 -> 客户端设置 -> 进入设置 -> 生成/设置专属授权密码`. Fallback paths: `设置 -> 系统设置 -> 客户端设置`, top `客户端`, `授权码管理`, or `https://<webmail-host>/static/commonweb/authcode.html` after login.
- Gmail -> `https://mail.google.com/` for IMAP, then `https://myaccount.google.com/security` for app passwords.
- Outlook/Hotmail -> `https://outlook.live.com/mail/`; Microsoft 365 -> `https://outlook.office.com/mail/`.
- Tencent Exmail/腾讯企业邮箱 -> `https://exmail.qq.com/`.
- Proton -> `https://proton.me/mail/bridge`.
- Tuta/Tutanota -> `https://app.tuta.com/`, with a note that standard IMAP/SMTP is unsupported.

For providers not listed above, read `references/provider-catalog.md` and return the login/settings link from the matching row.

## Provider Lookup

Read `references/provider-catalog.md` when provider-specific instructions are needed. Use it to answer:

- where the user should log in
- which settings page or menu contains IMAP/POP/SMTP access
- whether they need an app password, client password, authorization code, OAuth flow, or Proton Bridge
- incoming IMAP host, outgoing SMTP host, ports, and TLS mode
- provider caveats and unsupported cases

When the user has a custom domain and does not know the provider, optionally suggest checking MX records or asking the mail administrator. Common MX hints:

- `aspmx.l.google.com` -> Google Workspace
- `*.protection.outlook.com` -> Microsoft 365
- `mx.zoho.*` -> Zoho Mail
- `mxbiz*.qq.com` -> Tencent Exmail
- `mxhichina.com` or `aliyun` mail hosts -> Aliyun/Alibaba Mail
- `messagingengine.com` -> Fastmail

## Answer Pattern

For a known provider, keep the user-facing answer short, friendly, and action-first:

1. Start with "可以，我一步一步带你开通".
2. Give one link and one click path.
3. Name the generated secret in the provider's words, such as "授权码", "应用专用密码", or "客户端专用密码".
4. Delay IMAP/SMTP server settings until the user has generated the secret or asks for technical details.
5. Tell them where to enter the mailbox address and the secret. Prefer a secure credential field; if this agent must receive it in chat to proceed, instruct the user to send the full mailbox address plus the authorization code/app password, never their normal login password or 2FA code.

Example shape:

```text
QQ邮箱可以走标准 IMAP。

你先做这一步：
打开授权码入口：https://wx.mail.qq.com/account

进去后点：账号与安全 -> 安全设置 -> POP3/IMAP/SMTP/Exchange/CardDAV 服务

把 IMAP/SMTP 服务开启，然后生成授权码。它不是 QQ 登录密码，是专门给第三方客户端/agent 用的密码。

生成的授权码相当于密码。如果产品有绑定页面，就把邮箱地址和授权码一起填进去；如果当前 agent 必须直接操作邮箱，再把完整邮箱地址和授权码发给 agent，但不要发送 QQ 登录密码或 2FA 验证码。

等授权码准备好后，再使用：
IMAP：imap.qq.com，端口 993，SSL/TLS
SMTP：smtp.qq.com，端口 465，SSL/TLS
```

## Secret Handling Rules

- Do not ask for the user's normal mailbox password, OAuth code, recovery code, or 2FA code in chat.
- Ask for an app password, authorization code, client password, or Bridge-generated password only when it is actually needed to connect and there is no better secret-entry surface.
- If the user provides a secret in chat, do not repeat or quote it. Acknowledge receipt generically, such as "收到授权码，我会只用于本次连接测试".
- Never store, test, or route a naked authorization code/app password. The mailbox address is required unless it is already known in the current flow.
- Do not write secrets into arbitrary files, screenshots, summaries, issue bodies, commits, docs, or logs.
- The only file-based secret store allowed by this skill is the dedicated encrypted plugin auth store used by `scripts/mail_cli.py auth-save`: sandbox `/mnt/agents/.user/auth/email`, local default `~/.kimi-work/auth/email`, or an explicit `EMAIL_AUTH_ROOT` override. The store can contain many mailbox authorization codes, one per email address. `accounts.json` must contain non-secret metadata only; encrypted authorization codes live under `secrets/*.enc`.
- `auth-save`, `auth-delete`, `auth-clear`, and `auth-restore` serialize writes with a store lock. Still avoid launching multiple mailbox save operations in parallel against the same auth root; one mailbox at a time is the safe pattern.
- If testing a connection, prefer a secure secret input, local credential store, environment variable, or user-provided app UI field when available.
- Treat app passwords and Chinese "授权码" as password-equivalent secrets.
- Use the same authorization code/app password for IMAP and SMTP unless the provider says separate client passwords are required.
- After a one-off manual test using a chat-provided secret, recommend that the user revoke/regenerate it if they do not intend to keep the integration active.
- Prefer provider OAuth when the product supports it, especially for Gmail, Outlook.com, Microsoft 365, Yahoo, and enterprise Microsoft tenants.
- Explain that many providers require 2FA before app passwords appear.
- Warn that enterprise admins can disable IMAP, app passwords, SMTP AUTH, or legacy clients even when the public provider supports them.

## Workflow

1. At the start of a new conversation or after sandbox replacement, run `scripts/mail_cli.py auth-check` before asking the user for a new authorization code. If direct filesystem access is available, check non-secret metadata under both `/mnt/agents/.user/auth/email` and `~/.kimi-work/auth/email`. Use `auth-restore` only when the store needs migration/repair or when you deliberately need to verify that encrypted secrets can be decrypted.
2. If saved credentials exist and are usable, offer the saved mailbox list first. If none exist, say this looks like first-time binding and continue.
3. Ask the provider question if missing.
4. Resolve the provider from the user's answer or email domain.
5. Return the provider-specific login/settings link and click path before discussing ports, CLI, or server settings.
6. Read `references/provider-catalog.md` and select the matching entry.
7. If the provider is unsupported or special, say so early:
   - Proton Mail: use Proton Mail Bridge; no direct public IMAP login.
   - Tuta/Tutanota: no standard IMAP/POP/SMTP access.
   - Microsoft 365 tenants: OAuth is often required; Basic Auth/app-password IMAP may be disabled by admin policy.
8. Give a short "do this now" checklist for generating the provider-specific secret.
9. If credentials are required next, ask for the safest available handoff method. Always ask for the mailbox address together with the generated authorization code/app password unless the address is already known. If chat handoff is unavoidable, ask for only the mailbox address plus generated code, never the login password.
10. If the user asks to disconnect one mailbox, run `auth-delete --email ... --confirm-delete yes`. If the user uninstalls/disconnects the Email plugin or asks to clear all Email credentials, actively run `auth-clear --confirm-delete yes` or have the host delete `/mnt/agents/.user/auth/email`; do not rely on an implicit uninstall hook unless the host confirms one exists.
11. If there is a connection failure, troubleshoot with the checklist below.

## CLI Operations

Use `scripts/mail_cli.py` when this agent needs to actually connect to IMAP/SMTP after the user supplies a generated app password, authorization code, client password, or Bridge password. Read `references/cli.md` for command examples.

The CLI supports:

- `providers`: list built-in provider profiles.
- `profile`: infer IMAP/SMTP settings and setup links for an email address.
- `auth-path`: show whether the run is using sandbox auth storage or local Work storage.
- `auth-check`: read-only saved-account preflight for new conversations; does not decrypt, migrate, or write files.
- `auth-restore`: migrate/repair legacy saved accounts and verify encrypted secret decryptability.
- `auth-save`: save one mailbox's generated app password/authorization code into the Email plugin auth store without printing it.
- `auth-list`: list saved mailboxes without printing authorization codes.
- `auth-env`: print non-secret connection environment values for a saved mailbox.
- `auth-delete`: delete one or all saved mailbox credentials.
- `auth-clear`: delete the whole Email plugin auth directory for plugin uninstall/disconnect.
- These mutation commands take a lock so simultaneous saves or deletes do not clobber `accounts.json`.
- `imap-test`: verify IMAP login and folder visibility.
- `imap-list`: list folders.
- `imap-search`: search messages with IMAP SEARCH criteria.
- `imap-recent`: search recent messages by day window.
- `imap-fetch`: fetch message headers or text body by UID.
- `imap-mark-read`: mark UIDs as read; requires `--confirm-write yes`.
- `imap-move`: move UIDs if the server supports IMAP MOVE; requires `--confirm-write yes`.
- `smtp-test`: verify SMTP login.
- `smtp-send`: send mail; requires `--confirm-send yes`.

Put secrets in environment variables, especially `MAIL_PASSWORD`, or save them with `auth-save`. Never put authorization codes directly in command-line flags.

## Troubleshooting

Use these quick checks before deeper debugging:

- `Authentication failed`: wrong credential type; use app password/authorization code/client password instead of the normal login password.
- `IMAP disabled`: the user enabled SMTP/POP but not IMAP, or enterprise admin blocked IMAP.
- `SMTP/send failed`: SMTP service is disabled, SMTP AUTH is blocked, the wrong port/TLS mode is used, or the provider requires the same generated authorization code instead of the normal password.
- `2FA required`: app passwords may be hidden until 2FA is enabled.
- `Too many login attempts`: wait, unlock account in provider security center, or revoke/regenerate the app password.
- `Outlook/Microsoft 365 failure`: check whether the app supports OAuth; tenant may block Basic Auth or SMTP AUTH.
- `Gmail failure`: check "Forwarding and POP/IMAP" settings, Google Workspace admin policy, and app password availability.
- `QQ/163/Sina/Sohu failure`: regenerate the authorization code and confirm IMAP/SMTP service is enabled in webmail settings.
- `Custom domain failure`: confirm the provider from MX records and use that provider's server names, not just `imap.domain.com`.

## References

- `references/provider-catalog.md`: provider instructions, settings paths, server names, and source links.
- `references/onboarding-playbook.md`: beginner-friendly user-facing onboarding scripts.
- `references/cli.md`: CLI commands for IMAP/SMTP testing and mailbox operations.
- `references/tool-contract.md`: recommended mailbox tool contract if wrapping this skill as MCP or product tools.
