# SENSEX OHLC Data

Historical SENSEX OHLC intraday data, including 1-minute candles from 2023 and 15-second candles from 15 September 2026. All times are IST. Volume data is only available from 2026 for 1-minute candles.

## Data Structure

```
sensex/
├── 1min/                 # 1-minute candles (CSV)
│   ├── 2023-2025/        # One file per year
│   └── 2026/             # One file per month, from 01 January 2026 (includes Volume)
├── 15sec/                # 15-second candles (CSV)
│   └── 2026/             # One file per month, from 15 September 2026
├── parquet/              # Generated Parquet files (not in git, see below)
├── scripts/
│   └── build_parquet.sql # Builds the Parquet files from the CSVs
└── README.md             # This file
```

File names are `SENSEX_<timeframe>_<year>.csv` for 2023-2025 and `SENSEX_<timeframe>_<year>-<month>.csv` for 2026, for example `SENSEX_1min_2026-09.csv`.

## File Format

Each CSV file contains the following columns:

| Column | Description |
|--------|-------------|
| Epoch | Unix timestamp (seconds since 1970-01-01) |
| Timestamp | ISO 8601 format (YYYY-MM-DDTHH:MM:SS), IST |
| Open | Opening price for the candle |
| High | Highest price during the candle |
| Low | Lowest price during the candle |
| Close | Closing price for the candle |
| Volume | 2026 1-minute files only |

## Parquet Files

Parquet files are not stored in git. Build them from the CSVs with [DuckDB](https://duckdb.org) (run from the repo root):

```
duckdb < scripts/build_parquet.sql
```

On Windows PowerShell, the `<` redirect isn't supported, so use either of these instead (they also work in Command Prompt and Linux/macOS shells):

```
duckdb -c ".read scripts/build_parquet.sql"
Get-Content scripts/build_parquet.sql -Raw | duckdb
```

This creates the following files in `parquet/`, a columnar format for fast backtesting. Re-run it whenever the CSVs change:

| File | Timeframe |
|------|-----------|
| `SENSEX_15sec.parquet` | 15 seconds (from 15 Sep 2026) |
| `SENSEX_01min.parquet` | 1 minute (includes `volume`, NULL before 2026) |
| `SENSEX_02min`, `03min`, `05min`, `10min`, `15min`, `30min`, `60min` | Resampled from 1-minute data |

Columns are `epoch` (BIGINT), `ts` (TIMESTAMP, IST), `open`, `high`, `low`, `close` (DOUBLE). Resampled bars start at the 09:15 session open, and `ts` is the bar start time.

```sql
-- DuckDB
SELECT * FROM 'parquet/SENSEX_05min.parquet' WHERE ts >= '2024-01-01';
```

## Data Cleaning

The CSVs and Parquet files have been cleaned:

- Bars outside 09:15-15:29 IST removed (including pre-open and post-close bars), except the evening Diwali muhurat sessions (12 Nov 2023, 1 Nov 2024).
- Two bad first candles in 2024 fixed (12 Apr 09:15 and 23 Apr 09:16): High adjusted to include Open.
- Removed a spurious partial Saturday session: 21 Mar 2026.
- Prices rounded to 2 decimals (the source had float32 noise); duplicate epochs removed.

Known remaining quirks: the 72 trading days from 2 Jan to 12 Jul 2023 have 374 bars and no 15:29 bar, 14 Jul 2023 has 372 bars, 21 Oct 2025 (muhurat) has only 60 bars, and some frozen-price stretches may exist. Weekend rows are special sessions (muhurat 12 Nov 2023, budget days, 20 Jan 2024, 2 Mar and 18 May 2024).

## Adding New Data

1. Add the new CSV to the matching folder (for 2026, the current month's file), with the same header as the existing files.
2. Rebuild the Parquet files with the command above. Duplicate epochs across files are removed automatically.

## NIFTY OHLC Data

If you are looking for NIFTY index OHLC data, it can be downloaded at [https://github.com/technovusin/nifty50-historical-data](https://github.com/technovusin/nifty50-historical-data) 
