# Town ↔ Hermes Connector

Connect **Town** to your own **Hermes Agent** through MCP. Send a request, reuse the same Hermes session, and retrieve its response—even when it takes longer than a normal tool call.

This is Robbe Richman's Town-focused fork of [mlennie/hermes-mcp](https://github.com/mlennie/hermes-mcp), distributed under Apache-2.0. It is independently available from this repository; upstream pull-request acceptance is not required. It is unofficial and is not endorsed by Town or Hermes.

```text
You → Town → this connector → Hermes Agent
                                  ↓
                         configured tools or workers
```

## Start here

- **Not a coder?** Read the [plain-language guide](docs/non-coder-start-here.md).
- **Installing on Hostinger or Docker?** Follow the [Town setup guide](docs/town-hostinger.md).
- **Configuring Town's behavior?** Adapt the [routine template](docs/town-routine-template.md).
- **Checking whether it works?** Use the [verification checklist and limitations](docs/town-verification.md).
- **Updating an existing installation?** Follow the [upgrade guide](docs/upgrading.md).

## Get this version

Use this repository directly. Installing the package by name from PyPI does not select this fork.

```bash
git clone https://github.com/robertrichman/hermes-mcp.git town-hermes-connector
cd town-hermes-connector
```

Build the Docker image from this checkout using the setup guide. For a Python installation (Python 3.11+), use `pip install .` inside an appropriate virtual environment. The command remains `hermes-mcp`; existing module names and deployment settings are preserved.

The setup requires a working Hermes gateway, an HTTPS address, and Town access to custom MCP integrations. Installing this connector does not install or configure a software-development team.

## What is included

- Town connection through OAuth and Streamable HTTP.
- Stable session IDs forwarded to the Hermes gateway.
- Asynchronous requests with job IDs for later checks.
- Non-blocking gateway requests so the connector can answer status checks while waiting.
- SQLite job-result persistence with approximately 24-hour retention after terminal completion.
- Explicit unconfirmed outcomes for requests interrupted by a restart; no automatic replay.
- Hostinger/Docker deployment examples and a reusable Town routine.

These are connector capabilities. Correctness of Hermes's answers and successful execution of its tools require separate verification.

## Tools

| Tool | Purpose |
|---|---|
| `hermes_ask` | Send a request; reuse `session_id`, and use `async_mode=true` for slow or uncertain requests. |
| `hermes_check` | Read the existing bridge job without resending the instruction. |
| `hermes_cancel` | Cancel the bridge job; do not assume this stops downstream workers or reverses side effects. |
| `hermes_reset` | Administrative job-store reset; not a routine retry mechanism. |

The optional `toolsets` argument is ignored for compatibility. Configure available tools in Hermes itself.

## What “completed” means

Every async result includes `completion_scope: "gateway_response"`.

**Completed means Hermes returned a response.** It does not prove that a delegated worker started, tests passed, a preview exists, or the requested work is finished. Preserve the downstream tracking reference and verify through the system that actually records that work.

This connector does not supply Kanban tracking, a coding harness, QA, deployment credentials, or a preview service. Project-specific tools such as `the143_task_status` are not included.

## Known limits

- OAuth tokens remain in memory. After restarting the connector, Town may need reconnection. Persisted job results and OAuth tokens have different lifecycles.
- Keep the SQLite store on persistent storage. The Docker examples include a volume.
- Run one connector process per job store. Increasing Uvicorn workers is not a supported concurrency fix.
- The connector cannot keep a blocking Hermes gateway responsive; it only avoids blocking its own request loop.
- Reusing a session ID provides conversation continuity, not guaranteed memory accuracy or task deduplication.
- No promise of unattended software delivery is made. Read the [verification boundaries](docs/town-verification.md) before delegating work.

## Configuration and responsible use

See [the environment reference](.env.example), [deployment settings](deploy/hermes-mcp.env.example), and [threat model](THREAT_MODEL.md). Limit Hermes's tools and permissions to the intended use. Keep credentials private and approval boundaries explicit.

The underlying protocol may work with other MCP clients, but this fork's primary documentation and verification workflow focus on Town. No other client compatibility was retested for this documentation update.

## Attribution and contribution

Original bridge: [mlennie/hermes-mcp](https://github.com/mlennie/hermes-mcp). Town/Hostinger integration, documentation, and reliability changes are available here independently. The [upstream contribution](https://github.com/mlennie/hermes-mcp/pull/10) is separate from using this fork.

For feedback, provide connector and Hermes versions, a redacted error, and the failed verification step. Never include tokens, private prompts, or raw job databases in public reports. See [contributing](CONTRIBUTING.md) and [license](LICENSE).
