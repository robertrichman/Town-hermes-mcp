# Town + Hermes Agent on Hostinger Docker

This deployment connects a Town assistant to a durable Hermes Agent session through
`hermes-mcp`:

```text
Town routine -> HTTPS/OAuth -> hermes-mcp -> Hermes gateway -> durable Hermes session
```

The example is suitable for Hostinger's Docker Manager or another Docker host that already
runs Traefik and Hermes Agent. It keeps the bridge in its own container, exposes it only
through Traefik, and places the public router labels on the bridge container that actually
serves MCP.

## Prerequisites

- A working Hermes Agent gateway with its OpenAI-compatible API enabled.
- A Docker network shared with the Hermes gateway.
- A Docker network shared with Traefik.
- A public hostname pointed at the Docker host.
- Traefik configured with a TLS certificate resolver.

The bridge needs the Hermes gateway's `API_SERVER_KEY`. It does not need unrelated
production credentials. Keep Hermes approval hooks enabled and configure the gateway's
API toolset for the actions this connection is allowed to perform.

## Configure the containers

1. Copy `deploy/hermes-mcp.env.example` to `deploy/hermes-mcp.env`. The destination is
   ignored by Git.
2. Set `MCP_HOSTNAME`, the two Docker network names, and the Traefik certificate resolver.
3. Run `hermes-mcp mint-client` and place the generated OAuth values in the env file.
4. Set `HERMES_API_KEY` to the gateway's `API_SERVER_KEY`.
5. If the gateway service is not named `hermes-agent`, set `HERMES_API_URL` to its URL on
   the shared Docker network.

Validate the resolved configuration before starting it:

```bash
docker compose \
  --env-file deploy/hermes-mcp.env \
  -f deploy/docker-compose.traefik.yml \
  config
```

Then build and start the bridge:

```bash
docker compose \
  --env-file deploy/hermes-mcp.env \
  -f deploy/docker-compose.traefik.yml \
  up -d --build
```

The image starts as a non-root user. Its startup doctor checks that the gateway is
reachable and accepts the configured key before the MCP server begins accepting work.

## Verify the public route

These two unauthenticated checks do not run Hermes work:

```bash
curl -fsS "https://${MCP_HOSTNAME}/.well-known/oauth-authorization-server"
curl -sS -o /dev/null -w '%{http_code}\n' "https://${MCP_HOSTNAME}/mcp"
```

The metadata request should return JSON with the public issuer and OAuth endpoints. The
second request should return `401`; that proves the route reaches the protected MCP
service. `404` usually means the router rule did not match. `502` usually means Traefik
cannot reach the bridge container or selected the wrong Docker network.

Keep every `traefik.http.routers.*` and `traefik.http.services.*` label on the
`hermes-mcp` service. Putting those labels on the Hermes gateway container routes the
hostname to the wrong port and can produce a persistent `502` even though both containers
are healthy. `traefik.docker.network` removes ambiguity when the bridge joins two networks.

## Connect Town

Town's current custom-integration flow is:

1. Open **Settings -> MCP** and choose **Add Server**.
2. Enter a recognizable name, `https://<MCP_HOSTNAME>/mcp`, and a short description.
3. Complete the OAuth flow.
4. Enable this MCP server only on the routines that need Hermes.
5. Run a read-only supervised request before allowing an execution routine to use it.

Town documents its OAuth callback as
`https://www.town.com/api/mcp/oauth/callback` and notes that some providers also need
`https://town.com/api/mcp/oauth/callback`. `hermes-mcp` accepts HTTPS redirect URIs, so no
Town-specific custom URI scheme is required. See
[Town's custom MCP documentation](https://www.town.com/docs/integrations/mcp-servers).

Use a stable, role-based `session_id` for a durable Hermes role. Do not create a new ID for
each Town run. For example, a routine that always addresses one project lead can call:

```text
hermes_ask(
  prompt="Consult the current project records and report status without changing them.",
  session_id="my-project-lead",
  async_mode=false
)
```

Use synchronous mode for a bounded status or judgment request expected to finish quickly.
Use asynchronous mode for multi-step execution, preserve the returned `job_id`, and poll
`hermes_check` no faster than every 5-10 seconds.

## Do not confuse bridge completion with downstream completion

Every asynchronous record includes `completion_scope: "gateway_response"`. A bridge job
marked `completed` proves that the Hermes gateway returned a response. It does not prove
that a separate worker, Kanban card, CI run, deployment, or other downstream process named
in that response also finished.

If the result is a handoff or receipt, make one synchronous follow-up through the same
`session_id`. Ask Hermes to read the current downstream state, then reconcile the answer
with the system that owns the facts, such as the project tracker, source repository, CI
provider, or deployment platform. Do not submit the execution instruction again merely
because the MCP receipt ended; that can create duplicate work.

A supervised connection test should prove all of the following:

- Town reaches the intended durable Hermes session.
- The session reads the intended project context and current authoritative records.
- A read-only status request creates no task, worker, branch, or deployment.
- One bounded authorized instruction creates only the expected work.
- The final report distinguishes the MCP receipt from the real downstream state.
- Human action is stated explicitly when needed.

## Updating safely

Render `docker compose ... config` first and compare the candidate image with the currently
running bridge. Back up the compose file, build the candidate without moving the live
router, and run local metadata, authentication, durable-session, synchronous, and
asynchronous checks. Move the public router only after those checks pass. A bridge restart
clears in-memory OAuth tokens and async job receipts; it does not erase Hermes sessions.
