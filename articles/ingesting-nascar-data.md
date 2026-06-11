# Ingesting NASCAR Data

The **nascaR.data** package hosts its canonical race results datasets
publicly on Cloudflare R2. While R users can leverage
[`load_series()`](https://www.kylegrealis.com/nascaR.data/reference/load_series.md),
non-R users or developers building external pipelines can access these
datasets directly in both Parquet and CSV formats.

## Direct Download URLs

All datasets are updated every Monday at 5:00 AM EST during the racing
season.

### Parquet Format (Recommended)

Parquet is highly recommended as it preserves exact column data types
and has a significantly smaller file size.

- **Cup Series**: `https://nascar.kylegrealis.com/cup_series.parquet`
- **NXS Series**: `https://nascar.kylegrealis.com/nxs_series.parquet`
- **Truck Series**:
  `https://nascar.kylegrealis.com/truck_series.parquet`

### CSV Format

- **Cup Series**: `https://nascar.kylegrealis.com/cup_series.csv`
- **NXS Series**: `https://nascar.kylegrealis.com/nxs_series.csv`
- **Truck Series**: `https://nascar.kylegrealis.com/truck_series.csv`

------------------------------------------------------------------------

## Command-Line Download

You can download any of these files directly using `curl` or `wget`:

``` bash
# Download Cup Series CSV results
curl -O https://nascar.kylegrealis.com/cup_series.csv

# Download NXS Series Parquet results
curl -O https://nascar.kylegrealis.com/nxs_series.parquet
```

------------------------------------------------------------------------

## Critical Ingestion Note: NASCAR Car Numbers

When ingesting the CSV files, pay special attention to the `Car` (car
number) column.

In NASCAR, car numbers can contain leading zeros (e.g., `"08"`, `"09"`),
which represent entirely different teams and entries from single-digit
numbers (e.g., `"8"`, `"9"`).

By default, most CSV parsers (including R’s
[`read.csv()`](https://rdrr.io/r/utils/read.table.html) and Python’s
`pandas.read_csv()`) guess column types based on initial rows and will
parse the `Car` column as an integer. This strips leading zeros,
incorrectly converting `"08"` to `8`.

### Correct Ingestion in R

When reading the CSV file in R, explicitly specify that the `Car` column
should be parsed as a character string:

``` r

# Base R
cup <- read.csv(
  "cup_series.csv",
  colClasses = c(Car = "character"),
  stringsAsFactors = FALSE
)

# tidyverse / readr
cup <- readr::read_csv(
  "cup_series.csv",
  col_types = readr::cols(Car = readr::col_character())
)
```

### Correct Ingestion in Python (pandas)

When reading the CSV file in Python, use the `dtype` argument to treat
the `Car` column as a string:

``` python
import pandas as pd

# Load CSV and preserve leading zeros
cup = pd.read_csv("cup_series.csv", dtype={"Car": str})
```

By specifying the type as a string/character, you ensure the car numbers
remain accurate for historical roster matching.
