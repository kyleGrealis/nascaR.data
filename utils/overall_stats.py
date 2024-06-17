# %%
import polars as pl


def overall_stats(df, type, group_key): 
  
  prefix = 'owner' if group_key == 'owner' else 'mfg'
  
  races_per_vehicle = df.group_by(group_key, 'season', 'race').agg(
    race_count = pl.count('race')
  ).group_by(group_key).agg(
      **{
        f'{prefix}_overall_races': pl.count('race')
      }
  )

  overall = (
    df
    .group_by(group_key, maintain_order=True).agg(
      **{
        f'{prefix}_overall_{type}s_raced': pl.count(group_key),
        f'{prefix}_overall_wins': pl.col('win').sum(),
        f'{prefix}_overall_avg_start': pl.col('start').drop_nans().mean().round(2),
        f'{prefix}_overall_avg_finish': pl.col('finish').mean().round(2),
        f'{prefix}_overall_avg_laps_led': pl.col('laps_led').drop_nans().mean().round(2),
        f'{prefix}_overall_laps_led': pl.col('laps_led').sum(),
      }      
    )
    .join(races_per_vehicle, on=group_key, how='left')
    .with_columns(
      **{
        f'{prefix}_overall_win_pct': (pl.col(f'{prefix}_overall_wins') / pl.col(f'{prefix}_overall_races'))
        .cast(pl.Float64).round(5),
        f'{prefix}_overall_{type}_win_pct': (pl.col(f'{prefix}_overall_wins') / pl.col(f'{prefix}_overall_{type}s_raced')).cast(pl.Float64).round(5)
      }
    )
    .sort(group_key)
  ).select(
    group_key, 
    f'{prefix}_overall_races', 
    f'{prefix}_overall_wins', 
    f'{prefix}_overall_win_pct', 
    f'{prefix}_overall_{type}s_raced', 
    f'{prefix}_overall_{type}_win_pct', 
    f'{prefix}_overall_avg_start', 
    f'{prefix}_overall_avg_finish',
    f'{prefix}_overall_laps_led',
    f'{prefix}_overall_avg_laps_led' 
  )
  
  return overall
