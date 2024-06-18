
# %%
import polars as pl

'''
Calculating statistics for the driver's results by season.
'''
def season(df):
  
  driver = (
    df
    .group_by('driver', 'season', maintain_order=True).agg(
      
      season_races = pl.count('driver'),
      
      season_wins = pl.col('win').sum(),
      
      season_best_start = pl.col('start').min(),
      season_worst_start = pl.col('start').max(),
      season_avg_start = pl.col('start').drop_nans().mean().round(2),
      
      season_best_finish = pl.col('finish').min(),
      season_worst_finish = pl.col('finish').max(),
      season_avg_finish = pl.col('finish').mean().round(2),
      
      season_most_laps_led = pl.col('laps_led').max(),
      season_avg_laps_led = pl.col('laps_led').drop_nans().mean().round(2),
      season_total_laps_led = pl.col('laps_led').sum(),
      
      season_avg_points = pl.col('pts').drop_nans().mean().round(2),
      
      # playoff points started in 2017
      season_avg_playoff_pts = pl.col('playoff_pts').drop_nans().mean().round(2),
      
      # money results aren't collected after the 2015 season
      season_total_money = pl.col('money').sum().cast(pl.Int64),
      season_avg_money = pl.col('money').mean().round(0).cast(pl.Int64),
      
      season_max_race_money = pl.col('money').max().cast(pl.Int64),
      season_min_race_money = pl.col('money').min().cast(pl.Int64)
    )
    .with_columns(
      season_win_pct = (
        pl.col('season_wins') / pl.col('season_races')
      ).cast(pl.Float64).round(5)
    )
  ).select(
    'season', 'driver', 'season_races', 'season_wins', 'season_win_pct', 
    'season_avg_start', 'season_best_start', 'season_worst_start',
    'season_avg_finish', 'season_best_finish', 'season_worst_finish',
    'season_avg_laps_led', 'season_total_laps_led', 'season_most_laps_led',
    'season_avg_points', 'season_avg_playoff_pts', 'season_total_money', 
    'season_avg_money', 'season_max_race_money', 'season_min_race_money'
  ).sort('season', 'season_wins', descending=[False, True])

  return driver


# %%

'''
Calculating statistics for the driver's results by career.
'''
def overall(df):
  driver = (
    df
    .group_by('driver', maintain_order=True).agg(
      
      career_races = pl.count('driver'),
      
      career_wins = pl.col('win').sum(),
      
      career_best_start = pl.col('start').min(),
      career_worst_start = pl.col('start').max(),
      career_avg_start = pl.col('start').drop_nans().mean().round(2),
      
      career_best_finish = pl.col('finish').min(),
      career_worst_finish = pl.col('finish').max(),
      career_avg_finish = pl.col('finish').mean().round(2),
      
      career_most_laps_led = pl.col('laps_led').max(),
      career_avg_laps_led = pl.col('laps_led').drop_nans().mean().round(2),
      career_total_laps_led = pl.col('laps_led').sum(),
      
      # money results aren't collected after the 2015 season
      career_total_money = pl.col('money').sum().cast(pl.Int64),
      career_avg_money = pl.col('money').mean().round(0).cast(pl.Int64),
      
      career_max_race_money = pl.col('money').max().cast(pl.Int64),
      career_min_race_money = pl.col('money').min().cast(pl.Int64)
    )
    .with_columns(
      career_win_pct = (pl.col('career_wins') / pl.col('career_races')).cast(pl.Float64).round(5)
    )
  ).select(
    'driver', 'career_races', 'career_wins', 'career_win_pct', 'career_avg_start', 
    'career_best_start', 'career_worst_start', 'career_avg_finish',
    'career_best_finish', 'career_worst_finish', 'career_avg_laps_led',
    'career_total_laps_led', 'career_most_laps_led', 'career_total_money',
    'career_avg_money', 'career_max_race_money', 'career_min_race_money'
  ).sort('driver')

  return driver