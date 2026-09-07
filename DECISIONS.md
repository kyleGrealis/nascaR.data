# Project Decision Log

This document records technical, statistical, and architectural decisions made throughout the lifecycle of this project.

Entries are ordered chronologically with newest entries at the top.

---

## 2026-09-07: Update NXS Scraper Base URL for DriverAverages Rebrand

- **Context / Problem**: DriverAverages.com moved its second-tier series URL path from `/nascar_xfinityseries/` to `/nascar_secondseries/` with a 301 redirect. Relying on HTTP redirects for relative race link resolution introduces failure modes during automated weekly cron runs.
- **Decision Taken**: Update `config$nxs$base_url` directly to `https://www.driveraverages.com/nascar_secondseries/` in `inst/updates/scraper.R`.
- **Rationale & Trade-offs**: Direct endpoint resolution avoids redirect latency and prevents relative path mismatches during weekly race scraping.
- **Related Files**: `inst/updates/scraper.R`, `GEMINI.md`, `NEWS.md`
