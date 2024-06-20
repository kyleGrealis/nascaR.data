
# %%
import glob
import os
import polars as pl
import re

from utils.season_stats import *
from utils.overall_stats import *
from utils.driver_stats import *


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