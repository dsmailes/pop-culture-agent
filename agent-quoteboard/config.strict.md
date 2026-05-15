# Agent Quoteboard Config

Quote source mode: **strict bank only**.

Use only quotes from `agent-quoteboard/quotes.json`.

Do not invent new quote-style lines during normal operation. If no quote in the
bank fits the current reasoning state, tone, freshness, and intensity, skip the
quote entirely.

Only add new quotes by editing `agent-quoteboard/quotes.json` when the user
explicitly asks to expand the quote bank.
