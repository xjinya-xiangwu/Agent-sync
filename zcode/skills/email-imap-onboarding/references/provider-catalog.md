# IMAP / SMTP Provider Catalog

Use this catalog after identifying the mailbox provider. Provider UIs change often; if a setting path fails, keep the server settings as a clue and ask the user to search the provider's webmail settings for "IMAP", "SMTP", "POP/IMAP", "third-party clients", "app password", "authorization code", "client password", or "授权码".

Checked: 2026-06-12.

## Onboarding Defaults

- Ask for the provider first; if the user gives an email address, infer from its domain.
- Give the login link first, then the exact settings path.
- Prefer secure credential fields. If the agent must receive a generated app password/authorization code in chat to operate, treat it as a secret and do not echo or log it.
- For enterprise/custom domains, tell the user that admin policy may disable IMAP even if the backend normally supports it.
- If the product supports OAuth, prefer OAuth over raw IMAP credentials.
- SMTP is needed for sending. In most providers, the same generated app password/authorization code is used for IMAP and SMTP; if sending fails, check SMTP AUTH, port/TLS mode, and admin policy.

## Provider Table

| Provider | Domains / aliases | Login or settings link | Where to find IMAP / app password | IMAP settings | Credential notes |
|---|---|---|---|---|---|
| Gmail | `gmail.com`, `googlemail.com` | https://mail.google.com/ and https://myaccount.google.com/security | Gmail: gear -> See all settings -> Forwarding and POP/IMAP. Google Account: Security -> 2-Step Verification -> App passwords. | `imap.gmail.com`, port `993`, SSL/TLS | OAuth preferred. App passwords require 2FA and may be disabled by Workspace admin. |
| Google Workspace | custom domains on Google | https://mail.google.com/ and admin/user Google Account security pages | Same as Gmail for users; admin may need to allow IMAP and app passwords. | `imap.gmail.com`, port `993`, SSL/TLS | Ask whether the organization allows IMAP/app passwords. OAuth is usually best. |
| Outlook.com / Hotmail / Live / MSN | `outlook.com`, `hotmail.com`, `live.com`, `msn.com` | https://outlook.live.com/mail/ | Outlook web: Settings -> Mail -> Sync email / Forwarding and IMAP, depending on UI. | `outlook.office365.com`, port `993`, SSL/TLS | OAuth preferred. App passwords may work only for accounts and apps that still allow password auth. |
| Microsoft 365 / Exchange Online | organization domains hosted by Microsoft | https://outlook.office.com/mail/ | Outlook web settings or tenant admin policy. User may not see usable IMAP if admin blocked it. | `outlook.office365.com`, port `993`, SSL/TLS | Modern Auth/OAuth is often required. Basic Auth for IMAP may be disabled by tenant policy. |
| Yahoo Mail | `yahoo.com`, `ymail.com`, `rocketmail.com` | https://mail.yahoo.com/ and https://login.yahoo.com/account/security | Account Security -> Generate app password, then use Yahoo's third-party client settings. | `imap.mail.yahoo.com`, port `993`, SSL/TLS | Use an app password for third-party IMAP clients. |
| AOL Mail | `aol.com` | https://mail.aol.com/ and https://login.aol.com/account/security | Account Security -> Generate app password. | `imap.aol.com`, port `993`, SSL/TLS | AOL is Yahoo-owned; third-party clients usually need an app password. |
| iCloud Mail | `icloud.com`, `me.com`, `mac.com` | https://www.icloud.com/mail/ and https://account.apple.com/ | Apple Account -> Sign-In and Security -> App-Specific Passwords. | `imap.mail.me.com`, port `993`, SSL/TLS | Use an app-specific password, not the Apple Account password. |
| Proton Mail | `proton.me`, `protonmail.com`, paid custom domains | https://mail.proton.me/ and https://proton.me/mail/bridge | Install Proton Mail Bridge, sign in there, then copy the local IMAP settings shown by Bridge. | Bridge local host/ports vary, commonly localhost IMAP plus Bridge-generated credentials | No direct public IMAP endpoint for normal clients. Requires Bridge; availability depends on Proton plan. |
| Tuta / Tutanota | `tuta.com`, `tutanota.com`, custom domains on Tuta | https://app.tuta.com/ | No IMAP/POP/SMTP settings page for standard clients. | Not supported | Tell the user to use Tuta apps/web unless their product has a dedicated Tuta integration. |
| Zoho Mail | `zoho.com`, custom domains on Zoho | https://mail.zoho.com/ and https://accounts.zoho.com/ | Zoho Mail Settings -> Mail Accounts -> IMAP Access. Zoho Account Security -> App Passwords if MFA is enabled. | `imap.zoho.com`, port `993`, SSL/TLS. Region-specific accounts may use `imap.zoho.eu`, `imap.zoho.in`, etc. | Enable IMAP in mailbox settings. Use app password when MFA is on. |
| Fastmail | `fastmail.com`, many Fastmail-hosted domains, custom domains | https://app.fastmail.com/ and https://app.fastmail.com/settings/security | Settings -> Privacy & Security -> App passwords. | `imap.fastmail.com`, port `993`, SSL/TLS | Create an app password for the mail client. |
| GMX | `gmx.com`, `gmx.net`, regional GMX domains | https://www.gmx.com/ or regional webmail | Settings -> POP3 & IMAP -> enable access. | `imap.gmx.com`, port `993`, SSL/TLS | Some regions require enabling POP3/IMAP before login works. |
| mail.com | `mail.com` and mail.com vanity domains | https://www.mail.com/ | Settings -> POP3 & IMAP -> enable access. | `imap.mail.com`, port `993`, SSL/TLS | Use the full email address as username. |
| Yandex Mail | `yandex.com`, `yandex.ru`, custom domains | https://mail.yandex.com/ and https://id.yandex.com/security | Mail settings -> Email clients -> enable IMAP. Security -> app passwords if 2FA/password restrictions are enabled. | `imap.yandex.com`, port `993`, SSL/TLS | App password is safer and often required. |
| Mail.ru | `mail.ru`, `inbox.ru`, `list.ru`, `bk.ru` | https://e.mail.ru/ | Mail.ru Account Security -> passwords for external apps; mail settings for client access. | `imap.mail.ru`, port `993`, SSL/TLS | Use an app password when account security requires it. |
| Naver Mail | `naver.com` | https://mail.naver.com/ | Mail settings -> POP3/IMAP settings -> enable IMAP. | `imap.naver.com`, port `993`, SSL/TLS | Use the full Naver ID/email format requested by the client page. |
| Daum / Kakao Mail | `daum.net`, Kakao-hosted mail | https://mail.daum.net/ | Mail settings -> IMAP/POP3 settings. | `imap.daum.net`, port `993`, SSL/TLS | Verify current app-password/security requirements in Kakao account settings. |
| Seznam Email | `seznam.cz`, `email.cz`, `post.cz` | https://email.seznam.cz/ | Account/mail settings -> POP3/IMAP access. | `imap.seznam.cz`, port `993`, SSL/TLS | May require enabling IMAP and confirming security prompts. |
| QQ Mail | `qq.com`, `foxmail.com` personal QQ mail | Mail login: https://mail.qq.com/; authorization-code page: https://wx.mail.qq.com/account | 账号与安全 -> 安全设置 -> POP3/IMAP/SMTP/Exchange/CardDAV 服务 -> 开启服务 -> 生成授权码. | `imap.qq.com`, port `993`, SSL/TLS | Use 授权码 as the password. Do not use the QQ login password. |
| Tencent Exmail / WeCom Mail | enterprise domains on Tencent | https://exmail.qq.com/ | Webmail settings -> client settings / POP3/IMAP/SMTP service -> generate client password or authorization code. | `imap.exmail.qq.com`, port `993`, SSL/TLS | Admin can disable client access. Use the enterprise mailbox's client password/授权码. |
| NetEase 163 Mail | `163.com` | https://mail.163.com/ | 设置 -> POP3/SMTP/IMAP -> enable IMAP/SMTP -> generate 授权码. | `imap.163.com`, port `993`, SSL/TLS | Use 授权码 as password. |
| NetEase 126 Mail | `126.com` | https://mail.126.com/ | 设置 -> POP3/SMTP/IMAP -> enable IMAP/SMTP -> generate 授权码. | `imap.126.com`, port `993`, SSL/TLS | Use 授权码 as password. |
| NetEase yeah.net | `yeah.net` | https://www.yeah.net/ | 设置 -> POP3/SMTP/IMAP -> enable IMAP/SMTP -> generate 授权码. | `imap.yeah.net`, port `993`, SSL/TLS | Use 授权码 as password. |
| NetEase Enterprise Mail / NetEase Cloud Mail | enterprise domains on NetEase, including school/company mail hosted under `qiye.163.com` webmail hosts; PKU/北大 student mail such as `stu.pku.edu.cn` can use this UI | https://qiye.163.com/ or the organization's NetEase webmail host, such as `https://mailshz.qiye.163.com/` | Newer PKU/NetEase enterprise UI: top `设置` -> `账号与安全` -> `客户端设置` -> `进入设置` -> set collection time and generate the dedicated authorization password. If not found, try top `客户端`, `设置` -> `系统设置` -> `客户端设置`, or search for `授权码管理` / `专属授权密码` / `客户端设置`. If already logged in, some tenants expose `https://<webmail-host>/static/commonweb/authcode.html`; example: `https://mailshz.qiye.163.com/static/commonweb/authcode.html`. | Commonly provider-specific; ask admin or read webmail client settings | Use 授权码/专属授权密码 as password. Do not copy `sid`, `uid`, or other session query parameters into instructions. Admin policy controls access and server names. |
| Sina Mail | `sina.com`, `sina.cn` | https://mail.sina.com.cn/ | 邮箱设置 -> 账户 / 客户端 POP/IMAP/SMTP -> enable IMAP and create client authorization if offered. | Commonly `imap.sina.com`, port `993`, SSL/TLS | Sina UI varies; if auth fails, search settings for 授权码/客户端授权码. |
| Sohu Mail | `sohu.com` | https://mail.sohu.com/ | 设置 -> POP3/SMTP/IMAP or 客户端设置 -> enable IMAP. | Commonly `imap.sohu.com`, port `993`, SSL/TLS | Verify current server/settings in the Sohu client setup page. |
| Aliyun / Alibaba Mail | Aliyun personal or enterprise mail, custom domains | https://mail.aliyun.com/ and https://qiye.aliyun.com/ | Webmail settings -> account/security/client login password. Enterprise admin may need to permit client access. | Enterprise commonly `imap.qiye.aliyun.com`, port `993`, SSL/TLS | Use third-party client password/authorization if required; admin policy may block IMAP. |
| Coremail-hosted mail | universities, companies, local Chinese organizations | provider webmail URL varies | Webmail 设置 -> 客户端设置 / POP3/IMAP/SMTP; otherwise ask admin. | Often `imap.<domain>` or `mail.<domain>`, port `993`, SSL/TLS, but verify in webmail | No universal host. Treat as custom domain. |
| China Mobile 139 Mail | `139.com` | https://mail.10086.cn/ | 设置 / 客户端设置 -> POP/IMAP/SMTP; generate authorization/client password if requested. | Commonly `imap.139.com`, port `993`, SSL/TLS | Verify in settings because account type/region can vary. |
| China Telecom 189 Mail | `189.cn` | https://mail.189.cn/ | 设置 / 客户端设置 -> POP/IMAP/SMTP; generate authorization/client password if requested. | Commonly `imap.189.cn`, port `993`, SSL/TLS | Verify in settings because account type/region can vary. |
| Xfinity / Comcast | `comcast.net` | https://connect.xfinity.com/ | Xfinity email settings/security -> allow third-party email client access. | `imap.comcast.net`, port `993`, SSL/TLS | Third-party access can be disabled in account security settings. |
| AT&T Mail | `att.net`, `sbcglobal.net`, `bellsouth.net`, legacy AT&T domains | https://currently.att.yahoo.com/ | AT&T profile/security -> create Secure Mail Key. | `imap.mail.att.net`, port `993`, SSL/TLS | Use Secure Mail Key as password for non-OAuth clients. |
| Spectrum / Charter | `charter.net`, `spectrum.net`, legacy cable domains | https://webmail.spectrum.net/ | Spectrum email settings/help -> server settings. | Commonly `mobile.charter.net`, port `993`, SSL/TLS | Regional/legacy domains vary; verify with Spectrum server settings. |
| Rackspace Email | hosted domains on Rackspace | https://apps.rackspace.com/ | Webmail settings or Rackspace control panel -> client setup. | `secure.emailsrvr.com`, port `993`, SSL/TLS | Use mailbox password unless account security policy says otherwise. |
| IONOS Mail | hosted domains on IONOS | https://mail.ionos.com/ | IONOS help/control panel -> email client setup. | `imap.ionos.com`, port `993`, SSL/TLS | Use mailbox credentials or provider-generated app password if security requires. |
| cPanel / generic hosting mail | custom domains | hosting control panel or webmail | cPanel -> Email Accounts -> Connect Devices / Set Up Mail Client. | Usually `mail.<domain>`, port `993`, SSL/TLS, but use cPanel's exact values | Ask for hosting provider or cPanel client setup screen. |

## Outgoing SMTP Settings

Use SMTP only when the user/product needs to send mail. For read-only onboarding, IMAP is enough.

| Provider | SMTP settings | Notes |
|---|---|---|
| Gmail / Google Workspace | `smtp.gmail.com`, port `465` SSL/TLS or `587` STARTTLS | OAuth preferred. App passwords require 2FA and may be disabled by Workspace admin. |
| Outlook.com / Microsoft 365 | `smtp.office365.com`, port `587` STARTTLS | Modern Auth/OAuth is often required; tenant may disable SMTP AUTH. |
| Yahoo Mail | `smtp.mail.yahoo.com`, port `465` SSL/TLS or `587` STARTTLS | Use Yahoo app password for password-based clients. |
| AOL Mail | `smtp.aol.com`, port `465` SSL/TLS or `587` STARTTLS | Use app password for password-based clients. |
| iCloud Mail | `smtp.mail.me.com`, port `587` STARTTLS | Use Apple app-specific password. |
| Proton Mail | Use Proton Mail Bridge's local SMTP settings | No direct public SMTP endpoint for normal clients. |
| Tuta / Tutanota | Not supported | Standard SMTP is not available. |
| Zoho Mail | `smtp.zoho.com`, port `465` SSL/TLS or `587` STARTTLS; regional accounts may vary | Use app password when MFA is on. |
| Fastmail | `smtp.fastmail.com`, port `465` SSL/TLS or `587` STARTTLS | Use app password. |
| GMX | `smtp.gmx.com`, port `465` SSL/TLS or `587` STARTTLS | Enable POP3/IMAP/SMTP access if the account requires it. |
| mail.com | `smtp.mail.com`, port `465` SSL/TLS or `587` STARTTLS | Use full email address as username. |
| Yandex Mail | `smtp.yandex.com`, port `465` SSL/TLS | Use app password when required. |
| Mail.ru | `smtp.mail.ru`, port `465` SSL/TLS | Use app password when required. |
| Naver Mail | `smtp.naver.com`, port `465` SSL/TLS or `587` STARTTLS | Confirm current settings in Naver mail client setup. |
| Daum / Kakao Mail | `smtp.daum.net`, port `465` SSL/TLS | Confirm current settings in Kakao/Daum client setup. |
| Seznam Email | `smtp.seznam.cz`, port `465` SSL/TLS or `587` STARTTLS | Confirm current settings in webmail. |
| QQ Mail | `smtp.qq.com`, port `465` SSL/TLS; `587` STARTTLS may work when required by the client | Use QQ 授权码 as the SMTP password. |
| Tencent Exmail / WeCom Mail | `smtp.exmail.qq.com`, port `465` SSL/TLS | Admin can disable SMTP/client access. |
| NetEase 163 Mail | `smtp.163.com`, port `465` SSL/TLS | Use 授权码 as password. |
| NetEase 126 Mail | `smtp.126.com`, port `465` SSL/TLS | Use 授权码 as password. |
| NetEase yeah.net | `smtp.yeah.net`, port `465` SSL/TLS | Use 授权码 as password. |
| NetEase Enterprise Mail / NetEase Cloud Mail | Read the webmail client settings; commonly enterprise-specific | Use 授权码 as password. Avoid guessing if the webmail shows exact SMTP host/port. |
| Sina Mail | Commonly `smtp.sina.com`, port `465` SSL/TLS | Verify in Sina client settings. |
| Sohu Mail | Commonly `smtp.sohu.com`, port `465` SSL/TLS | Verify in Sohu client settings. |
| Aliyun / Alibaba Mail | Enterprise commonly `smtp.qiye.aliyun.com`, port `465` SSL/TLS | Admin policy may block SMTP. |
| Coremail-hosted mail | Often `smtp.<domain>` or `mail.<domain>`, port `465` SSL/TLS or `587` STARTTLS | Use the webmail client setup page or ask admin. |
| China Mobile 139 Mail | Commonly `smtp.139.com`, port `465` SSL/TLS | Verify in webmail settings. |
| China Telecom 189 Mail | Commonly `smtp.189.cn`, port `465` SSL/TLS | Verify in webmail settings. |
| Xfinity / Comcast | `smtp.comcast.net`, port `587` STARTTLS | Third-party access can be disabled in account security settings. |
| AT&T Mail | `smtp.mail.att.net`, port `465` SSL/TLS | Use Secure Mail Key. |
| Spectrum / Charter | Commonly `mobile.charter.net`, port `587` STARTTLS | Regional/legacy domains vary. |
| Rackspace Email | `secure.emailsrvr.com`, port `465` SSL/TLS or `587` STARTTLS | Use mailbox credentials unless policy says otherwise. |
| IONOS Mail | `smtp.ionos.com`, port `587` STARTTLS | Use mailbox credentials or provider-generated app password if required. |
| cPanel / generic hosting mail | Usually `mail.<domain>`, port `465` SSL/TLS or `587` STARTTLS | Use cPanel's Connect Devices values. |

## Unsupported or Special Cases

- Tuta/Tutanota: no standard IMAP/POP/SMTP. Do not keep trying server guesses.
- Proton Mail: use Proton Mail Bridge. The Bridge app shows local IMAP/SMTP host, port, username, and generated password.
- Microsoft 365: many tenants reject password-based IMAP even with correct server settings. Use OAuth-capable integration where possible.
- Gmail/Google Workspace: if app passwords are missing, check 2FA and Workspace admin policy.
- Enterprise mailboxes: public provider docs are not enough; admin settings can override everything.

## Source Links

- Gmail IMAP setup: https://support.google.com/mail/answer/7126229
- Google app passwords: https://support.google.com/accounts/answer/185833
- Microsoft Outlook.com IMAP settings: https://support.microsoft.com/en-us/office/pop-imap-and-smtp-settings-for-outlook-com-d088b986-291d-42b8-9564-9c414e2aa040
- Microsoft Exchange Online auth background: https://learn.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/deprecation-of-basic-authentication-exchange-online
- Yahoo third-party mail app settings: https://help.yahoo.com/kb/download-email-yahoo-mail-third-party-sln28681.html
- iCloud Mail server settings: https://support.apple.com/en-us/102525
- Apple app-specific passwords: https://support.apple.com/en-us/102654
- Zoho IMAP access: https://www.zoho.com/mail/help/imap-access.html
- Fastmail IMAP/SMTP settings: https://www.fastmail.help/hc/en-us/articles/1500000278342
- Proton Mail Bridge: https://proton.me/mail/bridge
- Tuta IMAP/POP/SMTP support note: https://tuta.com/support
- GMX IMAP settings: https://support.gmx.com/pop-imap/imap/serverdata.html
- mail.com IMAP settings: https://support.mail.com/pop-imap/imap/serverdata.html
- AOL IMAP settings: https://help.aol.com/articles/verizon-move-to-aol-mail-setting-up-your-new-aol-account-in-a-third-party-email-program-or-mobile-device-imap
- Yandex IMAP setup: https://yandex.com/support/mail/mail-clients/others.html
- QQ Mail account and authorization-code management: https://wx.mail.qq.com/account
- NetEase Enterprise Mail authorization-code page pattern: https://mailshz.qiye.163.com/static/commonweb/authcode.html
- Xfinity third-party email client access: https://www.xfinity.com/support/articles/email-client-programs-with-xfinity-email
- AT&T Secure Mail Key: https://www.att.com/support/article/email-support/KM1240308/
