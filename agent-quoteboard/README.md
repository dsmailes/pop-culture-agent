# Agent Quoteboard

Agent Quoteboard is a small `AGENTS.md` behavior snippet that replaces bland
agent transition phrases with occasional short, bold pop-culture-style lines.

It is intentionally prompt-only. It does not install dependencies or change
runtime code. The optional quote bank is data-only JSON used to reduce
repetition.

## Install In A Repo With AGENTS.md

Copy the `agent-quoteboard` directory into your repository, then add these
lines to your existing root `AGENTS.md`:

```md
@./agent-quoteboard/AGENTS.snippet.md
@./agent-quoteboard/quotes.json
@./agent-quoteboard/config.strict.md
```

Keep your existing repo instructions in place. The snippet is additive.

## Install In A Repo Without AGENTS.md

Copy the `agent-quoteboard` directory into your repository, then create a root
`AGENTS.md` containing:

```md
@./agent-quoteboard/AGENTS.snippet.md
@./agent-quoteboard/quotes.json
@./agent-quoteboard/config.strict.md
```

## Install-Time Choice

Choose exactly one config file when installing:

```md
@./agent-quoteboard/config.strict.md
```

Strict mode uses only `quotes.json`. If no bank quote fits, the agent skips the
quote. This is the recommended default because it reduces repetition and keeps
the behavior predictable.

```md
@./agent-quoteboard/config.open.md
```

Open mode prefers `quotes.json`, but lets the agent improvise a short,
contextually appropriate line when the bank has no fresh fit.

## Uninstall

Remove the include lines from `AGENTS.md`, then delete the `agent-quoteboard`
directory.

## Tune

If the quotes feel too frequent, edit `AGENTS.snippet.md` and change the
frequency guidance from `3-5 agent updates` to a larger interval such as
`5-8 agent updates`.

## Quote Bank

`quotes.json` contains reusable quote entries tagged by reasoning state and
tone. Add new entries there when a phrase gets stale.

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
