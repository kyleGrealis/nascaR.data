# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## \[Unreleased\]

### Changed

- Updated DriverAverages scraper base URL for the second-tier series
  from `nascar_xfinityseries/` to `nascar_secondseries/` to match
  upstream rebrand.

### Fixed

- Restored missing 2025 `S1` and `S2` stage data across Cup, NXS, and
  Truck series (#41).

## \[3.1.0\] - 2026-06-11

### Added

- Added
  [`export_series()`](https://www.kylegrealis.com/nascaR.data/reference/export_series.md)
  function to export series datasets to local CSV or Parquet files.
- Added support for automated CSV generation and upload to Cloudflare R2
  alongside Parquet.
- Added `ingesting-nascar-data` vignette detailing direct access URLs
  and type-coercion considerations.

## \[3.0.1\] - 2026-05-06

### Changed

- Replaced persistent on-disk caching with in-memory session caching in
  [`load_series()`](https://www.kylegrealis.com/nascaR.data/reference/load_series.md)
  to prevent stale local data.

## \[3.0.0\] - 2026-05-06

### Changed

- Migrated canonical datasets out of the package bundle to Cloudflare R2
  remote storage.
- Added
  [`load_series()`](https://www.kylegrealis.com/nascaR.data/reference/load_series.md)
  dynamic reader function.
