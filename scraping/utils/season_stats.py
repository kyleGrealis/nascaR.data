import polars as pl

def season_stats(df, type, group_key):
    """
    Calculate season statistics for a given DataFrame.

    Args:
      df (DataFrame): The input DataFrame containing race data.
      type (str): The type of statistics to calculate (e.g., 'car' or 'truck').
      group_key (str): The key to group the data by (e.g., 'owner', 'mfg').

    Returns:
      DataFrame: The DataFrame containing the overall statistics.

    """
    prefix = 'owner' if group_key == 'owner' else 'mfg'
     
    season = (
        df
        .group_by(group_key, 'season', maintain_order=True).agg(
            **{
                # Count unique races per season for each owner/manufacturer
                f'{prefix}_season_races': pl.n_unique('race'),
                f'{prefix}_season_wins': pl.col('win').sum(),
                f'{prefix}_season_top_5': pl.col('top_5').sum(),
                f'{prefix}_season_top_10': pl.col('top_10').sum(),
                f'{prefix}_season_top_20': pl.col('top_20').sum(),
                # Count total entries (cars/trucks) per season
                f'{prefix}_season_{type}s_raced': pl.count(group_key),
                # Calculate average start position, ignoring NaN values
                f'{prefix}_season_avg_start': pl.col('start').drop_nans().mean().round(2),
                # Calculate average finish position
                f'{prefix}_season_avg_finish': pl.col('finish').mean().round(2),
                # Sum total laps led
                f'{prefix}_season_laps_led': pl.col('laps_led').sum(),
                # Calculate average laps led, ignoring NaN values
                f'{prefix}_season_avg_laps_led': pl.col('laps_led').drop_nans().mean().round(2)
            }      
        )
        .with_columns(
            **{
                # Calculate win percentage based on unique races
                f'{prefix}_season_win_pct': (pl.col(f'{prefix}_season_wins') / pl.col(f'{prefix}_season_races')).cast(pl.Float64).round(5),
                # Calculate win percentage based on total entries
                f'{prefix}_season_{type}_win_pct': (pl.col(f'{prefix}_season_wins') / pl.col(f'{prefix}_season_{type}s_raced')).cast(pl.Float64).round(5)
            }
        )
        .sort('season', group_key)
    ).select(
        group_key, 
        'season',
        f'{prefix}_season_races',
        f'{prefix}_season_{type}s_raced',  # Added to show total entries alongside unique races
        f'{prefix}_season_wins',
        f'{prefix}_season_win_pct', 
        f'{prefix}_season_{type}_win_pct', 
        f'{prefix}_season_top_5',
        f'{prefix}_season_top_10',
        f'{prefix}_season_top_20',
        f'{prefix}_season_avg_start', 
        f'{prefix}_season_avg_finish',
        f'{prefix}_season_laps_led',
        f'{prefix}_season_avg_laps_led'
    )
    
    return season