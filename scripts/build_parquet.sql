-- Build Parquet files from the cleaned CSVs. Run from the repo root:
--   duckdb -c ".read scripts/build_parquet.sql"

COPY (
  SELECT DISTINCT ON (Epoch)
    Epoch::BIGINT AS epoch, Timestamp::TIMESTAMP AS ts,
    Open::DOUBLE AS open, High::DOUBLE AS high, Low::DOUBLE AS low, Close::DOUBLE AS close,
    Volume::BIGINT AS volume
  FROM read_csv('1min/*/*.csv', union_by_name=true, header=true)
  ORDER BY Epoch
) TO 'parquet/SENSEX_01min.parquet' (FORMAT parquet, COMPRESSION zstd);

COPY (
  SELECT DISTINCT ON (Epoch)
    Epoch::BIGINT AS epoch, Timestamp::TIMESTAMP AS ts,
    Open::DOUBLE AS open, High::DOUBLE AS high, Low::DOUBLE AS low, Close::DOUBLE AS close
  FROM read_csv('15sec/*/*.csv', header=true)
  ORDER BY Epoch
) TO 'parquet/SENSEX_15sec.parquet' (FORMAT parquet, COMPRESSION zstd);

-- Resampled bars start at the 09:15 session open; ts is the bar start time.
COPY (
  SELECT min(epoch) AS epoch,
    time_bucket(INTERVAL 2 MINUTE, ts, TIMESTAMP '2023-01-02 09:15:00') AS ts,
    first(open ORDER BY epoch) AS open, max(high) AS high,
    min(low) AS low, last(close ORDER BY epoch) AS close
  FROM 'parquet/SENSEX_01min.parquet' GROUP BY 2 ORDER BY 2
) TO 'parquet/SENSEX_02min.parquet' (FORMAT parquet, COMPRESSION zstd);
COPY (
  SELECT min(epoch) AS epoch,
    time_bucket(INTERVAL 3 MINUTE, ts, TIMESTAMP '2023-01-02 09:15:00') AS ts,
    first(open ORDER BY epoch) AS open, max(high) AS high,
    min(low) AS low, last(close ORDER BY epoch) AS close
  FROM 'parquet/SENSEX_01min.parquet' GROUP BY 2 ORDER BY 2
) TO 'parquet/SENSEX_03min.parquet' (FORMAT parquet, COMPRESSION zstd);
COPY (
  SELECT min(epoch) AS epoch,
    time_bucket(INTERVAL 5 MINUTE, ts, TIMESTAMP '2023-01-02 09:15:00') AS ts,
    first(open ORDER BY epoch) AS open, max(high) AS high,
    min(low) AS low, last(close ORDER BY epoch) AS close
  FROM 'parquet/SENSEX_01min.parquet' GROUP BY 2 ORDER BY 2
) TO 'parquet/SENSEX_05min.parquet' (FORMAT parquet, COMPRESSION zstd);
COPY (
  SELECT min(epoch) AS epoch,
    time_bucket(INTERVAL 10 MINUTE, ts, TIMESTAMP '2023-01-02 09:15:00') AS ts,
    first(open ORDER BY epoch) AS open, max(high) AS high,
    min(low) AS low, last(close ORDER BY epoch) AS close
  FROM 'parquet/SENSEX_01min.parquet' GROUP BY 2 ORDER BY 2
) TO 'parquet/SENSEX_10min.parquet' (FORMAT parquet, COMPRESSION zstd);
COPY (
  SELECT min(epoch) AS epoch,
    time_bucket(INTERVAL 15 MINUTE, ts, TIMESTAMP '2023-01-02 09:15:00') AS ts,
    first(open ORDER BY epoch) AS open, max(high) AS high,
    min(low) AS low, last(close ORDER BY epoch) AS close
  FROM 'parquet/SENSEX_01min.parquet' GROUP BY 2 ORDER BY 2
) TO 'parquet/SENSEX_15min.parquet' (FORMAT parquet, COMPRESSION zstd);
COPY (
  SELECT min(epoch) AS epoch,
    time_bucket(INTERVAL 30 MINUTE, ts, TIMESTAMP '2023-01-02 09:15:00') AS ts,
    first(open ORDER BY epoch) AS open, max(high) AS high,
    min(low) AS low, last(close ORDER BY epoch) AS close
  FROM 'parquet/SENSEX_01min.parquet' GROUP BY 2 ORDER BY 2
) TO 'parquet/SENSEX_30min.parquet' (FORMAT parquet, COMPRESSION zstd);
COPY (
  SELECT min(epoch) AS epoch,
    time_bucket(INTERVAL 60 MINUTE, ts, TIMESTAMP '2023-01-02 09:15:00') AS ts,
    first(open ORDER BY epoch) AS open, max(high) AS high,
    min(low) AS low, last(close ORDER BY epoch) AS close
  FROM 'parquet/SENSEX_01min.parquet' GROUP BY 2 ORDER BY 2
) TO 'parquet/SENSEX_60min.parquet' (FORMAT parquet, COMPRESSION zstd);
