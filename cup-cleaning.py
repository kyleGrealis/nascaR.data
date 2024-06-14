'''
This is the data cleaning script for NASCAR Cup series data. Some level of data exploration is necessary, but the primary purpose is to clean the data and create new variables.
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
  'data/cup-series/all-cup-series-results.csv', infer_schema_length=10000
)

# convert # to Integer
# impute missing Led to 0
# Running: -- to 'running' or vice versa?



# %%
# df.select(
#   pl.n_unique('Track').alias('total_tracks'),
#   pl.n_unique('Driver').alias('total_drivers'),
#   pl.n_unique('Car').alias('total_cars'),
#   pl.n_unique('Status').alias('total_status'),
#   pl.col('Money').sum().alias('total_money_awarded')
# )

# %%
# function to transform a column that contains '-' to integer
def transform_column(col):
    return col.replace('–', None).cast(pl.Float64).cast(pl.Int64)



# %%

# cleaning variable names, types, and correcting missingness where appropriate
cup = (
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
    '#': 'car_number',
    'Driver': 'driver',
    'Car': 'car',
    'Laps': 'laps',
    'Money': 'money',
    'Status': 'status',
    'Led': 'laps_led',
    'Pts': 'pts',
    'PPts': 'playoff_pts'
  })
  # note: The sponsor information exists outside the parentesis if there are parenthesis in the string, such as 'STP (Petty Enterprises)'. Other cells only have the value of the Owner listed, such as 'Kyle Grealis' or the value is empty.
  .with_columns(
    
    # apply the new function to remove '-' and convert to integer
    transform_column(pl.col('start')).alias('start'),
    transform_column(pl.col('pts')).alias('pts'),
    transform_column(pl.col('laps')).alias('laps'),
    transform_column(pl.col('playoff_pts')).alias('playoff_pts'),
    
    pl.col('finish').cast(pl.Int64),
    
    # fix the car number to remove the decimal and floating point number
    # some values are: '34.0', '9-A', '42.0', '53.0', '77-A'
    pl.col('car_number')
      .map_elements(lambda value: value if not value.replace('.', '').isdigit() else value.split('.')[0], return_dtype=pl.Utf8)
      .alias('car_number'),
      
    # convert the – value in laps_led to '0' then convert to integer
    pl.col('laps_led').replace('–','0')
      .cast(pl.Float64)
      .cast(pl.Int64),
    
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
  .with_columns(
    pl.col('owner').replace('–', '')
  )
  .drop('Sponsor / Owner')
).select(
  'season', 'race', 'site', 'track', 'track_length', 'track_type',
  'finish', 'start', 'driver', 'car_number', 'owner', 'sponsor',
  'laps', 'laps_led', 'status', 'money', 'pts', 'playoff_pts', 'win'
)


# %%

'''
Calculating statistics for the driver's results by season.
'''
driver_season = (
  cup
  .group_by('driver', 'season', maintain_order=True).agg(
    
    total_races = pl.count('driver'),
    
    wins = pl.col('win').sum(),
    
    best_start = pl.col('start').min(),
    worst_start = pl.col('start').max(),
    # some seasons don't have starting position
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
  cup
  .group_by('driver', maintain_order=True).agg(
    
    total_races = pl.count('driver'),
    
    wins = pl.col('win').sum(),
    
    best_start = pl.col('start').min(),
    worst_start = pl.col('start').max(),
    # some seasons don't have starting position
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
  .sort('driver')
).select(
  'driver', 'total_races', 'wins', 'win_pct', 'avg_start', 'best_start',
  'worst_start', 'avg_finish', 'best_finish', 'worst_finish', 'avg_laps_led',
  'total_laps_led', 'most_laps_led', 'avg_points', 'avg_playoff_pts',
  'total_money', 'avg_money', 'max_race_money', 'min_race_money'
)


# %%

'''
Calculating statistics by owner.
'''
owner = (
  cup
  .group_by('owner', maintain_order=True).agg(
    
    total_races = pl.count('owner'),
    
    wins = pl.col('win').sum(),
    
    best_start = pl.col('start').min(),
    worst_start = pl.col('start').max(),
    # some seasons don't have starting position
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
  .sort('owner')
  .filter(pl.col('owner') != '')
).select(
  'owner', 'total_races', 'wins', 'win_pct', 'avg_start', 'best_start',
  'worst_start', 'avg_finish', 'best_finish', 'worst_finish', 'avg_laps_led',
  'total_laps_led', 'most_laps_led', 'avg_points', 'avg_playoff_pts',
  'total_money', 'avg_money', 'max_race_money', 'min_race_money'
)



# %%
