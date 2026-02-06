# Project Status Snapshot

Last Updated: 2025-08-11

## Purpose
Screen for in-the-money (ITM) covered call opportunities across a user-provided list of tickers, applying liquidity and return filters, and ranking results by customizable metrics.

## Core Workflow (Implemented)
1. Input tickers (multi-line text area)
2. Fetch underlying price (Polygon previous close / realtime if entitled; multi-endpoint fallback)
3. Fetch option chain (Polygon contracts endpoint)
4. Filter contracts: DTE range, ITM (strike < price), minimum open interest, minimum premium, minimum annualized ROI
5. Compute metrics: Premium, Breakeven, Downside Protection %, Return if Assigned %, Annualized ROI %
6. Sort by selected metric and display formatted dataframe

## Implemented Features
- Streamlit UI (sidebar controls + main results)
- DTE range slider
- Min Open Interest, Min Premium $, Min Annualized ROI % filters
- ITM enforcement (strike < underlying price)
- Metrics calculations & currency / percent formatting toggle
- Sorting by key metrics
- Polygon data integration with cascading price source fallback (last trade → snapshot → previous close)
- Previous Close Only mode for restricted API plans
- Detailed error/diagnostics panel with API key tester
- Optional local persistence of API key & tickers (.itm_cc_config.json) + clear button - FIXED
- Caching of API responses (Streamlit cache) to reduce calls
- Configurable price source selection
- Early abort on authentication errors to save calls
- .gitignore with secret/config exclusions
- Enhanced diagnostics panel with API plan capability testing
- Manual API key override for debugging
- API key format validation and whitespace cleanup

## Known Limitations
- Reliant on Polygon option chain bid availability (free plan may yield zero bids)
- No alternate data provider implemented yet (Yahoo / Mock not coded)
- No CSV / Excel export button
- No auto-refresh interval feature
- No unit/integration tests
- No provider abstraction layer (logic still Polygon-centric in-place)
- No volatility / Greeks / probability metrics
- No multi-threading / async for faster batch fetches
- Error handling is coarse for per-contract issues (silent skips)

## Planned / Backlog
Priority (High → Low):
1. Data Provider Abstraction (BaseProvider + PolygonProvider extraction)
2. Yahoo Finance (unofficial) fallback provider (quote + options chain)
3. Mock provider for offline demo/testing
4. CSV export (download button) + raw JSON export
5. Auto-refresh option (interval slider) with state-safe reruns
6. Mid-price fallback (use (bid+ask)/2 when bid missing & ask present)
7. Watchlist file upload (CSV) & environment variable watchlist ingestion
8. Unit tests for metric calculations & filtering edge cases
9. Logging panel / debug toggles for API responses (redacted)
10. Performance: parallel requests (async or ThreadPool) with rate limit guards
11. Risk metrics: annualized yield vs. DTE scatter plot, implied volatility (if data available)
12. Persistence encryption (avoid plaintext API key)
13. Dark/light theme customization & column visibility toggles
14. CI workflow (lint + tests) and code formatting (black / ruff)
15. Packaging: entry point script & optional Dockerfile

## Deferred / Exploratory
- Direct brokerage integration (Robinhood/Fidelity) due to ToS & stability concerns
- Interactive Brokers / Tradier official API support (future optional module)
- Strategy simulation (rolling, early assignment probability modeling)

## Quick Start Reminder
1. Create venv & install requirements
2. Run: `streamlit run app.py`
3. Enter Polygon API key (or load saved) / set Price Source
4. Adjust filters & click "Find Opportunities"

## Security Notes
- API key stored locally only if user opts in (plaintext). Consider moving to environment variables or encrypted keyring later.

## Next Recommended Step
Refactor into provider architecture + add Yahoo fallback to improve data coverage on free tiers.
