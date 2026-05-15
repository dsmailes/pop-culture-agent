# Pop Culture Agent

Pop Culture Agent is a prompt-only `AGENTS.md` add-on for making agent progress
updates a little more characterful. It replaces bland transition phrases with
occasional short, bold pop-culture-style lines while keeping technical updates
clear.

It is intentionally small:

- no package manager
- no runtime code
- no dependencies
- no build step

## Install

Run this from the root of the repo where you want Pop Culture Agent installed:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh
```

The installer downloads `pop-culture-agent/` and adds one include line to the
target repo's `AGENTS.md`:

```md
@./pop-culture-agent/AGENTS.md
```

## Choose A Mode

Strict mode is the default. To install open mode:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_MODE=open sh
```

Under the hood, use exactly one config file:

```md
@./pop-culture-agent/config.strict.md
```

Strict mode uses only quotes from `quotes.json`. If no quote fits, the agent
skips the quote. This is the recommended default.

```md
@./pop-culture-agent/config.open.md
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

Edit `pop-culture-agent/quotes.json` to add or remove quotes. Edit
`pop-culture-agent/AGENTS.snippet.md` to change frequency, formatting, tone
modes, or selection rules.

## Uninstall

Remove the Pop Culture Agent include line from `AGENTS.md`, then delete the
`pop-culture-agent` directory.
