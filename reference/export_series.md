# Export NASCAR Series Data

Downloads or loads the specified NASCAR series data and writes it to a
file in either CSV or Parquet format.

## Usage

``` r
export_series(series = c("cup", "nxs", "truck"), path, format = NULL, ...)
```

## Arguments

- series:

  Character. The series to export. One of `"cup"`, `"nxs"`, or
  `"truck"`.

- path:

  Character. Path to the output file (including extension).

- format:

  Character. Output format: `"csv"`, `"parquet"`, or `NULL`. If `NULL`
  (default), the format is guessed from the file extension of `path`.

- ...:

  Additional arguments passed to
  [`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html) (for
  CSV) or
  [`arrow::write_parquet()`](https://arrow.apache.org/docs/r/reference/write_parquet.html)
  (for Parquet).

## Value

Invisibly returns the exported data.

## Examples

``` r
if (FALSE) { # \dontrun{
# Export Cup Series data to CSV
export_series("cup", "cup_data.csv")

# Export Truck Series data to Parquet
export_series("truck", "truck_data.parquet")
} # }
```
