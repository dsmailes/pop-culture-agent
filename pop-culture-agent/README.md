# Pop Culture Agent

Pop Culture Agent is a small `AGENTS.md` behavior snippet that replaces bland
agent transition phrases with occasional short, bold pop-culture-style lines.

It is intentionally prompt-only. It does not install dependencies or change
runtime code. The optional quote bank is data-only JSON used to reduce
repetition.

## Install

Run this from the target repo:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh
```

When run in a terminal, the installer asks you to choose improvise/strict mode
and which agent bridge files to create. Press Enter for the recommended
defaults: improvise mode and all supported bridge files.

If you do not want extra bridge files such as `CLAUDE.md`, `GEMINI.md`, or
`.github/copilot-instructions.md`, choose `AGENTS.md only` at the prompt.

The installer copies the `pop-culture-agent` directory into your repository,
then adds bridge instructions for common coding agents:

- `AGENTS.md` for Codex-style and other `AGENTS.md` readers
- `CLAUDE.md` for Claude Code
- `GEMINI.md` for Gemini CLI
- `.github/copilot-instructions.md` for GitHub Copilot

For `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`, the bridge line is:

```md
@./pop-culture-agent/AGENTS.md
```

Keep your existing repo instructions in place. The snippet is additive: the
installer creates missing files, preserves existing files, and will not
duplicate existing bridge lines.

## Update

Rerunning the installer normally preserves existing installed files. To refresh
stock prompts and configs to the latest version, use update mode:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh -s -- --update
```

For a global install, include `--global`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh -s -- --global --update
```

Update mode replaces the stock files in `pop-culture-agent/` and writes `.bak`
copies beside replaced files. It preserves an existing `quotes.json`; the latest
upstream quote bank is saved beside it as `quotes.json.latest` so custom quotes
can be merged deliberately.

For non-interactive updates, set `POP_CULTURE_AGENT_UPDATE=1`.

## Install-Time Choice

Improvise mode is the default. It prefers `quotes.json`, but lets the agent use
a short, contextually appropriate fallback line when the bank has no fresh fit:

```md
@./pop-culture-agent/config.open.md
```

This is the recommended default because it keeps the agent from going quiet
when the quote bank has no exact fit.

Skip the prompt and install strict mode with:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_MODE=strict sh
```

You can also pass the default mode explicitly; `open` and `improvise` are
equivalent:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_MODE=open sh
```

Strict mode uses:

```md
@./pop-culture-agent/config.strict.md
```

Strict mode uses only `quotes.json` and skips quotes when no bank quote fits.

To switch to strict mode later, edit `pop-culture-agent/AGENTS.md` and replace
the open config line with the strict config line.

## Install-Time Agent Targets

By default, the installer targets `agents,claude,gemini,copilot`. To install
only specific bridge files without prompting, set `POP_CULTURE_AGENT_TARGETS`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_TARGETS=agents,claude sh
```

## Uninstall

Remove the Pop Culture Agent bridge line from any generated instruction files,
then delete the `pop-culture-agent` directory.

## Tune

If the quotes feel too frequent, edit `AGENTS.snippet.md` and change the
frequency guidance from `1-3 meaningful progress updates` to a larger interval
such as `3-5 agent updates`. The installer preserves this file when rerun.

## Quote Bank

`quotes.json` contains reusable quote entries tagged by reasoning state and
tone. Add new entries there when a phrase gets stale.

You can ask your coding agent to add quotes from a favorite source:

```md
Add short quotes from Metal Gear Solid to Pop Culture Agent.
```

The installed instructions tell the agent to choose short, standalone lines,
categorize them by reasoning state, assign matching tones, and validate the JSON.
Providing exact favorite lines gives the agent the cleanest input.

Each quote should stay short and use this shape:

```json
{
  "id": "bigger_boat",
  "quote": "We're gonna need a bigger boat.",
  "source": "Jaws",
  "source_type": "movie",
  "states": ["hidden_complexity"],
  "tones": ["default", "survival_horror"],
  "intensity": 0.7,
  "rarity": 0.2
}
```

Use `states` to decide when a quote applies, `tones` to match the requested
style, `intensity` to avoid over-dramatizing routine updates, and `rarity` to
keep distinctive quotes from showing up too often.

Agents should render selected quote text as bold Markdown without surrounding
inverted commas, for example:

```md
**We're gonna need a bigger boat.**
```
