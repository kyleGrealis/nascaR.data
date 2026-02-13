# Maintainer Notes

## Cloudflare R2 Credentials

### Local Setup
```r
# Add to .Renviron (NEVER commit this file)
R2_ACCOUNT_ID="your_account_id"
R2_ACCESS_KEY_ID="your_access_key_id"
R2_SECRET_ACCESS_KEY="your_secret_access_key"
```

### GitHub Secrets
Settings > Secrets and variables > Actions > Add:
- `R2_ACCOUNT_ID`
- `R2_ACCESS_KEY_ID`
- `R2_SECRET_ACCESS_KEY`

### Token Rotation (Annually)
1. Cloudflare Dashboard > R2 > Manage R2 API Tokens
2. Create new token (Object Read & Write, bucket: `nascar-data`)
3. Update `.Renviron` and GitHub Secrets
4. Delete old token

## Data Workflow

R2 is the single source of truth. No data is bundled with the package.

### Weekly Automated Pipeline (GitHub Actions)
Runs every Monday at 10:00 UTC (5:00 AM EST).
Manual trigger: Actions tab > Weekly NASCAR Data Update > Run workflow.

1. `scraper.R` downloads existing data from R2
2. Scrapes new races from DriverAverages.com
3. Combines old + new and uploads back to R2
4. `validate_data.R` downloads from R2 and validates
5. Commits `.checksums.json` to main

### Manual Seed/Re-upload
```bash
# Upload local rda files to R2 as parquet (one-time or recovery)
Rscript inst/updates/upload_to_r2.R

# Dry run (no actual upload)
Rscript inst/updates/upload_to_r2.R --dry-run
```

### Local Full Update
```r
# Requires R2 credentials in .Renviron + paws.storage, arrow, httr2
source("R/r2_upload.R")
source("inst/updates/scraper.R")
update_nascar_series("cup")
update_nascar_series("xfinity")
update_nascar_series("truck")
```

## R2 Bucket Details

- **Bucket**: `nascar-data`
- **Region**: WNAM
- **Custom domain**: `nascar.kylegrealis.com`
- **Files**: `cup_series.parquet`, `xfinity_series.parquet`, `truck_series.parquet`

## Adding Track Info

When new tracks are added to the NASCAR schedule:
1. Update the relevant `inst/updates/*_track_info.rda` file
2. Include: Track name (must match DriverAverages.com), Length, Surface

## Xfinity Series Naming

The dataset uses `xfinity_series` regardless of future sponsor changes.
If renamed post-2026, add a backward-compatible alias so both names work,
then sunset the old name after the transition season.
