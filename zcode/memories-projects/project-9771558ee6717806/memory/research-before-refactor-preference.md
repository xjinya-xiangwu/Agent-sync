---
name: research-before-refactor-preference
description: User prefers external best-practice research and gap analysis
  before any code changes on refactors
metadata:
  node_type: memory
  type: feedback
  originSessionId: sess_54bc33e8-126e-4097-b8c9-26e25a4ba906
---

For the testing-platform gateway refactor the user explicitly said "先不要急着修改" — first survey external agent-evaluation platforms, then produce a best-practice-vs-current module/user-journey gap analysis, and only then touch code.

**Why:** They treat refactor requests as design-review-first tasks; premature edits would be rejected.

**How to apply:** On refactor/feature requests in this workspace, deliver a written gap analysis (module design + user journey comparison) and wait for approval before editing. Note: background research subagents failed here (EHOSTUNREACH to the subagent API) while main-session WebSearch/WebFetch worked — do web research inline. Related: [[testing-platform-gateway-refactor]]
