# Agent Quoteboard

Agent Quoteboard is a prompt-only `AGENTS.md` add-on for making agent progress
updates a little more characterful. It replaces bland transition phrases with
occasional short, bold pop-culture-style lines while keeping technical updates
clear.

It is intentionally small:

- no package manager
- no runtime code
- no dependencies
- no build step

## Install

Copy the `agent-quoteboard` directory into your repository.

If your repo already has an `AGENTS.md`, add:

```md
@./agent-quoteboard/AGENTS.snippet.md
@./agent-quoteboard/quotes.json
@./agent-quoteboard/config.strict.md
```

If your repo does not have an `AGENTS.md`, create one with those same lines.

## Choose A Mode

Use exactly one config file:

```md
@./agent-quoteboard/config.strict.md
```

Strict mode uses only quotes from `quotes.json`. If no quote fits, the agent
skips the quote. This is the recommended default.

```md
@./agent-quoteboard/config.open.md
```

Open mode prefers `quotes.json`, but lets the agent improvise a short outside-
bank line when the bank has no fresh fit.

## Example Output

```md
**The truth is out there.**

The issue is in `AuthReducer`: logout clears the token but leaves the refresh
task running.
```

## Customize

Edit `agent-quoteboard/quotes.json` to add or remove quotes. Edit
`agent-quoteboard/AGENTS.snippet.md` to change frequency, formatting, tone
modes, or selection rules.

## Uninstall

Remove the Agent Quoteboard include lines from `AGENTS.md`, then delete the
`agent-quoteboard` directory.
