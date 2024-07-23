
# %%
import polars as pl

'''
Calculating statistics for the driver's results by season.
'''
def season(df):
  """
  Calculates various statistics for each driver in a given season.

  Parameters:
  - df: DataFrame
    The input DataFrame containing race data.

  Returns:
  - driver: DataFrame
    The resulting DataFrame with the following columns:
    - season: int
      The season year.
    - driver: str
      The driver's name.
    - season_races: int
      The number of races the driver participated in during the season.
    - season_wins: int
      The number of races the driver won during the season.
    - season_win_pct: float
      The win percentage of the driver during the season.
    - season_top_5: int
      The number of top 5 finishes the driver had during the season.
    - season_top_5_pct: float
      The top 5 finish percentage of the driver during the season.
    - season_top_10: int
      The number of top 10 finishes the driver had during the season.
    - season_top_10_pct: float
      The top 10 finish percentage of the driver during the season.
    - season_top_20: int
      The number of top 20 finishes the driver had during the season.
    - season_top_20_pct: float
      The top 20 finish percentage of the driver during the season.
    - season_avg_start: float
      The average starting position of the driver during the season.
    - season_best_start: int
      The best starting position of the driver during the season.
    - season_worst_start: int
      The worst starting position of the driver during the season.
    - season_avg_finish: float
      The average finishing position of the driver during the season.
    - season_best_finish: int
      The best finishing position of the driver during the season.
    - season_worst_finish: int
      The worst finishing position of the driver during the season.
    - season_avg_laps_led: float
      The average number of laps led by the driver during the season.
    - season_total_laps_led: int
      The total number of laps led by the driver during the season.
    - season_most_laps_led: int
      The most laps led by the driver in a single race during the season.
    - season_avg_points: float
      The average number of points earned by the driver during the season.
    - season_avg_playoff_pts: float
      The average number of playoff points earned by the driver during the season.
    - season_total_money: int
      The total amount of money earned by the driver during the season.
    - season_avg_money: int
      The average amount of money earned by the driver per race during the season.
    - season_max_race_money: int
      The maximum amount of money earned by the driver in a single race during the season.
    - season_min_race_money: int
      The minimum amount of money earned by the driver in a single race during the season.

  """
  driver = (
    df
    .group_by('driver', 'season', maintain_order=True).agg(
      
      season_races = pl.count('driver'),
      
      season_wins = pl.col('win').sum(),
      season_top_5 = pl.col('top_5').sum(),
      season_top_10 = pl.col('top_10').sum(),
      season_top_20 = pl.col('top_20').sum(),
      
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
      ).cast(pl.Float64).round(5),
      season_top_5_pct = (
        pl.col('season_top_5') / pl.col('season_races')
      ).cast(pl.Float64).round(5),
      season_top_10_pct = (
        pl.col('season_top_10') / pl.col('season_races')
      ).cast(pl.Float64).round(5),
      season_top_20_pct = (
        pl.col('season_top_20') / pl.col('season_races')
      ).cast(pl.Float64).round(5)
    )
  ).select(
    'season', 'driver', 'season_races', 'season_wins', 'season_win_pct', 
    'season_top_5', 'season_top_5_pct', 'season_top_10', 'season_top_10_pct',
    'season_top_20', 'season_top_20_pct',
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
      career_top_5 = pl.col('top_5').sum(),
      career_top_10 = pl.col('top_10').sum(),
      career_top_20 = pl.col('top_20').sum(),
      
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
      career_win_pct = (pl.col('career_wins') / pl.col('career_races')).cast(pl.Float64).round(5),
      career_top_5_pct = (
        pl.col('career_top_5') / pl.col('career_races')
      ).cast(pl.Float64).round(5),
      career_top_10_pct = (
        pl.col('career_top_10') / pl.col('career_races')
      ).cast(pl.Float64).round(5),
      career_top_20_pct = (
        pl.col('career_top_20') / pl.col('career_races')
      ).cast(pl.Float64).round(5),
    )
  ).select(
    'driver', 'career_races', 'career_wins', 'career_win_pct', 
    'career_top_5', 'career_top_5_pct', 
    'career_top_10', 'career_top_10_pct',
    'career_top_20', 'career_top_20_pct',
    'career_avg_start', 
    'career_best_start', 'career_worst_start', 'career_avg_finish',
    'career_best_finish', 'career_worst_finish', 'career_avg_laps_led',
    'career_total_laps_led', 'career_most_laps_led', 'career_total_money',
    'career_avg_money', 'career_max_race_money', 'career_min_race_money'
  ).sort('driver')

  return driver