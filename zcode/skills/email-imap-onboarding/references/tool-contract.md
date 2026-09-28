# Agent Tool Contract

Use this contract if the mailbox capability is wrapped as MCP tools, internal product tools, or another agent runtime API. Keep the tool layer higher level than raw IMAP commands, and keep credentials out of tool arguments after onboarding.

This contract intentionally uses a different shape from generic email MCP examples: namespace tools under `mailbox.*`, split read/write/send operations clearly, and require explicit confirmation tokens for state-changing actions.

## Account And Setup

`mailbox.resolve_settings`

Input:

```json
{
  "email": "user@example.com",
  "provider": "auto"
}
```

Output:

```json
{
  "provider": "qq",
  "imap": {"host": "imap.qq.com", "port": 993, "security": "ssl"},
  "smtp": {"host": "smtp.qq.com", "port": 465, "security": "ssl"},
  "credential_kind": "authorization_code",
  "setup_url": "https://wx.mail.qq.com/account",
  "notes": []
}
```

`mailbox.check_access`

Input:

```json
{
  "account_id": "mailbox_123",
  "mode": "imap|smtp|both"
}
```

Use this after credentials are stored in the runtime. The tool should return connection status and non-secret error messages only.

`mailbox.store_credential`

Input:

```json
{
  "email": "user@example.com",
  "provider": "qq",
  "credential_kind": "authorization_code",
  "credential": "<secret from secure input>",
  "imap": {"host": "imap.qq.com", "port": 993, "security": "ssl"},
  "smtp": {"host": "smtp.qq.com", "port": 465, "security": "ssl"}
}
```

Use a secure secret input surface when possible. If implemented on Kimi main-site sandbox, store under `/mnt/agents/.user/auth/email` so host cleanup can target all persisted mailbox credentials for the `email` plugin. Store only non-secret metadata in `accounts.json`; save authorization codes/app passwords as encrypted `secrets/*.enc` files. Return only non-secret account metadata.

The `email` field is required whenever a credential is stored. Do not accept, save, or test a bare authorization code/app password without a mailbox address. If the user has not already provided an address, the onboarding UI or agent prompt must ask for both the mailbox address and generated code together.

`mailbox.list_accounts`

Output should include email, provider, connection hosts, and whether a credential exists. Never return the credential.

`mailbox.delete_credential`

Input:

```json
{
  "email": "user@example.com",
  "confirm": "yes"
}
```

Delete one mailbox credential. A product may add "delete all" for plugin disconnect/uninstall flows.

`mailbox.clear_credentials`

Input:

```json
{
  "confirm": "yes"
}
```

Delete the entire Email plugin auth directory when the user uninstalls the plugin or asks to clear all Email credentials. Current plugin manifests do not guarantee an automatic uninstall hook; the product uninstall/disconnect flow should call this tool or delete `/mnt/agents/.user/auth/email` directly.

## Read Operations

`mailbox.list_folders`

Input:

```json
{"account_id": "mailbox_123"}
```

`mailbox.search_messages`

Input:

```json
{
  "account_id": "mailbox_123",
  "folder": "INBOX",
  "query": {
    "from": "sender@example.com",
    "subject": "invoice",
    "text": "keyword",
    "since": "2026-06-01",
    "before": "2026-06-12",
    "unread": true
  },
  "limit": 20
}
```

Return stable message IDs or IMAP UIDs plus headers. Do not fetch full bodies by default.

`mailbox.read_message`

Input:

```json
{
  "account_id": "mailbox_123",
  "folder": "INBOX",
  "message_id": "12345",
  "include_body": true,
  "max_bytes": 20000
}
```

## State-Changing Operations

Require explicit user intent and a confirmation token for these tools.

`mailbox.mark_seen`

```json
{
  "account_id": "mailbox_123",
  "folder": "INBOX",
  "message_ids": ["12345"],
  "seen": true,
  "confirm": "yes"
}
```

`mailbox.move_messages`

```json
{
  "account_id": "mailbox_123",
  "source_folder": "INBOX",
  "target_folder": "Archive",
  "message_ids": ["12345"],
  "confirm": "yes"
}
```

Avoid permanent delete in a default tool contract. Prefer moving to Trash, and require a second confirmation for permanent deletion if a product adds it.

## Send Operation

`mailbox.compose_send`

```json
{
  "account_id": "mailbox_123",
  "to": ["recipient@example.com"],
  "cc": [],
  "bcc": [],
  "subject": "Subject",
  "text": "Plain text body",
  "html": null,
  "attachments": [],
  "confirm": "yes"
}
```

Sending should require explicit user intent. If attachments are supported, allow only local file paths that the runtime can read, and surface filenames in confirmation text before sending.

## CLI Mapping

- `mailbox.resolve_settings` -> `scripts/mail_cli.py profile`
- `mailbox.store_credential` -> `scripts/mail_cli.py auth-save`
- `mailbox.list_accounts` -> `scripts/mail_cli.py auth-list`
- `mailbox.delete_credential` -> `scripts/mail_cli.py auth-delete`
- `mailbox.clear_credentials` -> `scripts/mail_cli.py auth-clear`
- `mailbox.check_access` -> `imap-test` and/or `smtp-test`
- `mailbox.list_folders` -> `imap-list`
- `mailbox.search_messages` -> `imap-search` or `imap-recent`
- `mailbox.read_message` -> `imap-fetch`
- `mailbox.mark_seen` -> `imap-mark-read`
- `mailbox.move_messages` -> `imap-move`
- `mailbox.compose_send` -> `smtp-send`

## Safety

- Store the app password/authorization code outside normal chat whenever possible.
- Never echo credential values in tool output.
- Do not include message bodies in search/list responses unless requested.
- Confirm before sending, moving, marking large batches, or any irreversible action.
- Log non-secret metadata only: provider, host, port, folder, UID/message ID, counts, and error classes.
