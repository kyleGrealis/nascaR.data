
# %%
import glob
import os
import polars as pl
import re

# from processing_scripts.cup_processing import *
from processing_scripts.xfinity_processing import *
from processing_scripts.truck_processing import *

# use project modules
from utils.season_stats import *
from utils.overall_stats import *
from utils.driver_stats import *



# %%
# cup series
cup = process_cup_data()

driver_season = season(cup)
driver_overall = overall(cup)
mfg_overall = overall_stats(cup, 'car', 'manufacturer')
owner_overall = overall_stats(cup, 'car', 'owner')
mfg_season = season_stats(cup, 'car', 'manufacturer')
owner_season = season_stats(cup, 'car', 'owner')


# %%
# xfinity series
xfinity = process_xfinity_data()

driver_season = season(xfinity)
driver_overall = overall(xfinity)
mfg_overall = overall_stats(xfinity, 'car', 'manufacturer')
owner_overall = overall_stats(xfinity, 'car', 'owner')
mfg_season = season_stats(xfinity, 'car', 'manufacturer')
owner_season = season_stats(xfinity, 'car', 'owner')


# %%
# truck series
truck = process_truck_data()

driver_season = season(truck)
driver_overall = overall(truck)
mfg_overall = overall_stats(truck, 'truck', 'manufacturer')
owner_overall = overall_stats(truck, 'truck', 'owner')
mfg_season = season_stats(truck, 'truck', 'manufacturer')
owner_season = season_stats(truck, 'truck', 'owner')


# %%
'''
The imported `cup`, `xfinity` & `truck` datasets consists of individual race results for all seasons listed by driver.
'''

cup.write_csv('data/cup-series/cleaned/race_data.csv')
driver_season.write_csv('data/cup-series/cleaned/driver_season.csv')
driver_overall.write_csv('data/cup-series/cleaned/driver_career.csv')
owner_season.write_csv('data/cup-series/cleaned/owner_season.csv')
owner_overall.write_csv('data/cup-series/cleaned/owner_career.csv')
mfg_season.write_csv('data/cup-series/cleaned/mfg_season.csv')
mfg_overall.write_csv('data/cup-series/cleaned/mfg_overall.csv')

xfinity.write_csv('data/xfinity-series/cleaned/race_data.csv')
driver_season.write_csv('data/xfinity-series/cleaned/driver_season.csv')
driver_overall.write_csv('data/xfinity-series/cleaned/driver_career.csv')
owner_season.write_csv('data/xfinity-series/cleaned/owner_season.csv')
owner_overall.write_csv('data/xfinity-series/cleaned/owner_career.csv')
mfg_season.write_csv('data/xfinity-series/cleaned/mfg_season.csv')
mfg_overall.write_csv('data/xfinity-series/cleaned/mfg_overall.csv')

truck.write_csv('data/truck-series/cleaned/race_data.csv')
driver_season.write_csv('data/truck-series/cleaned/driver_season.csv')
driver_overall.write_csv('data/truck-series/cleaned/driver_career.csv')
owner_season.write_csv('data/truck-series/cleaned/owner_season.csv')
owner_overall.write_csv('data/truck-series/cleaned/owner_career.csv')
mfg_season.write_csv('data/truck-series/cleaned/mfg_season.csv')
mfg_overall.write_csv('data/truck-series/cleaned/mfg_overall.csv')

# %%
# test joining all data as possible starting dataset for modeling
# test = (
#   truck
#   .join(driver_season, on=['driver', 'season'])
#   .join(driver_overall, on='driver')
#   .join(owner_season, on=['owner', 'season'])
#   .join(owner_overall, on='owner')
#   .join(mfg_season, on=['manufacturer', 'season'])
#   .join(mfg_overall, on='manufacturer')
# )