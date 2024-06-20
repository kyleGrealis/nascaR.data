'''
This is the data cleaning script for NASCAR Cup series data. Some level of data exploration is necessary, but the primary purpose is to clean the data and create new variables.

The script reads in a main racing results CSV file, performs data cleaning operations, and creates new variables based on the existing columns. The cleaned and processed data is then returned as a DataFrame.

Functions:
- transform_column: A helper function to transform a column that contains '-' to an integer.
- process_cup_data: The main function that processes the cup data and returns the cleaned DataFrame.

Usage:
1. Import the necessary libraries.
2. Call the process_cup_data() function to process the cup data.

Example:
df = process_cup_data()
'''

# %%
import polars as pl
import glob
import os
import re

from utils.season_stats import *
from utils.overall_stats import *
from utils.driver_stats import *


# %%

# read in the main racing results CSV
df = pl.read_csv(
  'data/cup-series/scraped/cup-series-full-import.csv', infer_schema_length=10000
)


# %%
# function to transform a column that contains '-' to integer
def transform_column(col):
    return col.replace('–', None).cast(pl.Float64).cast(pl.Int64)


# %%
def process_cup_data():
  '''
  Process the cup data and return the cleaned DataFrame.

  Returns:
  - cup: A DataFrame containing the cleaned and processed cup data.
  '''
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
      'Car': 'manufacturer',
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
        
        # create a 0/1 win column  
      pl.when(pl.col('finish') == 1)
        .then(1)
        .otherwise(0)
        .cast(pl.Int64)
        .alias('win'),
      
      # create 0/1 top-5, top-10, and top-20 columns
      pl.when(pl.col('finish') <= 5)
        .then(1)
        .otherwise(0)
        .cast(pl.Int64)
        .alias('top_5'),
            
      pl.when(pl.col('finish') <= 10)
        .then(1)
        .otherwise(0)
        .cast(pl.Int64)
        .alias('top_10'),
            
      pl.when(pl.col('finish') <= 20)
        .then(1)
        .otherwise(0)
        .cast(pl.Int64)
        .alias('top_20'),
        
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
    'finish', 'start', 'driver', 'manufacturer', 'car_number', 
    'owner', 'sponsor', 'win', 'top_5', 'top_10', 'top_20',
    'laps', 'laps_led', 'status', 'money', 'pts', 'playoff_pts'
  )
  
  return cup


# %%
cup = process_cup_data()

driver_season = season(cup)
driver_overall = overall(cup)
mfg_overall = overall_stats(cup, 'car', 'manufacturer')
owner_overall = overall_stats(cup, 'car', 'owner')
mfg_season = season_stats(cup, 'car', 'manufacturer')
owner_season = season_stats(cup, 'car', 'owner')

# %%
# cup.write_csv('data/cup-series/cleaned/race_data.csv')
# driver_season.write_csv('data/cup-series/cleaned/driver_season.csv')
# driver_overall.write_csv('data/cup-series/cleaned/driver_career.csv')
# owner_season.write_csv('data/cup-series/cleaned/owner_season.csv')
# owner_overall.write_csv('data/cup-series/cleaned/owner_career.csv')
# mfg_season.write_csv('data/cup-series/cleaned/mfg_season.csv')
# mfg_overall.write_csv('data/cup-series/cleaned/mfg_overall.csv')
