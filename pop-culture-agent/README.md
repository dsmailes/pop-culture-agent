# Pop Culture Agent

Pop Culture Agent is a small `AGENTS.md` behavior snippet that replaces bland
agent transition phrases with occasional short, bold pop-culture-style lines.

It is intentionally prompt-only. It does not install dependencies or change
runtime code.

## Install

Run this from the target repo:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh
```

When run in a terminal, the installer asks for up to three favorite films,
games, shows, or franchises, then asks which agent bridge files to create. Press
Enter for the recommended defaults, including no favorite-source preferences.

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
copies beside replaced files.

For non-interactive updates, set `POP_CULTURE_AGENT_UPDATE=1`.

## Reference Selection

The installed agent uses open reference selection:

```md
@./pop-culture-agent/AGENTS.snippet.md
@./pop-culture-agent/preferences.md
@./pop-culture-agent/config.open.md
```

The agent chooses short, recognizable references from the model's own
pop-culture knowledge. There is no strict bank mode and no bundled quote list.
If no familiar reference cleanly matches the reasoning state, the agent should
skip the quote instead of forcing a generic one.

To set favorite sources non-interactively, use `POP_CULTURE_AGENT_FAVORITES`
with up to three comma-separated values:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_FAVORITES="Scream, Metal Gear Solid, Alien" sh
```

Existing `preferences.md` files are preserved on rerun. In update mode, passing
`POP_CULTURE_AGENT_FAVORITES` refreshes `preferences.md` and writes a `.bak`
copy first.

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

## Tune Sources

You can steer the agent later by editing `preferences.md`:

```md
- Scream
- Metal Gear Solid
- Alien
```

Agents should render selected reference text as bold Markdown without surrounding
inverted commas, for example:

```md
**See you, space cowboy.**
```
