# Pop Culture Agent

Pop Culture Agent is a prompt-only add-on for making coding agent progress
updates a little more characterful. It installs pop-culture-style progress
instructions into a target repository so compatible agents can replace bland
transition phrases with occasional short, bold lines while keeping technical
updates clear.

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

When run in a terminal, the installer asks you to choose:

- repo or global install scope
- up to three favorite films, games, shows, or franchises
- which agent bridge files to create

Press Enter for the recommended defaults: repo scope, no favorite-source
preferences, and all supported repo bridge files.

To make the scope explicit in a one-line install, pass installer arguments with
`sh -s --`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh -s -- --repo
```

For a global install:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh -s -- --global
```

If you do not want extra bridge files such as `CLAUDE.md`, `GEMINI.md`, or
`.github/copilot-instructions.md`, choose `AGENTS.md only` at the prompt.

In repo scope, the installer downloads `pop-culture-agent/` and adds small
bridge instructions for common coding agents:

- `AGENTS.md` for Codex-style and other `AGENTS.md` readers
- `CLAUDE.md` for Claude Code
- `GEMINI.md` for Gemini CLI
- `.github/copilot-instructions.md` for GitHub Copilot

For `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`, the bridge line is:

```md
@./pop-culture-agent/AGENTS.md
```

For Copilot, the bridge is a Markdown reference to the same installed agent
instructions:

```md
Refer to [Pop Culture Agent](../pop-culture-agent/AGENTS.md) for agent progress-update style.
```

In global scope, the installer writes the shared agent files to
`~/.pop-culture-agent` by default and adds absolute bridge lines to:

- `~/.codex/AGENTS.md`
- `~/.claude/CLAUDE.md`
- `~/.gemini/GEMINI.md`

Global scope skips Copilot because Copilot instructions are repo-level
`.github/copilot-instructions.md` files.

The installer is idempotent and non-destructive: rerunning it creates any
missing bundled files and bridge lines, but preserves existing files and does
not duplicate bridge lines.

To refresh an existing install to the latest stock prompts and configs, use
update mode:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh -s -- --update
```

For a global install, include `--global`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh -s -- --global --update
```

Update mode replaces the stock prompt files in `pop-culture-agent/` and writes
`.bak` copies beside replaced files.

The installer refuses to run from the Pop Culture Agent source repo by default,
so testing the installer here does not create local bridge files by accident.

## Reference Selection

The generated `pop-culture-agent/AGENTS.md` includes the behavior snippet and
one generated preferences file plus the open selection config:

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

## Choose Agent Targets

By default, the installer targets `agents,claude,gemini,copilot`. To install
only specific bridge files without prompting, set `POP_CULTURE_AGENT_TARGETS`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_TARGETS=agents,claude sh
```

For CI or other non-interactive installs, set the values explicitly:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_NONINTERACTIVE=1 POP_CULTURE_AGENT_SCOPE=repo POP_CULTURE_AGENT_TARGETS=agents,claude,gemini,copilot sh
```

You can include favorites in the same command:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_NONINTERACTIVE=1 POP_CULTURE_AGENT_SCOPE=repo POP_CULTURE_AGENT_FAVORITES="Scream, Metal Gear Solid, Alien" POP_CULTURE_AGENT_TARGETS=agents,claude,gemini,copilot sh
```

To update non-interactively, set `POP_CULTURE_AGENT_UPDATE=1`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_NONINTERACTIVE=1 POP_CULTURE_AGENT_UPDATE=1 sh
```

To run a non-interactive global install:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_NONINTERACTIVE=1 POP_CULTURE_AGENT_SCOPE=global POP_CULTURE_AGENT_TARGETS=agents,claude,gemini sh
```

## Example Outputs

Discovery:

```md
**Enhance.**

The issue is in `AuthReducer`: logout clears the token but leaves the refresh
task running.
```

Root cause found:

```md
**It was Agatha all along.**

`MenuImporter` is parsing the cached fixture instead of the downloaded response.
```

Hidden complexity:

```md
**That's no moon.**

The CLI flag is wired correctly, but the installer path is rebuilt later from
`POP_CULTURE_AGENT_DIR`.
```

Risky action:

```md
**Never tell me the odds.**

I am about to rewrite the bridge-file update logic and keep the existing user
instructions intact.
```

Build/test failure:

```md
**Houston, we have a problem.**

`tests/install.sh` now reaches update mode, but the backup assertion is checking
the old config line.
```

Completion:

```md
**See you, space cowboy.**

The installer test passes, and the branch is ready to push.
```

## Customize

Edit `pop-culture-agent/AGENTS.snippet.md` to change frequency, formatting, tone
modes, or selection rules.

You can steer the agent later by editing `pop-culture-agent/preferences.md`:

```md
- Scream
- Metal Gear Solid
- Alien
```

The installed instructions tell the agent to prioritize semantic fit, keep
references short, avoid long copyrighted passages, and skip the quote when no
recognizable line fits.

## Uninstall

Remove the Pop Culture Agent bridge line from any generated instruction files,
then delete the `pop-culture-agent` directory.
