#!/bin/bash

# Get today's date in mm/dd/yyyy format
today_date=$(date +'%m/%d/%Y')

# Print current working directory
echo "Starting... Current directory:"
pwd

# Git operations in current directory
git add .
git commit -m "Updated race results on $today_date"
git push




# Change to nascaR.data directory
echo "Changed to:"
cd ../nascaR.data
pwd

# Bump patch version
echo "Bumping patch version..."
Rscript -e "
  desc <- read.dcf('DESCRIPTION')
  current_version <- desc[1, 'Version']
  version_parts <- unlist(strsplit(current_version, '\\\\.'))
  new_patch <- as.integer(version_parts[3]) + 1
  new_version <- paste0(version_parts[1], '.', version_parts[2], '.', new_patch)
  desc[1, 'Version'] <- new_version
  write.dcf(desc, 'DESCRIPTION')
  cat('New version:', new_version, '\n')
"

# Git operations in current directory
git add .
git commit -m "Updated race results on $today_date"
git push




# Return to the starting directory
echo "Returned to starting directory:"
cd ../motorsports-scraping
pwd