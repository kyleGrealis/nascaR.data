# %%

import numpy as np
import pandas as pd
from selenium import webdriver
from bs4 import BeautifulSoup
import os

# function to get the race results informaton
def race_results(driver, race_link, season, race_num, track):
  
    driver.get(race_link)
    
    # get the HTML of the page and parse with BeautifulSoup
    soup = BeautifulSoup(driver.page_source, 'html.parser')
    
    # select only the table with class 'race-results-tbl'
    table = soup.select_one('.race-results-tbl')
    
    # convert the table to a pandas DataFrame
    race_table = pd.read_html(str(table))[0]
    
    # convert all numeric columns to float
    for col in race_table.columns:
        if race_table[col].dtype == 'int64' or race_table[col].dtype == 'float64':
            race_table[col] = race_table[col].astype('float64')
    
    # save the original column names
    original_columns = race_table.columns.tolist()

    # add season, race number, and site to the DataFrame
    race_table['Season'] = season
    race_table['Race'] = race_num
    race_table['Track'] = track

    # reorder the columns
    race_table = race_table[['Season', 'Race', 'Track'] + original_columns]

    return race_table

# function to get all season race results from start to stop year
def truck_racing(start, stop):
    
    base_url = 'https://www.racing-reference.info/season-stats/{}/C/'
    
    seasons = list(np.arange(start, stop+1))
    
    all_race_tables = []
    
    # open firefox
    driver = webdriver.Firefox()
    
    for season in seasons:
        season_race_tables = []
        
        driver.get(base_url.format(season))
        
        # get the HTML of the page and parse with BeautifulSoup
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        # get each race link
        divs = soup.find_all('div', class_='race-number')
        race_links = [a['href'] for div in divs for a in div.find_all('a')]
        
        # get the race track name
        track_divs = soup.find_all('div', class_='track')
        tracks = [a.text for div in track_divs for a in div.find_all('a')]
        
        # get race info for each race
        for i, race_link in enumerate(race_links):
            race_table = race_results(driver, race_link, season, i+1, tracks[i])
            season_race_tables.append(race_table)
        
        # concatenate all race tables into one dataframe for the season
        season_df = pd.concat(season_race_tables)
        
        # save the dataframe for the season to a CSV file
        season_df.to_csv(
            os.path.join('data', 'truck-series', f'trucks-{season}.csv'), 
            index=False
        )
        
        # add the season data to the main data
        all_race_tables.append(season_df)
        
    # close Firefox after scraping the season info
    driver.quit()
    
    # concatenate all race tables into one dataframe
    all_races_df = pd.concat(all_race_tables)
    
    # save the main dataframe to a CSV file
    all_races_df.to_csv(
        os.path.join('data', 'truck-series', 'all-truck-series-results.csv'), 
        index=False
    )
    
    return all_races_df


# %%
# test
# trucks = truck_racing(1995, 1996)

# %%
import time
start_time = time.time()

trucks = truck_racing(1995, 2024)

end_time = time.time()

print(f'The process took {end_time-start_time} seconds.')



# %%
import polars as pl
trucks_pl = pl.from_pandas(trucks)