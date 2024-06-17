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
    'Truck': 'manufacturer',
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
  'finish', 'start', 'driver', 'manufacturer', 'truck_number', 'owner', 'sponsor',
  'laps', 'laps_led', 'status', 'money', 'pts', 'playoff_pts', 'win'
)



# %%
def overall_stats(df, type, group_key): 
  
  prefix = 'owner' if group_key == 'owner' else 'mfg'
  
  races_per_vehicle = df.group_by(group_key, 'season', 'race').agg(
    race_count = pl.count('race')
  ).group_by(group_key).agg(
      **{
        f'{prefix}_overall_races': pl.count('race')
      }
  )

  overall = (
    df
    .group_by(group_key, maintain_order=True).agg(
      **{
        f'{prefix}_overall_{type}s_raced': pl.count(group_key),
        f'{prefix}_overall_wins': pl.col('win').sum(),
        f'{prefix}_overall_avg_start': pl.col('start').drop_nans().mean().round(2),
        f'{prefix}_overall_avg_finish': pl.col('finish').mean().round(2),
        f'{prefix}_overall_avg_laps_led': pl.col('laps_led').drop_nans().mean().round(2),
        f'{prefix}_overall_laps_led': pl.col('laps_led').sum(),
      }      
    )
    .join(races_per_vehicle, on=group_key, how='left')
    .with_columns(
      **{
        f'{prefix}_overall_win_pct': (pl.col(f'{prefix}_overall_wins') / pl.col(f'{prefix}_overall_races'))
        .cast(pl.Float64).round(5),
        f'{prefix}_overall_{type}_win_pct': (pl.col(f'{prefix}_overall_wins') / pl.col(f'{prefix}_overall_{type}s_raced')).cast(pl.Float64).round(5)
      }
    )
    .sort(group_key)
  ).select(
    group_key, 
    f'{prefix}_overall_races', 
    f'{prefix}_overall_wins', 
    f'{prefix}_overall_win_pct', 
    f'{prefix}_overall_{type}s_raced', 
    f'{prefix}_overall_{type}_win_pct', 
    f'{prefix}_overall_avg_start', 
    f'{prefix}_overall_avg_finish',
    f'{prefix}_overall_laps_led',
    f'{prefix}_overall_avg_laps_led' 
  )
  
  return overall

# %%

mfg_overall = overall_stats(truck, 'truck', 'manufacturer')
own_overall = overall_stats(truck, 'truck', 'owner')



# %%

def season_stats(df, type, group_key):
  
  prefix = 'owner' if group_key == 'owner' else 'mfg'
   
  season = (
    df
    .group_by(group_key, 'season', maintain_order=True).agg(
      **{
        f'{prefix}_season_races': pl.col('race').n_unique(),
        f'{prefix}_season_wins': pl.col('win').sum(),
        f'{prefix}_season_{type}s_raced': pl.count(group_key),
        f'{prefix}_season_avg_start': pl.col('start').drop_nans().mean().round(2),
        f'{prefix}_season_avg_finish': pl.col('finish').mean().round(2),
        f'{prefix}_season_laps_led': pl.col('laps_led').sum(),
        f'{prefix}_season_avg_laps_led': pl.col('laps_led').drop_nans().mean().round(2)
      }      
    )
    .with_columns(
      **{
        f'{prefix}_season_win_pct': (pl.col(f'{prefix}_season_wins') / pl.col(f'{prefix}_season_races')).cast(pl.Float64).round(5),
        f'{prefix}_season_{type}_win_pct': (pl.col(f'{prefix}_season_wins') / pl.col(f'{prefix}_season_{type}s_raced')).cast(pl.Float64).round(5)
      }
    )
    .sort('season', group_key)
  ).select(
    group_key, 
    'season',
    f'{prefix}_season_races',
    f'{prefix}_season_wins', 
    f'{prefix}_season_win_pct', 
    f'{prefix}_season_{type}s_raced', 
    f'{prefix}_season_{type}_win_pct', 
    f'{prefix}_season_avg_start', 
    f'{prefix}_season_avg_finish',
    f'{prefix}_season_avg_laps_led', 
    f'{prefix}_season_laps_led'
  )
  
  return season


# %%
mfg_season = season_stats(truck, 'truck', 'manufacturer')
own_season = season_stats(truck, 'truck', 'owner')













# %%

# storing the cleaned datasets
truck.write_csv('data/truck-series/truck-results.csv')

driver_career.write_csv('data/truck-series/truck-driver-career.csv')
driver_season.write_csv('data/truck-series/truck-driver-season.csv')

owner.write_csv('data/truck-series/truck-owner.csv')

manufacturer_overall.write_csv('data/truck-series/truck-manufacturer-overall.csv')
manufacturer_season.write_csv('data/truck-series/truck-manufacturer-season.csv')

# %%
