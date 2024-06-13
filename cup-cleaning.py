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
# specify data types
dtypes = {
  'Season': 'int64',
  'Race': 'int64',
  'Site': 'str',
  'Track': 'str',
  'Track_length': 'float64',
  'Track_type': 'str',
  'Pos': 'int64',
  'St': 'object',  # changed from 'float64'
  '#': 'str',  # changed from 'float64'
  'Driver': 'str',
  'Sponsor / Owner': 'str',
  'Car': 'str',
  'Laps': 'object',  # changed from 'float64'
  'Money': 'float64',
  'Status': 'str',
  'Led': 'object',  # changed from 'float64'
  'Pts': 'float64',
  'PPts': 'float64'
}

# read each CSV file into a Pandas DataFrame and add it to a list
all_race_tables = [
  pd.read_csv(file, dtype=dtypes) for file in glob.glob(os.path.join('data', 'cup-series', 'cup-*.csv'))
]

# convert columns to numeric, replacing non-numeric values with NaN
for df in all_race_tables:
  df['St'] = pd.to_numeric(df['St'], errors='coerce')
  # df['#'] = pd.to_numeric(df['#'], errors='coerce')
  df['Laps'] = pd.to_numeric(df['Laps'], errors='coerce').astype('int')
  df['Led'] = pd.to_numeric(df['Led'], errors='coerce')

# concat all DataFrames in the list to one DataFrame
all_races_df = pl.from_pandas(pd.concat(all_race_tables))



# %%
df.select(
  pl.n_unique('Track').alias('total_tracks'),
  pl.n_unique('Driver').alias('total_drivers'),
  pl.n_unique('Car').alias('total_cars'),
  pl.n_unique('Status').alias('total_status'),
  pl.col('Money').sum().alias('total_money_awarded')
)


# %%

cup = (
  df
  .rename({
    'Season': 'season',
    'Race': 'race',
    'Track': 'track',
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
  # note: The sponsor information exists outside the parentesis if there are parenthesis in the string, such as "STP (Petty Enterprises)". Other cells only have the value of the Owner listed, such as "Kyle Grealis" or the value is empty.
  .with_columns(
    
    pl.col('pts').cast(pl.Int32),
    pl.col('playoff_pts').cast(pl.Int32),
    
    # create 'Sponsor' column by removing content within parentheses and strip whitespace, or set to empty string if no parentheses meaning there is no sponsor but only owner information in "Sponsor / Owner" variable.
    pl.col('Sponsor / Owner')
    .map_elements(lambda value: re.sub(r'\(.*?\)', '', value).strip() if re.search(r'\(.*?\)', value) else "", return_dtype=pl.Utf8) 
    .alias('Sponsor'),
    
     # Create 'Owner' column by extracting content within parentheses or using the entire value if no parentheses. When the original "Sponsor / Owner" value is blank, neither new variable will have a value entered and will remain blank.
    pl.col('Sponsor / Owner')
    .map_elements(lambda value: re.search(r'\((.*?)\)', value).group(1) if re.search(r'\((.*?)\)', value) else value, return_dtype=pl.Utf8)
    .alias('Owner')
  )
  .drop('Sponsor / Owner')
)


# %%
# TODO: create new variables
# TODO: consider making per driver stats

'''
Calculating statistics for the driver's results by season.
'''
driver_season = (
  cup
  .group_by('driver', 'season', maintain_order=True).agg(
    
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
    total_money = pl.col('money').sum(),
    avg_money = pl.col('money').mean().round(0).cast(pl.UInt64),
    
    max_race_money = pl.col('money').max(),
    min_race_money = pl.col('money').min()
  )
  # .filter(pl.col('season_avg_money') > 0)
  # .filter(pl.col('avg_playoff_pts') > 0)
  .filter(pl.col('season') == 2015)
  .sort('season', 'avg_finish')
)

driver_season


# %%