
# %%
import polars as pl

# TODO: functionalize this across series

'''
Calculating statistics for the driver's results by season.
'''
driver_season = (
  truck
  .group_by('driver', 'season', maintain_order=True).agg(
    
    total_races = pl.count('driver'),
    
    wins = pl.col('win').sum(),
    
    best_start = pl.col('start').min(),
    worst_start = pl.col('start').max(),
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
    total_money = pl.col('money').sum().cast(pl.Int64),
    avg_money = pl.col('money').mean().round(0).cast(pl.Int64),
    
    max_race_money = pl.col('money').max().cast(pl.Int64),
    min_race_money = pl.col('money').min().cast(pl.Int64)
  )
  .with_columns(
    win_pct = (pl.col('wins') / pl.col('total_races')).cast(pl.Float64).round(5)
  )
  .sort('season', 'avg_finish')
).select(
  'season', 'driver', 'total_races', 'wins', 'win_pct', 'avg_start', 'best_start',
  'worst_start', 'avg_finish', 'best_finish', 'worst_finish', 'avg_laps_led',
  'total_laps_led', 'most_laps_led', 'avg_points', 'avg_playoff_pts',
  'total_money', 'avg_money', 'max_race_money', 'min_race_money'
)


# %%

'''
Calculating statistics for the driver's results by career.
'''
driver_career = (
  truck
  .group_by('driver', maintain_order=True).agg(
    
    total_races = pl.count('driver'),
    
    wins = pl.col('win').sum(),
    
    best_start = pl.col('start').min(),
    worst_start = pl.col('start').max(),
    avg_start = pl.col('start').drop_nans().mean().round(2),
    
    best_finish = pl.col('finish').min(),
    worst_finish = pl.col('finish').max(),
    avg_finish = pl.col('finish').mean().round(2),
    
    most_laps_led = pl.col('laps_led').max(),
    avg_laps_led = pl.col('laps_led').drop_nans().mean().round(2),
    total_laps_led = pl.col('laps_led').sum(),
    
    # money results aren't collected after the 2015 season
    total_money = pl.col('money').sum().cast(pl.Int64),
    avg_money = pl.col('money').mean().round(0).cast(pl.Int64),
    
    max_race_money = pl.col('money').max().cast(pl.Int64),
    min_race_money = pl.col('money').min().cast(pl.Int64)
  )
  .with_columns(
    win_pct = (pl.col('wins') / pl.col('total_races')).cast(pl.Float64).round(5)
  )
  .sort('driver')
).select(
  'driver', 'total_races', 'wins', 'win_pct', 'avg_start', 'best_start',
  'worst_start', 'avg_finish', 'best_finish', 'worst_finish', 'avg_laps_led',
  'total_laps_led', 'most_laps_led',
  'total_money', 'avg_money', 'max_race_money', 'min_race_money'
)

