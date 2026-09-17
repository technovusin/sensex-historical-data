# SENSEX OHLC Data

Historical SENSEX OHLC intraday data, including 1-minute candles from 2023 and 15-second candles from 15 September 2026. Volume data is only available from 2026 for 1 minute candles.

## Data Structure

```
nifty/
├── 1min/          # 1-minute candlestick data
│   ├── 2023-2025/ # Full years
│   └── 2026/      # From 01 January 2026
├── 15sec/         # 15-second candlestick data
│   └── 2026/      # From 15 September 2026
└── README.md      # This file
```

## File Format

Each CSV file contains the following columns:

| Column | Description |
|--------|-------------|
| Epoch | Unix timestamp (seconds since 1970-01-01) |
| Timestamp | ISO 8601 format (YYYY-MM-DDTHH:MM:SS) |
| Open | Opening price for the candle |
| High | Highest price during the candle |
| Low | Lowest price during the candle |
| Close | Closing price for the candle |
