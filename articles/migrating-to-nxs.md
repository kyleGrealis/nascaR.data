# Upgrading to v3

Version 3.0.0 introduces several breaking changes focused on modernizing
the package architecture and future-proofing the series identifiers.
This guide helps you migrate from v2.x to v3.0.0.

## Bundled datasets removed

**What changed:** The `cup_series`, `xfinity_series`, and `truck_series`
datasets are no longer bundled with the package. All data is now served
from Cloudflare R2.

**Before (v2.x):**

``` r
data("cup_series")
data("xfinity_series")
data("truck_series")
```

**After (v3.0.0):**

``` r
cup <- load_series("cup")
nxs <- load_series("nxs")
truck <- load_series("truck")
```

**Why:** Bundling large datasets in the package made installation slow
and increased package size. Serving data from R2 with local caching
provides faster updates and smaller package downloads.

## Series identifier: “xfinity” renamed to “nxs”

**What changed:** The second-tier series identifier changed from
`"xfinity"` to `"nxs"`.

**Before (v2.x):**

``` r
xfinity <- load_series("xfinity")
get_driver_info("bell", series = "xfinity")
```

**After (v3.0.0):**

``` r
nxs <- load_series("nxs")
get_driver_info("bell", series = "nxs")
```

**Why:** The second-tier NASCAR series has changed title sponsors four
times: Busch (1984-2007), Nationwide (2008-2014), Xfinity (2015-2025),
and O’Reilly Auto Parts (2026-present). “NXS” is NASCAR’s own
sponsor-neutral abbreviation for the series, so it will never go stale
with future sponsor changes.

**Note:** The `Series` column in returned data now shows `"NXS"` instead
of `"Xfinity"`. Update any code that filters on `Series == "Xfinity"`.

## arrow package now required

**What changed:** The `arrow` package moved from Suggests to Imports. It
is now a required dependency.

**Why:** All data is stored as Parquet files on R2. The `arrow` package
is required to read this data efficiently.

**Action required:** None. The `arrow` package will be installed
automatically when you install nascaR.data v3.0.0.

## Caching

**How it works:**

1.  **First call in a session:** Downloads data from R2 and caches in
    memory
2.  **Subsequent calls in same session:** Instant retrieval from memory
    cache
3.  **New R session:** Downloads fresh data from R2 automatically

Each new R session fetches the latest data, so you always have
up-to-date race results without any manual intervention.

**Managing the cache:**

``` r
# Force fresh download within a session
cup <- load_series("cup", refresh = TRUE)

# Reset the in-memory cache
clear_cache()
```

## find\_\*() functions removed

**What changed:** `find_driver()`, `find_team()`, and
`find_manufacturer()` have been removed.

**Before (v2.x):**

``` r
find_driver("bell")
get_driver_info("Christopher Bell")
```

**After (v3.0.0):**

``` r
# Just use get_*_info() directly
get_driver_info("bell")
```

**Why:** The `get_*_info()` functions already include fuzzy matching and
return actual data. The `find_*()` functions were redundant.

## Summary of required changes

| v2.x                          | v3.0.0                            |
|-------------------------------|-----------------------------------|
| `data("cup_series")`          | `load_series("cup")`              |
| `data("xfinity_series")`      | `load_series("nxs")`              |
| `data("truck_series")`        | `load_series("truck")`            |
| `series = "xfinity"`          | `series = "nxs"`                  |
| `find_driver("bell")`         | `get_driver_info("bell")`         |
| `find_team("gibbs")`          | `get_team_info("gibbs")`          |
| `find_manufacturer("toyota")` | `get_manufacturer_info("toyota")` |
| `Series == "Xfinity"`         | `Series == "NXS"`                 |

## Data unchanged

The underlying race data is unchanged. Only the delivery mechanism and
series identifier have been updated. All historical results remain
available:

- Cup Series: 1949-present
- NXS: 1982-present
- Truck Series: 1995-present
