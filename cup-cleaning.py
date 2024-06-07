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
  # note: The sponsor information exists outside the parentesis if there are parenthesis in the string, such as "STP (Petty Enterprises)". Other cells only have the value of the Owner listed, such as "Kyle Grealis" or the value is empty.
  .with_columns(
    # create 'Sponsor' column by removing content within parentheses and strip whitespace, or set to empty string if no parentheses meaning there is no sponsor but only owner information in "Sponsor / Owner" variable.
    pl.col('Sponsor / Owner')
    .map_elements(lambda value: re.sub(r'\(.*?\)', '', value).strip() if re.search(r'\(.*?\)', value) else "", return_dtype=pl.Utf8) 
    .alias('Sponsor')
  )
  .with_columns(
    # Create 'Owner' column by extracting content within parentheses or using the entire value if no parentheses. When the original "Sponsor / Owner" value is blank, neither new variable will have a value entered and will remain blank.
    pl.col('Sponsor / Owner')
    .map_elements(lambda value: re.search(r'\((.*?)\)', value).group(1) if re.search(r'\((.*?)\)', value) else value, return_dtype=pl.Utf8)
    .alias('Owner')
  )
)


# TODO: create new variables
# TODO: consider making per driver stats
# TODO: consider making per owner stats

# %%
import numpy as np
import pandas as pd
import re
import siuba as ss

# %%
data_in = pl.read_csv(
  'data/cup-series/all-cup-series-results.csv', ignore_errors=True
)

# %%
mitter = (
  data_in
  # .select('Pos', 'St', 'Car', 'Sponsor / Owner')
  .with_columns(
    
    pl.col('Sponsor / Owner').fill_null('').alias('Sponsor / Owner'),
    pl.col('Car').fill_null('').alias('Car_model'),
    pl.col('Status').fill_null('').alias('Status'),
    
    pl.col('Sponsor / Owner')
    .map_elements(lambda value: re.sub(r'\(.*?\)', '', value).strip() if re.search(r'\(.*?\)', value) else "", return_dtype=pl.Utf8) 
    .alias('Sponsor'),
   
    # pl.col('Sponsor / Owner')
    # .map_elements(lambda value: re.search(r'\((.*?)\)', value).group(1) if re.search(r'\((.*?)\)', value) else value, return_dtype=pl.Utf8)
    # .alias('Owner')
  )
).head()

# %%
