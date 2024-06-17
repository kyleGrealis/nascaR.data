# %%

def season_stats(df, type, group_key):
  
  prefix = 'owner' if group_key == 'owner' else 'mfg'
   
  season = (
    df
    .group_by(group_key, 'season', maintain_order=True).agg(
      **{
        f'{prefix}_season_races': pl.col('race').n_unique(),
        f'{prefix}_season_wins': pl.col('win').sum(),
        f'{prefix}_season_{type}s_raced': pl.count(group_key),
        f'{prefix}_season_avg_start': pl.col('start').drop_nans().mean().round(2),
        f'{prefix}_season_avg_finish': pl.col('finish').mean().round(2),
        f'{prefix}_season_laps_led': pl.col('laps_led').sum(),
        f'{prefix}_season_avg_laps_led': pl.col('laps_led').drop_nans().mean().round(2)
      }      
    )
    .with_columns(
      **{
        f'{prefix}_season_win_pct': (pl.col(f'{prefix}_season_wins') / pl.col(f'{prefix}_season_races')).cast(pl.Float64).round(5),
        f'{prefix}_season_{type}_win_pct': (pl.col(f'{prefix}_season_wins') / pl.col(f'{prefix}_season_{type}s_raced')).cast(pl.Float64).round(5)
      }
    )
    .sort('season', group_key)
  ).select(
    group_key, 
    'season',
    f'{prefix}_season_races',
    f'{prefix}_season_wins', 
    f'{prefix}_season_win_pct', 
    f'{prefix}_season_{type}s_raced', 
    f'{prefix}_season_{type}_win_pct', 
    f'{prefix}_season_avg_start', 
    f'{prefix}_season_avg_finish',
    f'{prefix}_season_avg_laps_led', 
    f'{prefix}_season_laps_led'
  )
  
  return season