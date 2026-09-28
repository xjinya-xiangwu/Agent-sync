# CLI Operations

Use `scripts/mail_cli.py` when the agent needs to actually operate a mailbox after onboarding. It uses only Python standard-library modules.

These examples work from the Email skill folder, where `scripts/mail_cli.py` is bundled. In an installed Email plugin, also try the plugin-root launcher first: `plugins/managed/email/scripts/mail_cli.py`. If that launcher is absent, use the bundled skill script at `plugins/managed/email/skills/email-imap-onboarding/scripts/mail_cli.py`. Desktop/package caches can expose the same layout under `plugin-packages/email`. In Kimi Work/local Desktop, if shell quoting around `Application Support` paths fails, also try the no-space mirror `~/.kimi-work/plugins/managed/email/scripts/mail_cli.py` when it exists. If a managed plugin directory is not present but this skill is loaded, do not conclude the CLI is unavailable until you have checked the current skill bundle path.

Never put passwords, app passwords, authorization codes, or client passwords directly in the command line. Put them in an environment variable so they do not appear in shell history.

## Environment

Set these values before running commands:

```bash
export MAIL_USERNAME="user@example.com"
export IMAP_HOST="imap.example.com"
export IMAP_PORT="993"
export SMTP_HOST="smtp.example.com"
export SMTP_PORT="465"
read -s MAIL_PASSWORD
export MAIL_PASSWORD
```

`MAIL_PASSWORD` should be the provider-generated app password, authorization code, client password, or Bridge password, not the normal login password.

## Persistent Auth Store

Use the persistent auth store when the mailbox should remain available across new conversations or sandbox restarts.

- Kimi main-site sandbox: `/mnt/agents/.user/auth/email`
- Kimi Work / local default: `~/.kimi-work/auth/email`
- Override root when needed: `EMAIL_AUTH_ROOT=/some/root`; the CLI will use `/some/root/email`

The subdirectory name must be `email`, matching the plugin manifest name. This gives the host a stable cleanup target for all Email credentials. The current plugin manifest has no uninstall lifecycle hook, so do not assume uninstall automatically runs this CLI; call `auth-clear --confirm-delete yes` from the product/agent uninstall or disconnect flow, or have the host delete the auth directory directly. The CLI uses the same sandbox/local distinction as the CLI-plugin auth convention: if `/mnt/agents/.user/auth` exists, treat the run as a Kimi main-site sandbox; otherwise use the Work/local fallback. Auth store location is independent from plugin file location. Only write to the auth directory selected by `auth-path`; checking both supported auth directories should be read-only metadata inspection.

Mutating commands (`auth-save`, `auth-delete`, `auth-clear`, `auth-restore`) serialize on a store lock in the auth root, so two save flows should queue rather than overwrite each other. Still prefer one mailbox save at a time.

`accounts.json` stores non-secret account metadata only. Authorization codes/app passwords are encrypted into `secrets/*.enc` with an auth-dir `master.key`. Do not read or print either file in chat.

Check where credentials will be saved:

```bash
python3 scripts/mail_cli.py auth-path
```

At the start of a new conversation, check whether the user already has saved mailboxes before asking for a new authorization code:

```bash
python3 scripts/mail_cli.py auth-check
```

`auth-check` is the safe onboarding preflight. It reads non-secret metadata and verifies that the expected encrypted secret files exist, but it does not decrypt, migrate, or write files.
If `auth-check` reports `store_drift` or a non-zero `orphan_secret_count`, the `secrets/` directory contains encrypted files that are not referenced by `accounts.json`; re-save the missing mailbox metadata or run `auth-restore` if you are intentionally repairing legacy records.

Use `auth-restore` only when you intentionally need to migrate/repair the store or verify that encrypted secrets can be decrypted:

```bash
python3 scripts/mail_cli.py auth-restore
```

If direct filesystem access is available and the runtime boundary permits it, also check whether non-secret account metadata exists in either supported Email auth directory before calling this a first-time bind:

```bash
python3 scripts/mail_cli.py auth-path
# Kimi main-site sandbox: /mnt/agents/.user/auth/email
# Kimi Work/local fallback: ~/.kimi-work/auth/email
```

Save one mailbox authorization code. Do not put the code directly in the command line:

```bash
export MAIL_USERNAME="123456@qq.com"
read -s MAIL_PASSWORD
export MAIL_PASSWORD
python3 scripts/mail_cli.py auth-save --email "$MAIL_USERNAME"
unset MAIL_PASSWORD
```

`auth-save` always requires the mailbox address. If the user provided only an authorization code/app password, ask for the full mailbox address before saving or testing it.

For a custom/enterprise domain, include the provider or exact hosts from the webmail settings:

```bash
export MAIL_USERNAME="user@example.com"
read -s MAIL_PASSWORD
export MAIL_PASSWORD
python3 scripts/mail_cli.py auth-save \
  --email "$MAIL_USERNAME" \
  --provider custom \
  --imap-host imap.example.com \
  --imap-port 993 \
  --imap-security ssl \
  --smtp-host smtp.example.com \
  --smtp-port 465 \
  --smtp-security ssl
unset MAIL_PASSWORD
```

List saved mailboxes without printing secrets:

```bash
python3 scripts/mail_cli.py auth-list
```

Use a saved mailbox. If `MAIL_PASSWORD` is not set, the CLI loads the stored authorization code for `MAIL_USERNAME`:

```bash
export MAIL_USERNAME="123456@qq.com"
python3 scripts/mail_cli.py imap-test
python3 scripts/mail_cli.py smtp-test
```

Export non-secret connection values for a saved mailbox:

```bash
python3 scripts/mail_cli.py auth-env --email 123456@qq.com --shell
```

Delete saved credentials when the user asks to disconnect one mailbox:

```bash
python3 scripts/mail_cli.py auth-delete --email 123456@qq.com --confirm-delete yes
```

Clear the whole Email auth directory when the user uninstalls/disconnects the plugin or asks to remove all Email credentials. This command performs the deletion only when it is explicitly invoked:

```bash
python3 scripts/mail_cli.py auth-clear --confirm-delete yes
```

## Provider Profiles

List built-in profiles:

```bash
python3 scripts/mail_cli.py providers
```

Infer settings from an address:

```bash
python3 scripts/mail_cli.py profile --email user@qq.com --shell
```

For common personal providers, commands can infer hosts from `MAIL_USERNAME`:

```bash
export MAIL_USERNAME="123456@qq.com"
read -s MAIL_PASSWORD
export MAIL_PASSWORD
python3 scripts/mail_cli.py imap-test
python3 scripts/mail_cli.py smtp-test
```

For enterprise/custom domains, either set `MAIL_PROVIDER` to a supported profile such as `exmail`, or set `IMAP_HOST`/`SMTP_HOST` directly from the provider's webmail setup page.

## Read Mail With IMAP

Test login and basic folder access:

```bash
python3 scripts/mail_cli.py imap-test
```

List folders:

```bash
python3 scripts/mail_cli.py imap-list
```

Search messages:

```bash
python3 scripts/mail_cli.py imap-search --folder INBOX --criteria 'UNSEEN SINCE 12-Jun-2026' --limit 10
```

Search recent messages:

```bash
python3 scripts/mail_cli.py imap-recent --folder INBOX --days 3 --limit 20
```

Fetch headers only:

```bash
python3 scripts/mail_cli.py imap-fetch --folder INBOX --uid 12345
```

Fetch text body:

```bash
python3 scripts/mail_cli.py imap-fetch --folder INBOX --uid 12345 --body --max-bytes 20000
```

## Change Mailbox State

Write operations require explicit confirmation:

```bash
python3 scripts/mail_cli.py imap-mark-read --folder INBOX --uid 12345 --confirm-write yes
python3 scripts/mail_cli.py imap-move --folder INBOX --uid 12345 --target-folder Archive --confirm-write yes
```

Avoid destructive operations such as permanent delete unless the user explicitly asks and the product has a confirmation policy.

## Send Mail With SMTP

Test SMTP login:

```bash
python3 scripts/mail_cli.py smtp-test
```

Send a message only after explicit user intent:

```bash
python3 scripts/mail_cli.py smtp-send \
  --to recipient@example.com \
  --subject "Test" \
  --text "Hello" \
  --confirm-send yes
```

If the SMTP host uses STARTTLS on port 587:

```bash
export SMTP_PORT="587"
python3 scripts/mail_cli.py smtp-test --smtp-security starttls
```

## Common Provider Examples

QQ Mail:

```bash
export MAIL_USERNAME="123456@qq.com"
export IMAP_HOST="imap.qq.com"
export SMTP_HOST="smtp.qq.com"
export SMTP_PORT="465"
read -s MAIL_PASSWORD
export MAIL_PASSWORD
python3 scripts/mail_cli.py imap-test
python3 scripts/mail_cli.py smtp-test
```

Gmail:

```bash
export MAIL_USERNAME="user@gmail.com"
export IMAP_HOST="imap.gmail.com"
export SMTP_HOST="smtp.gmail.com"
export SMTP_PORT="465"
read -s MAIL_PASSWORD
export MAIL_PASSWORD
python3 scripts/mail_cli.py imap-test
python3 scripts/mail_cli.py smtp-test
```

Outlook / Microsoft 365 SMTP normally uses STARTTLS:

```bash
export MAIL_USERNAME="user@outlook.com"
export IMAP_HOST="outlook.office365.com"
export SMTP_HOST="smtp.office365.com"
export SMTP_PORT="587"
read -s MAIL_PASSWORD
export MAIL_PASSWORD
python3 scripts/mail_cli.py imap-test
python3 scripts/mail_cli.py smtp-test --smtp-security starttls
```
