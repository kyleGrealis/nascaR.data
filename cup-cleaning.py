'''
This is the data cleaning script for NASCAR Cup series data. Some level of data exploration is necessary, but the primary purpose is to clean the data and create new variables.
'''

# %%
import numpy as np
import pandas as pd
import polars as pl
import re


# %%
df = (
  pl.read_csv('data/cup-series/all-cup-series-results.csv', ignore_errors=True)
)

# %%
df.select(
  pl.n_unique('Track').alias('total_tracks'),
  pl.n_unique('Driver').alias('total_drivers'),
  pl.n_unique('Car').alias('total_cars'),
  pl.n_unique('Status').alias('total_status'),
  pl.col('Money').sum().alias('total_money_awarded')
)


# %%

(
  df
  .rename({
    'Season': 'season',
    'Race': 'race',
    'Track': 'track',
    'Pos': 'Finish',
    'St': 'Start',
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
    # create 'Sponsor' column by removing content within parentheses and strip whitespace, or set to empty string if no parentheses meaning there is no sponsor but only owner information in "Sponsor / Owner" variable.
    pl.col('Sponsor / Owner')
    .map_elements(lambda value: re.sub(r'\(.*?\)', '', value).strip() if re.search(r'\(.*?\)', value) else "", return_dtype=pl.Utf8) 
    .alias('Sponsor'),
    
     # Create 'Owner' column by extracting content within parentheses or using the entire value if no parentheses. When the original "Sponsor / Owner" value is blank, neither new variable will have a value entered and will remain blank.
    pl.col('Sponsor / Owner')
    .map_elements(lambda value: re.search(r'\((.*?)\)', value).group(1) if re.search(r'\((.*?)\)', value) else value, return_dtype=pl.Utf8)
    .alias('Owner')
  )
)



# TODO: create new variables
# TODO: consider making per driver stats
# TODO: consider making per owner stats
