'''
This is the data cleaning script for NASCAR Truck series data. Some level of data exploration is necessary, but the primary purpose is to clean the data and create new variables.

The script reads in a main racing results CSV file, performs data cleaning operations, and creates new variables based on the existing columns. The cleaned and processed data is then returned as a DataFrame.

Functions:
- transform_column: A helper function to transform a column that contains '-' to an integer.
- process_truck_data: The main function that processes the truck data and returns the cleaned DataFrame.

Usage:
1. Import the necessary libraries.
2. Call the process_truck_data() function to process the truck data.

Example:
df = process_truck_data()
'''

# %%
import polars as pl
import glob
import os
import re
import sys

sys.path.append(
  os.path.abspath(
    os.path.join(os.path.dirname(__file__), '..')
  )
)

from utils.season_stats import *
from utils.overall_stats import *
from utils.driver_stats import *


# read in the main racing results CSV
df = pl.read_csv(
  '../data/truck-series/scraped/truck-series-full-import.csv', infer_schema_length=10000
)


# function to transform a column that contains '-' to integer
def transform_column(col):
    return col.replace('–', None).cast(pl.Float64).cast(pl.Int64)


# creating a function to process the truck data. this will allow the function to be called from within another script.
def process_truck_data():
  '''
  Process the truck data and return the cleaned DataFrame.

  Returns:
  - truck: A DataFrame containing the cleaned and processed truck data.
  '''
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
      # more data cleaning
      pl.when(pl.col('sponsor').is_in(['Carnes Racing']))
      .then(pl.lit('Larry Carnes Racing')).otherwise(pl.col('sponsor'))
    )
    .drop('Sponsor / Owner')
  ).select(
    'season', 'race', 'site', 'track', 'track_length', 'track_type',
    'finish', 'start', 'driver', 'manufacturer', 'truck_number', 
    'owner', 'sponsor', 'win', 'top_5', 'top_10', 'top_20',
    'laps', 'laps_led', 'status', 'money', 'pts', 'playoff_pts'
  )
  
  return truck


# %%
truck = process_truck_data()
del df

driver_season = season(truck)
driver_overall = overall(truck)
mfg_overall = overall_stats(truck, 'truck', 'manufacturer')
owner_overall = overall_stats(truck, 'truck', 'owner')
mfg_season = season_stats(truck, 'truck', 'manufacturer')
owner_season = season_stats(truck, 'truck', 'owner')

# %%
cleaned_path = '../data/truck-series/cleaned'

truck.write_csv(f'{cleaned_path}/truck_race_data.csv')
driver_season.write_csv(f'{cleaned_path}/truck_driver_season.csv')
driver_overall.write_csv(f'{cleaned_path}/truck_driver_career.csv')
owner_season.write_csv(f'{cleaned_path}/truck_owner_season.csv')
owner_overall.write_csv(f'{cleaned_path}/truck_owner_career.csv')
mfg_season.write_csv(f'{cleaned_path}/truck_mfg_season.csv')
mfg_overall.write_csv(f'{cleaned_path}/truck_mfg_overall.csv')

# %%