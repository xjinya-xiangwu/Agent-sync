---
name: gateway-research-sources
description: External references used for the access-gateway best-practice
  research (LiteLLM, Inspect AI, Langfuse, vivaria, MCP guidance)
metadata:
  node_type: memory
  type: reference
  originSessionId: sess_54bc33e8-126e-4097-b8c9-26e25a4ba906
---

Sources gathered 2026-09-20 for the gateway refactor design ([[testing-platform-gateway-refactor]]):

- LiteLLM virtual keys: https://docs.litellm.ai/docs/proxy/virtual_keys — max_budget, budget_duration, rpm/tpm_limit, max_parallel_requests, models allowlist, rotation with grace period, block/unblock vs revoke, default/upperbound_key_generate_params.
- Inspect AI (UK AISI): https://inspect.aisi.org.uk/models.html and /providers.html — `provider/model` naming, `openai-api/<provider>/<model>` generic OpenAI-compatible convention, `<NAME>_API_KEY`/`<NAME>_BASE_URL` env derivation, model roles.
- promptfoo providers: https://www.promptfoo.dev/docs/providers/openai — apiBaseUrl/apiKey config, openai-compliant generic provider, env fallbacks.
- Langfuse: https://langfuse.com/docs/api-authentication — PK (trace-ingest, restricted) vs SK (full) project-scoped keys; https://langfuse.com/docs/tracing-features — trace/session observability.
- METR vivaria: https://github.com/METR/vivaria — agent repo+entrypoint registration, controlled task containers, out-of-band trajectory capture.
- MCP authorization guidance: https://modelcontextprotocol.io + Microsoft Learn MCP gateway docs — OAuth 2.1+PKCE, scope-based tool authorization, deny-by-default tool filtering, token audience restriction.
