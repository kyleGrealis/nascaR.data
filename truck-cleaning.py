'''
This is the data cleaning script for NASCAR Truck series data. Some level of data exploration is necessary, but the primary purpose is to clean the data and create new variables.
'''

# %%
import numpy as np
import pandas as pd
import polars as pl
import glob
import os
import re


# %%

# read in the main racing results CSV
df = pl.read_csv(
  'data/truck-series/all-truck-series-results.csv', infer_schema_length=10000
)


# %%
# function to transform a column that contains '-' to integer
def transform_column(col):
    return col.replace('–', None).cast(pl.Float64).cast(pl.Int64)


# %%

# cleaning variable names, types, and correcting missingness where appropriate
truck = (
  df
  .rename({
    'Season': 'season',
    'Race': 'race',
    'Site': 'site',
    'Track': 'track',
    'Track_length': 'track_length',
    'Track_type': 'track_type',
    'Pos': 'finish',
    'St': 'start',
    '#': 'truck_number',
    'Driver': 'driver',
    'Truck': 'truck',
    'Laps': 'laps',
    'Money': 'money',
    'Status': 'status',
    'Led': 'laps_led',
    'Pts': 'pts',
    'PPts': 'playoff_pts'
  })
  .with_columns(
    
    pl.col('finish').cast(pl.Int64),
    pl.col('start').cast(pl.Int64),
    pl.col('truck_number').cast(pl.Utf8),
    pl.col('laps').cast(pl.Int64),
    pl.col('laps_led').cast(pl.Int64),
    pl.col('pts').cast(pl.Int64),
    
    # user-created function
    transform_column(pl.col('playoff_pts')).alias('playoff_pts'),
    
    # create a 0/1 win column  
    pl.when(pl.col('finish') == 1)
      .then(1)
      .otherwise(0)
      .cast(pl.Int64)
      .alias('win'),
      
    # create 'Sponsor' column by removing content within parentheses and strip whitespace, or set to empty string if no parentheses meaning there is no sponsor but only owner information in 'Sponsor / Owner' variable.
    pl.col('Sponsor / Owner')
      .map_elements(
        lambda value: re.sub(r'\(.*?\)', '', value).strip() if re.search(r'\(.*?\)', value) else '', 
        return_dtype=pl.Utf8
      ) 
      .alias('sponsor'),
    
     # Create 'Owner' column by extracting content within parentheses or using the entire value if no parentheses. When the original 'Sponsor / Owner' value is blank, neither new variable will have a value entered and will remain blank.
    pl.col('Sponsor / Owner')
      .map_elements(
        lambda value: re.search(r'\((.*?)\)', value).group(1) if re.search(r'\((.*?)\)', value) else value, 
        return_dtype=pl.Utf8
      )
      .alias('owner'),
  )
  .drop('Sponsor / Owner')
).select(
  'season', 'race', 'site', 'track', 'track_length', 'track_type',
  'finish', 'start', 'driver', 'truck', 'truck_number', 'owner', 'sponsor',
  'laps', 'laps_led', 'status', 'money', 'pts', 'playoff_pts', 'win'
)


# %%

'''
Calculating statistics for the driver's results by season.
'''
driver_season = (
  truck
  .group_by('driver', 'season', maintain_order=True).agg(
    
    total_races = pl.count('driver'),
    
    wins = pl.col('win').sum(),
    
    best_start = pl.col('start').min(),
    worst_start = pl.col('start').max(),
    avg_start = pl.col('start').drop_nans().mean().round(2),
    
    best_finish = pl.col('finish').min(),
    worst_finish = pl.col('finish').max(),
    avg_finish = pl.col('finish').mean().round(2),
    
    most_laps_led = pl.col('laps_led').max(),
    avg_laps_led = pl.col('laps_led').drop_nans().mean().round(2),
    total_laps_led = pl.col('laps_led').sum(),
    
    avg_points = pl.col('pts').drop_nans().mean().round(2),
    
    # playoff points started in 2017
    avg_playoff_pts = pl.col('playoff_pts').drop_nans().mean().round(2),
    
    # money results aren't collected after the 2015 season
    total_money = pl.col('money').sum().cast(pl.Int64),
    avg_money = pl.col('money').mean().round(0).cast(pl.Int64),
    
    max_race_money = pl.col('money').max().cast(pl.Int64),
    min_race_money = pl.col('money').min().cast(pl.Int64)
  )
  .with_columns(
    win_pct = (pl.col('wins') / pl.col('total_races')).cast(pl.Float64).round(5)
  )
  .sort('season', 'avg_finish')
).select(
  'season', 'driver', 'total_races', 'wins', 'win_pct', 'avg_start', 'best_start',
  'worst_start', 'avg_finish', 'best_finish', 'worst_finish', 'avg_laps_led',
  'total_laps_led', 'most_laps_led', 'avg_points', 'avg_playoff_pts',
  'total_money', 'avg_money', 'max_race_money', 'min_race_money'
)


# %%

'''
Calculating statistics for the driver's results by career.
'''
driver_career = (
  truck
  .group_by('driver', maintain_order=True).agg(
    
    total_races = pl.count('driver'),
    
    wins = pl.col('win').sum(),
    
    best_start = pl.col('start').min(),
    worst_start = pl.col('start').max(),
    avg_start = pl.col('start').drop_nans().mean().round(2),
    
    best_finish = pl.col('finish').min(),
    worst_finish = pl.col('finish').max(),
    avg_finish = pl.col('finish').mean().round(2),
    
    most_laps_led = pl.col('laps_led').max(),
    avg_laps_led = pl.col('laps_led').drop_nans().mean().round(2),
    total_laps_led = pl.col('laps_led').sum(),
    
    # money results aren't collected after the 2015 season
    total_money = pl.col('money').sum().cast(pl.Int64),
    avg_money = pl.col('money').mean().round(0).cast(pl.Int64),
    
    max_race_money = pl.col('money').max().cast(pl.Int64),
    min_race_money = pl.col('money').min().cast(pl.Int64)
  )
  .with_columns(
    win_pct = (pl.col('wins') / pl.col('total_races')).cast(pl.Float64).round(5)
  )
  .sort('driver')
).select(
  'driver', 'total_races', 'wins', 'win_pct', 'avg_start', 'best_start',
  'worst_start', 'avg_finish', 'best_finish', 'worst_finish', 'avg_laps_led',
  'total_laps_led', 'most_laps_led',
  'total_money', 'avg_money', 'max_race_money', 'min_race_money'
)


# %%

'''
Calculating statistics by owner.
'''
owner_races_per_truck = truck.group_by('owner', 'season', 'race').agg(
    race_count = pl.count('race')
).group_by('owner').agg(
    races_participated = pl.count('race')
)

owner_overall = (
  truck
  .group_by('owner', maintain_order=True).agg(
    
    total_trucks_raced = pl.count('owner'),
    
    wins = pl.col('win').sum(),
    
    avg_start = pl.col('start').drop_nans().mean().round(2),
    avg_finish = pl.col('finish').mean().round(2),
    
    avg_laps_led = pl.col('laps_led').drop_nans().mean().round(2),
    total_laps_led = pl.col('laps_led').sum(),
  )
  .join(owner_races_per_truck, on='owner', how='left')
  .with_columns(
    overall_win_pct= (pl.col('wins') / pl.col('races_participated'))
    .cast(pl.Float64).round(5),
    owner_truck_win_pct = (pl.col('wins') / pl.col('total_trucks_raced')).cast(pl.Float64).round(5)
  )
  .sort('owner')
).select(
  'owner', 'races_participated', 'total_trucks_raced', 'wins', 
  'overall_win_pct', 'owner_truck_win_pct', 'avg_start', 'avg_finish',
  'avg_laps_led', 'total_laps_led'
)


# %%

'''
Calculating statistics for manufacturer by season.
'''
manufacturer_season = (
  truck
  .group_by('truck', 'season', maintain_order=True).agg(
    
    total_trucks_raced = pl.count('truck'),
    
    wins = pl.col('win').sum(),
    
    races_participated = pl.col('race').n_unique(),
    
    best_start = pl.col('start').min(),
    worst_start = pl.col('start').max(),
    avg_start = pl.col('start').drop_nans().mean().round(2),
    
    best_finish = pl.col('finish').min(),
    worst_finish = pl.col('finish').max(),
    avg_finish = pl.col('finish').mean().round(2),
    
    most_laps_led = pl.col('laps_led').max(),
    avg_laps_led = pl.col('laps_led').drop_nans().mean().round(2),
    total_laps_led = pl.col('laps_led').sum(),
  )
  .with_columns(
    win_pct = (pl.col('wins') / pl.col('races_participated'))
    .cast(pl.Float64).round(5)
  )
  .sort('season', 'truck')
  .filter(pl.col('truck') != '')
).select(
  'truck', 'season', 'total_trucks_raced', 'wins', 'races_participated', 
  'win_pct', 'avg_start', 'best_start', 'worst_start', 'avg_finish',
  'best_finish', 'worst_finish', 'avg_laps_led', 'total_laps_led'
)

# %%

'''
Calculating statistics for manufacturer by season.
'''

# count the number of races each manufacturer has had at least one truck
mfg_races_per_truck = truck.group_by('truck', 'season', 'race').agg(
    race_count = pl.count('race')
).group_by('truck').agg(
    races_participated = pl.count('race')
)

manufacturer_overall = (
  truck
  .group_by('truck', maintain_order=True).agg(
    
    total_trucks_raced = pl.count('truck'),
    
    wins = pl.col('win').sum(),
    
    avg_start = pl.col('start').drop_nans().mean().round(2),
    avg_finish = pl.col('finish').mean().round(2),
    
    avg_laps_led = pl.col('laps_led').drop_nans().mean().round(2),
    total_laps_led = pl.col('laps_led').sum(),
  )
  .join(mfg_races_per_truck, on='truck', how='left')
  .with_columns(
    overall_win_pct= (pl.col('wins') / pl.col('races_participated'))
    .cast(pl.Float64).round(5),
    mfg_truck_win_pct = (pl.col('wins') / pl.col('total_trucks_raced')).cast(pl.Float64).round(5)
  )
  .sort('truck')
).select(
  'truck', 'races_participated', 'total_trucks_raced', 'wins', 
  'overall_win_pct', 'mfg_truck_win_pct', 'avg_start', 'avg_finish',
  'avg_laps_led', 'total_laps_led'
)



# %%

# storing the cleaned datasets
truck.write_csv('data/truck-series/truck-results.csv')

driver_career.write_csv('data/truck-series/truck-driver-career.csv')
driver_season.write_csv('data/truck-series/truck-driver-season.csv')

owner.write_csv('data/truck-series/truck-owner.csv')

manufacturer_overall.write_csv('data/truck-series/truck-manufacturer-overall.csv')
manufacturer_season.write_csv('data/truck-series/truck-manufacturer-season.csv')

# %%
