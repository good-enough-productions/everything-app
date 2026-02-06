import streamlit as st
import pandas as pd
import requests
from datetime import datetime, date
from typing import List, Dict, Any, Optional
from pathlib import Path
import json
import os

# -----------------------------
# Helper / API Functions
# -----------------------------

@st.cache_data(show_spinner=False, ttl=300)
def fetch_last_trade_with_fallback(ticker: str, api_key: str) -> tuple[Optional[float], Optional[str]]:
    """Try multiple Polygon endpoints to obtain a last trade price (realtime if entitled).
    Chain: last trade -> snapshot -> previous close. Returns (price, error_message).
    """
    headers = {"User-Agent": "ITM-Covered-Call-Screener/1.0"}
    primary_url = f"https://api.polygon.io/v2/last/trade/{ticker.upper()}"
    params = {"apiKey": api_key}

    # 1. Primary endpoint
    try:
        resp = requests.get(primary_url, params=params, headers=headers, timeout=10)
        if resp.status_code == 200:
            data = resp.json()
            last = data.get("last", {})
            price = last.get("price") or last.get("p")
            if price is not None:
                return float(price), None
            # fall through to fallback if structure unexpected
        else:
            # For common 403 provide clearer message
            if resp.status_code in (401, 403):
                try:
                    j = resp.json()
                    err_msg = j.get("error") or j.get("message") or (
                        "Unauthorized (401)" if resp.status_code == 401 else "Forbidden (403)"
                    )
                except Exception:
                    err_msg = (
                        "Unauthorized (401) - check API key" if resp.status_code == 401 else "Forbidden (403)"
                    )
                prefix = "401" if resp.status_code == 401 else "403"
                guidance = (
                    "(Invalid / missing API key?)" if resp.status_code == 401 else "(Plan may not include realtime data)"
                )
                return None, f"{prefix} fetching last trade ({ticker}): {err_msg} {guidance}".strip()
            # Other status codes capture
            return None, f"HTTP {resp.status_code} fetching last trade ({ticker})."
    except requests.RequestException as e:
        # network-level issue - continue to fallback
        pass

    # 2. Snapshot fallback
    snapshot_url = f"https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/tickers/{ticker.upper()}"
    try:
        resp2 = requests.get(snapshot_url, params=params, headers=headers, timeout=10)
        if resp2.status_code == 200:
            data2 = resp2.json()
            # Typical structure: {"ticker": {"lastTrade": {"p": 123.45, ...}, ...}}
            tnode = data2.get("ticker") or {}
            last_trade = tnode.get("lastTrade") or {}
            price = last_trade.get("price") or last_trade.get("p")
            if price is not None:
                return float(price), None
            return None, f"Snapshot endpoint returned no price for {ticker}."
        else:
            if resp2.status_code in (401, 403):
                try:
                    j2 = resp2.json()
                    err_msg2 = j2.get("error") or j2.get("message") or (
                        "Unauthorized (401)" if resp2.status_code == 401 else "Forbidden (403)"
                    )
                except Exception:
                    err_msg2 = (
                        "Unauthorized (401)" if resp2.status_code == 401 else "Forbidden (403)"
                    )
                prefix = "401" if resp2.status_code == 401 else "403"
                return None, f"{prefix} snapshot ({ticker}): {err_msg2}"
            return None, f"HTTP {resp2.status_code} snapshot for {ticker}."
    except requests.RequestException:
        return None, f"Network error retrieving price for {ticker}."

    # 3. Previous close fallback
    prev_price, prev_err = fetch_previous_close_price(ticker, api_key)
    if prev_price is not None:
        return prev_price, None

    return None, prev_err or f"Price not found for {ticker} after all endpoints."


@st.cache_data(show_spinner=False, ttl=600)
def fetch_previous_close_price(ticker: str, api_key: str) -> tuple[Optional[float], Optional[str]]:
    """Fetch previous close price for ticker using the Polygon prev aggregate endpoint."""
    url = f"https://api.polygon.io/v2/aggs/ticker/{ticker.upper()}/prev"
    params = {"apiKey": api_key}
    try:
        resp = requests.get(url, params=params, timeout=10)
        if resp.status_code == 200:
            data = resp.json()
            results = data.get("results") or []
            if results:
                close_price = results[0].get("c")
                if close_price is not None:
                    return float(close_price), None
            return None, f"Previous close not found for {ticker}."
        else:
            if resp.status_code in (401, 403):
                try:
                    j = resp.json(); msg = j.get("error") or j.get("message") or (
                        "Unauthorized (401)" if resp.status_code == 401 else "Forbidden (403)"
                    )
                except Exception:
                    msg = (
                        "Unauthorized (401)" if resp.status_code == 401 else "Forbidden (403)"
                    )
                prefix = "401" if resp.status_code == 401 else "403"
                return None, f"{prefix} previous close ({ticker}): {msg}"
            return None, f"HTTP {resp.status_code} previous close ({ticker})."
    except requests.RequestException:
        return None, f"Network error previous close ({ticker})."
def detect_env_api_key() -> Optional[str]:
    """Return API key from environment if available."""
    return os.environ.get("POLYGON_API_KEY")

@st.cache_data(show_spinner=False, ttl=120)
def quick_api_key_validation(api_key: str) -> tuple[bool, str]:
    """Ping a lightweight endpoint to validate key (using previous close for SPY)."""
    if not api_key:
        return False, "Empty API key."
    url = "https://api.polygon.io/v2/aggs/ticker/SPY/prev"
    try:
        resp = requests.get(url, params={"apiKey": api_key}, timeout=8)
        if resp.status_code == 200:
            return True, "Key valid (prev data accessible)."
        if resp.status_code in (401, 403):
            try:
                j = resp.json(); msg = j.get("error") or j.get("message") or resp.reason
            except Exception:
                msg = resp.reason
            return False, f"{resp.status_code} {msg}".strip()
        return False, f"HTTP {resp.status_code} {resp.reason}"
    except requests.RequestException as e:
        return False, f"Network error: {e}"


@st.cache_data(show_spinner=False, ttl=300)
def check_polygon_plan_capabilities(api_key: str) -> dict:
    """Test which Polygon endpoints are accessible with this API key."""
    if not api_key:
        return {"error": "No API key provided"}
    
    results = {}
    test_ticker = "AAPL"
    
    # Test endpoints in order of importance
    endpoints = [
        ("Previous Close", f"https://api.polygon.io/v2/aggs/ticker/{test_ticker}/prev"),
        ("Last Trade", f"https://api.polygon.io/v2/last/trade/{test_ticker}"),
        ("Snapshot", f"https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/tickers/{test_ticker}"),
        ("Options Contracts", f"https://api.polygon.io/v3/reference/options/contracts?underlying_ticker={test_ticker}&contract_type=call&expired=false&limit=10"),
    ]
    
    for name, url in endpoints:
        try:
            resp = requests.get(url, params={"apiKey": api_key}, timeout=10)
            if resp.status_code == 200:
                data = resp.json()
                # Check if we got actual data
                if name == "Options Contracts":
                    contracts = data.get("results", [])
                    if contracts:
                        # Check if we have bid/ask data
                        first_contract = contracts[0]
                        has_quotes = bool(first_contract.get("last_quote"))
                        results[name] = f"✅ Available ({len(contracts)} contracts, quotes: {'Yes' if has_quotes else 'No'})"
                    else:
                        results[name] = "⚠️ Endpoint works but no data returned"
                elif name == "Previous Close":
                    prev_results = data.get("results", [])
                    if prev_results:
                        results[name] = f"✅ Available (price: ${prev_results[0].get('c', 'N/A')})"
                    else:
                        results[name] = "⚠️ Endpoint works but no data"
                elif name in ["Last Trade", "Snapshot"]:
                    results[name] = "✅ Available"
                else:
                    results[name] = "✅ Available"
            elif resp.status_code == 403:
                try:
                    error_msg = resp.json().get("error", "Forbidden")
                except:
                    error_msg = "Forbidden - plan restriction"
                results[name] = f"❌ {error_msg}"
            elif resp.status_code == 401:
                results[name] = "❌ Unauthorized - check API key"
            else:
                results[name] = f"❌ HTTP {resp.status_code}"
        except Exception as e:
            results[name] = f"❌ Error: {str(e)[:50]}"
    
    return results


@st.cache_data(show_spinner=False, ttl=300)
def fetch_options_chain(ticker: str, api_key: str) -> List[Dict[str, Any]]:
    """Fetch up to 1000 call option contracts for the underlying ticker (non-expired)."""
    url = (
        f"https://api.polygon.io/v3/reference/options/contracts?"
        f"underlying_ticker={ticker.upper()}&contract_type=call&expired=false&limit=1000"
    )
    params = {"apiKey": api_key}
    try:
        resp = requests.get(url, params=params, timeout=20)
        resp.raise_for_status()
        data = resp.json()
        results = data.get("results", [])
        return results if isinstance(results, list) else []
    except Exception:
        return []


# -----------------------------
# Processing Logic
# -----------------------------

def extract_bid(contract: Dict[str, Any]) -> Optional[float]:
    """Attempt to extract the bid price from various plausible locations in the contract payload.
    Returns None if not available.
    """
    # Potential key paths observed/anticipated
    candidates = []
    last_quote = contract.get("last_quote") or contract.get("last_quote_detail") or {}
    if isinstance(last_quote, dict):
        candidates.extend([
            last_quote.get("bid"),
            last_quote.get("bid_price"),
            last_quote.get("p_bid"),  # arbitrary fallback
        ])
    # Some Polygon structures might nest deeper or use short keys; extend here if needed.
    for val in candidates:
        if val is not None:
            try:
                v = float(val)
                if v > 0:
                    return v
            except (TypeError, ValueError):
                continue
    return None


def process_ticker(
    ticker: str,
    api_key: str,
    dte_min: int,
    dte_max: int,
    min_oi: int,
    today: date,
    min_premium: float = 0.0,
    min_annualized_roi: float = 0.0,
    price_source_mode: str = "auto",
) -> List[Dict[str, Any]]:
    """Process one ticker and return list of opportunity dicts."""
    opportunities: List[Dict[str, Any]] = []

    # Get stock price
    if price_source_mode == "previous_close":
        stock_price, price_err = fetch_previous_close_price(ticker, api_key)
    else:  # auto
        stock_price, price_err = fetch_last_trade_with_fallback(ticker, api_key)
    if stock_price is None or stock_price <= 0:
        raise ValueError(price_err or f"Could not get valid last trade price for {ticker}.")

    # Get options chain
    contracts = fetch_options_chain(ticker, api_key)
    if not contracts:
        raise ValueError(f"No option contracts retrieved for {ticker}.")

    for contract in contracts:
        try:
            strike = contract.get("strike_price") or contract.get("strike")
            expiration = contract.get("expiration_date") or contract.get("expiration")
            open_interest = contract.get("open_interest") or contract.get("oi")

            if strike is None or expiration is None or open_interest is None:
                continue  # missing critical fields

            # Normalize
            strike = float(strike)
            open_interest = int(open_interest)

            # Parse expiration date (Polygon uses YYYY-MM-DD)
            try:
                exp_dt = datetime.strptime(expiration[:10], "%Y-%m-%d").date()
            except Exception:
                continue

            dte = (exp_dt - today).days
            if dte < 0:
                continue  # already expired (shouldn't happen with expired=false)

            # DTE filter
            if not (dte_min <= dte <= dte_max):
                continue

            # ITM filter: strike below current stock price
            if strike >= stock_price:
                continue

            # Liquidity filter
            if open_interest < min_oi:
                continue

            bid = extract_bid(contract)
            if bid is None or bid <= 0:
                continue  # skip if no usable premium

            premium = bid  # premium per share

            breakeven = stock_price - premium
            downside_protection_pct = (stock_price - breakeven) / stock_price * 100.0  # simplifies to premium/price

            # Profit if assigned at expiration (per 100 shares)
            profit_assigned = (strike * 100) - (stock_price * 100) + (premium * 100)
            return_if_assigned_pct = (profit_assigned / (stock_price * 100)) * 100.0
            if dte == 0:
                # Avoid divide by zero; treat as extremely short-term; skip
                continue
            annualized_roi_pct = return_if_assigned_pct * (365.0 / dte)

            # Additional threshold filters applied after computation
            if premium < min_premium:
                continue
            if annualized_roi_pct < min_annualized_roi:
                continue

            opportunities.append(
                {
                    "Ticker": ticker.upper(),
                    "Stock Price": stock_price,
                    "Strike": strike,
                    "Expiration": exp_dt.isoformat(),
                    "DTE": dte,
                    "Premium": premium,
                    "Return if Assigned %": return_if_assigned_pct,
                    "Breakeven": breakeven,
                    "Downside Protection %": downside_protection_pct,
                    "Annualized ROI %": annualized_roi_pct,
                    "Open Interest": open_interest,
                }
            )
        except Exception:
            # Skip contract-level errors silently to keep flow smooth
            continue

    return opportunities


# -----------------------------
# Formatting Helpers
# -----------------------------

def format_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    """Return a copy of df with formatted string columns for display."""
    df_disp = df.copy()

    # Currency formatting
    currency_cols = ["Stock Price", "Strike", "Premium", "Breakeven"]
    for col in currency_cols:
        if col in df_disp.columns:
            df_disp[col] = df_disp[col].map(lambda x: f"${x:,.2f}")

    # Percentage formatting
    pct_cols = [
        "Return if Assigned %",
        "Downside Protection %",
        "Annualized ROI %",
    ]
    for col in pct_cols:
        if col in df_disp.columns:
            df_disp[col] = df_disp[col].map(lambda x: f"{x:,.2f}%")

    return df_disp


def sort_dataframe(df: pd.DataFrame, sort_choice: str) -> pd.DataFrame:
    mapping = {
        "Return if Assigned %": "Return if Assigned %",
        "Downside Protection %": "Downside Protection %",
        "Annualized ROI %": "Annualized ROI %",
    }
    sort_col = mapping.get(sort_choice, "Return if Assigned %")
    return df.sort_values(by=sort_col, ascending=False)


# -----------------------------
# Streamlit App UI
# -----------------------------

def main():
    st.set_page_config(page_title="ITM Covered Call Screener", layout="wide")
    st.title("ITM Covered Call Screener")

    # Config persistence - load early to populate widgets
    config_path = Path(__file__).parent / ".itm_cc_config.json"
    
    # Initialize session state for config loading
    if 'config_loaded' not in st.session_state:
        st.session_state['config_loaded'] = True
        st.session_state['saved_api_key'] = ""
        st.session_state['saved_tickers'] = "AI\nMSFT\nSOFI"
        
        # Try to load from config file
        if config_path.exists():
            try:
                cfg = json.loads(config_path.read_text(encoding='utf-8'))
                if cfg.get('api_key'):
                    st.session_state['saved_api_key'] = cfg['api_key']
                if cfg.get('tickers'):
                    st.session_state['saved_tickers'] = cfg['tickers']
            except Exception:
                st.sidebar.warning("Failed to load saved config file.")
    
    # Sidebar controls
    # API key priority: environment > saved > empty
    env_key = detect_env_api_key()
    default_key = env_key or st.session_state.get('saved_api_key', "")
    
    api_key = st.sidebar.text_input(
        "Polygon.io API Key",
        type="password",
        value=default_key,
        help="Set POLYGON_API_KEY env var or use Remember option to auto-load."
    )
    
    # Clean the API key of any whitespace
    if api_key:
        api_key = api_key.strip()
    # Manual API key override (for debugging)
    manual_override = st.sidebar.checkbox("Manual API Key Override", help="Use this if saved key isn't working")
    if manual_override:
        api_key = st.sidebar.text_input("Manual API Key", type="password", value="")
    
    # Diagnostics section
    with st.sidebar.expander("Diagnostics & API Key Test"):
        if api_key:
            masked = api_key[:4] + "***" + api_key[-4:] if len(api_key) > 8 else "***"
            st.write(f"Key detected: {masked} (length {len(api_key)})")
            
            # Validate key format
            if len(api_key) < 20:
                st.warning("⚠️ API key seems too short (should be ~32 chars)")
            elif len(api_key) > 50:
                st.warning("⚠️ API key seems too long")
            
            # Check for common issues
            if api_key.startswith(' ') or api_key.endswith(' '):
                st.error("🚨 API key has leading/trailing spaces!")
            if not api_key.replace('-', '').replace('_', '').isalnum():
                st.warning("⚠️ API key contains unusual characters")
                
            # Show first and last few characters for debugging
            if len(api_key) > 10:
                st.code(f"First 8: {api_key[:8]}...\nLast 8: ...{api_key[-8:]}")
        else:
            st.write("No API key entered yet.")
        
        col1, col2, col3 = st.columns(3)
        with col1:
            if st.button("Test API Key", use_container_width=True):
                if api_key:
                    valid, msg = quick_api_key_validation(api_key)
                    if valid:
                        st.success(msg)
                    else:
                        st.error(msg)
                        st.info("401 = invalid/missing; 403 = insufficient permissions / plan level.")
                        # Show raw API key for debugging 401s
                        if "401" in msg:
                            st.error("🔍 Debugging info:")
                            st.code(f"Raw key: '{api_key}'")
                            st.code(f"Test URL used: https://api.polygon.io/v2/aggs/ticker/SPY/prev?apiKey={api_key[:8]}...")
                            st.info("💡 Try testing this URL directly in your browser or with curl")
                else:
                    st.error("No API key to test")
        
        with col2:
            if st.button("Check Plan Limits", use_container_width=True):
                if api_key:
                    with st.spinner("Testing endpoints..."):
                        capabilities = check_polygon_plan_capabilities(api_key)
                    st.write("**Endpoint Access:**")
                    for endpoint, status in capabilities.items():
                        st.write(f"{endpoint}: {status}")
                else:
                    st.error("Enter API key first")
        
        with col3:
            if st.button("Copy Test URL", use_container_width=True):
                if api_key:
                    test_url = f"https://api.polygon.io/v2/aggs/ticker/SPY/prev?apiKey={api_key}"
                    st.code(test_url)
                    st.info("Copy this URL to test in browser/curl")
                else:
                    st.error("Need API key")
    dte_range = st.sidebar.slider(
        "Desired DTE Range (Days)",
        min_value=1,
        max_value=180,
        value=(25, 45),
        step=1,
    )
    min_oi = st.sidebar.number_input(
        "Minimum Open Interest", min_value=0, value=100, step=10,
        help="Filters out contracts with open interest below this number (liquidity)."
    )
    min_premium = st.sidebar.number_input(
        "Minimum Premium ($)", min_value=0.0, value=0.10, step=0.05,
        help="Exclude contracts with bid premium below this dollar amount per share."
    )
    min_annualized_roi = st.sidebar.number_input(
        "Minimum Annualized ROI %", min_value=0.0, value=0.0, step=1.0,
        help="Exclude contracts whose annualized ROI % is below this threshold."
    )
    sort_choice = st.sidebar.selectbox(
        "Sort by", ["Return if Assigned %", "Downside Protection %", "Annualized ROI %"],
    )
    price_source_mode = st.sidebar.selectbox(
        "Price Source", ["Auto (Realtime->Snapshot->Prev Close)", "Previous Close Only"],
        help="Use Previous Close Only if your plan does not include realtime data.")
    show_formatted = st.sidebar.checkbox(
        "Format numbers (currency & %)", value=True,
        help="Uncheck to keep raw numeric values (enables copy & further numeric sorting)."
    )

    remember = st.sidebar.checkbox(
        "Remember API key & tickers (plaintext local file)", value=False,
        help="Stores credentials & tickers in a local hidden JSON file next to the app. Do NOT enable on shared machines."
    )
    clear_saved = st.sidebar.button("Clear Saved Credentials", help="Deletes the local config file.")

    # Clear saved credentials if requested
    if clear_saved and config_path.exists():
        config_path.unlink(missing_ok=True)
        st.session_state['saved_api_key'] = ""
        st.session_state['saved_tickers'] = "AI\nMSFT\nSOFI"
        st.sidebar.success("Saved credentials cleared.")
        st.rerun()

    st.subheader("Tickers")
    default_ticker_block = st.session_state.get('saved_tickers', "AI\nMSFT\nSOFI")
    tickers_text = st.text_area(
        "Enter one ticker per line:",
        value=default_ticker_block,
        height=120,
    )
    tickers = [t.strip().upper() for t in tickers_text.splitlines() if t.strip()]

    if st.button("Find Opportunities", type="primary"):
        if not api_key:
            st.error("Please enter your Polygon.io API key in the sidebar.")
            return
        if not tickers:
            st.warning("Please enter at least one ticker.")
            return

        results: List[Dict[str, Any]] = []
        errors: List[str] = []
        today = date.today()

        with st.spinner("Fetching and processing option data..."):
            for tk in tickers:
                try:
                    opps = process_ticker(
                        tk, api_key, dte_range[0], dte_range[1], int(min_oi), today,
                        min_premium=float(min_premium),
                        min_annualized_roi=float(min_annualized_roi),
                        price_source_mode=(
                            "previous_close" if price_source_mode.startswith("Previous") else "auto"
                        ),
                    )
                    results.extend(opps)
                except Exception as e:
                    errors.append(f"{tk}: {e}")
                    # Abort early if all remaining likely to fail due to auth
                    if "401" in str(e) and len(results) == 0:
                        errors.append("Authentication issue detected. Aborting remaining tickers.")
                        break

        # Save config if requested & successful button press
        if remember and api_key:
            try:
                config_obj = {"api_key": api_key, "tickers": tickers_text}
                config_path.write_text(json.dumps(config_obj), encoding='utf-8')
                # Update session state so it persists
                st.session_state['saved_api_key'] = api_key
                st.session_state['saved_tickers'] = tickers_text
            except Exception:
                st.sidebar.warning("Failed to save config file.")

        if results:
            df = pd.DataFrame(results)
            # Ensure column order
            desired_cols = [
                "Ticker",
                "Stock Price",
                "Strike",
                "Expiration",
                "DTE",
                "Premium",
                "Return if Assigned %",
                "Breakeven",
                "Downside Protection %",
                "Annualized ROI %",
                "Open Interest",
            ]
            df = df[desired_cols]

            # Sort numeric before formatting
            df = sort_dataframe(df, sort_choice)
            if show_formatted:
                df_display = format_dataframe(df)
            else:
                df_display = df

            st.success(f"Found {len(df)} opportunities after filters.")
            st.dataframe(df_display, use_container_width=True)
        else:
            st.info("No opportunities found matching your criteria.")

        if errors:
            with st.expander("View errors / skipped tickers"):
                for msg in errors:
                    st.write(msg)

    st.caption(
        "All data sourced from Polygon.io. This tool is for informational purposes only and not investment advice."  # noqa: E501
    )


if __name__ == "__main__":
    main()
