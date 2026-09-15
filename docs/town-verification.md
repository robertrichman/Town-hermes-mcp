# Town connector verification and limits

This checklist distinguishes a working connection from successful downstream work. Record the date, fork commit, Hermes version, and Town connection tested. Do not describe this checklist as passing until it has been executed on the installation in question.

## 1. Connection and identity

Send one read-only request to an existing, known Hermes session.
Confirm Town receives a reply from the intended context. If project records are requested, require identifiable records, not a claim of remembered knowledge.
Confirm no downstream task, worker, branch, or deployment was created.

## 2. Async response and responsiveness

Send one explicitly authorized, harmless slow request with async mode.
Save its job ID. Check that another bridge status request responds while the first is pending.
Poll the existing job; do not resend the original instruction.
Distinguish gateway latency from connector responsiveness.

## 3. Persistence

On a test installation, complete a harmless job, restart the connector, reconnect OAuth if needed, and check the same job within the retention window.
Expect its saved result to survive if persistent storage is configured.
For an interrupted request, expect an explicit unconfirmed outcome—not automatic replay or assumed downstream cancellation.

## 4. Downstream execution, when configured

Before authorizing work, identify the supported route, accessible inputs, required tools, acceptance evidence, and system recording execution.
A bridge job ID is not a worker run ID.
Confirm the worker actually starts and that its tracking reference is recorded.
Verify that the chosen tracker covers that execution route. An empty tracker that does not cover the route cannot establish that no work occurred.
If the route lacks tracking, report that limitation and stop unattended progression.

For visual work, establish a permitted preview path before starting. For review, provide the specification and exact candidate to the reviewer. Missing required inputs or evidence must prevent accepted completion.
These are requirements on the downstream workflow; this bridge does not enforce them.

## 5. Completion reporting

Keep these separate:
- Town connected.
- Hermes responded.
- Downstream execution started.
- An artifact was produced.
- The artifact was checked against the request.
- The user can access the result.

A result can pass earlier steps and fail later ones. Do not label the whole workflow COMPLETE based on an earlier step.

## Lessons from a September 2026 integration exercise

A coordinator's report from a custom coding setup described replies claiming activity before dispatch, delegated work absent from its custom tracker, an unavailable preview, and review claims unsupported by the candidate or accessible specifications.

These are reported downstream integration findings, not a diagnosis of a new transport defect in this repository. They motivated clearer boundaries and the routine changes here. No private project artifacts are reproduced.

## Scope of this publication

This update changes documentation and package presentation. It does not repair Hermes worker dispatch, add Kanban integration, validate generated code, or qualify an autonomous coding pipeline. A new live Town/Hostinger test was not performed as part of this documentation update.
