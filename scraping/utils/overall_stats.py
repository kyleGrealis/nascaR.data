import polars as pl

def overall_stats(df, type, group_key): 
    """
    Calculate overall statistics for a given DataFrame.

    Args:
      df (DataFrame): The input DataFrame containing race data.
      type (str): The type of statistics to calculate (e.g., 'car' or 'truck').
      group_key (str): The key to group the data by (e.g., 'owner', 'mfg').

    Returns:
      DataFrame: The DataFrame containing the overall statistics.

    """
    prefix = 'owner' if group_key == 'owner' else 'mfg'
    
    # Count unique races for each owner/manufacturer
    unique_races = df.group_by(group_key).agg(
        **{
            # Count unique combinations of season and race
            f'{prefix}_overall_races': pl.n_unique(['season', 'race'])
        }
    )

    overall = (
        df
        .group_by(group_key, maintain_order=True).agg(
            **{
                f'{prefix}_overall_{type}s_raced': pl.count(group_key),  # Total number of entries
                f'{prefix}_overall_wins': pl.col('win').sum(),
                f'{prefix}_overall_top_5': pl.col('top_5').sum(),
                f'{prefix}_overall_top_10': pl.col('top_10').sum(),
                f'{prefix}_overall_top_20': pl.col('top_20').sum(),
                f'{prefix}_overall_avg_start': pl.col('start').drop_nans().mean().round(2),
                f'{prefix}_overall_avg_finish': pl.col('finish').mean().round(2),
                f'{prefix}_overall_laps_led': pl.col('laps_led').sum(),
                f'{prefix}_overall_avg_laps_led': pl.col('laps_led').drop_nans().mean().round(2),
            }      
        )
        .join(unique_races, on=group_key, how='left')  # Join with the unique race count
        .with_columns(
            **{
                # Calculate win percentage based on unique races
                f'{prefix}_overall_win_pct': (pl.col(f'{prefix}_overall_wins') / pl.col(f'{prefix}_overall_races'))
                .cast(pl.Float64).round(5),
                # Calculate win percentage based on total entries
                f'{prefix}_overall_{type}_win_pct': (pl.col(f'{prefix}_overall_wins') / pl.col(f'{prefix}_overall_{type}s_raced'))
                .cast(pl.Float64).round(5)
            }
        )
        .sort(group_key)
    ).select(
        group_key, 
        f'{prefix}_overall_races',  # This now correctly represents unique races
        f'{prefix}_overall_{type}s_raced',  # This represents total entries
        f'{prefix}_overall_wins', 
        f'{prefix}_overall_win_pct',
        f'{prefix}_overall_{type}_win_pct', 
        f'{prefix}_overall_top_5',
        f'{prefix}_overall_top_10',
        f'{prefix}_overall_top_20',
        f'{prefix}_overall_avg_start', 
        f'{prefix}_overall_avg_finish',
        f'{prefix}_overall_laps_led',
        f'{prefix}_overall_avg_laps_led' 
    )
    
    return overall