# ITM Covered Call Screener

A Streamlit web application that screens for in-the-money (ITM) covered call opportunities using Polygon.io option chain data.

## Features
- Input multiple tickers (one per line)
- Filters by Days to Expiration (DTE) range
- Filters by minimum open interest (liquidity)
- Filters by minimum premium ($) and minimum Annualized ROI %
- Only considers in-the-money call options (strike < current stock price)
- Calculates premium, breakeven, downside protection %, return if assigned %, and annualized ROI %
- Sort results by chosen metric
- Optional numeric formatting toggle (raw vs formatted values)
- Response caching (5 min TTL) to reduce API calls

## Requirements
Python 3.9+

## Installation
```bash
pip install -r requirements.txt
```

## Run the App
```bash
streamlit run app.py
```

Open the provided local URL in your browser. Enter your Polygon.io API key (kept hidden) and click "Find Opportunities".

## Notes
- Premium uses the bid price; contracts with missing/zero bid are excluded.
- Annualized ROI % = Return if Assigned % * (365 / DTE).
- Downside Protection % equals Premium / Stock Price * 100.
- Caching reduces repeated API requests within a 5 minute window (clear via Streamlit menu if needed).
- Data quality depends on Polygon.io responses.

## Disclaimer
This tool is for informational and educational purposes only and does not constitute investment advice. Always do your own research.
