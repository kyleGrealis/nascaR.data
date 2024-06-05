'''
This is the data cleaning script for NASCAR Cup series data. Some level of data exploration is necessary, but the primary purpose is to clean the data and create new variables.
'''

# %%
import numpy as np
import pandas as pd
import polars as pl
import re


# %%
cup = (
  pl.read_csv('data/cup-series/all-cup-series-results.csv', ignore_errors=True)
  .rename({
    'Pos': 'Finish',
    'St': 'Start',
    '#': 'Car_number',
    'Car': 'Car_model'
  })
  .with_columns(
    pl.col('Sponsor / Owner').fill_null('').alias('Sponsor / Owner'),
    pl.col('Car_model').fill_null('').alias('Car_model'),
    pl.col('Status').fill_null('').alias('Status')
  )
  .with_columns(
      # create 'Sponsor' column by removing content within parentheses and strip whitespace, or set to empty string if no parentheses
      pl.col('Sponsor / Owner')
      .map_elements(lambda value: re.sub(r'\(.*?\)', '', value).strip() if re.search(r'\(.*?\)', value) else "", return_dtype=pl.Utf8) 
      .alias('Sponsor')
    )
    .with_columns(
      # create 'Owner' column by extracting content within parentheses or using the entire value if no parentheses
      pl.col('Sponsor / Owner')
      .map_elements(lambda value: re.search(r'\((.*?)\)', value).group(1) if re.search(r'\((.*?)\)', value) else value, return_dtype=pl.Utf8)
      .alias('Owner')
    )
)




# %%
