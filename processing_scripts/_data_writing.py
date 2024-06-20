
# %%
import os
import polars as pl
import sys

# from cup_processing import *
# from xfinity_processing import *
from truck_processing import *

# use project modules
sys.path.append('..')
from utils.season_stats import *
from utils.overall_stats import *
from utils.driver_stats import *



# %%
# Truck series
truck = process_truck_data()

driver_season = season(truck)
driver_overall = overall(truck)

mfg_overall = overall_stats(truck, 'truck', 'manufacturer')
owner_overall = overall_stats(truck, 'truck', 'owner')

mfg_season = season_stats(truck, 'truck', 'manufacturer')
owner_season = season_stats(truck, 'truck', 'owner')

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