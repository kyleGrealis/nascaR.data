# %%

import numpy as np
import pandas as pd
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from bs4 import BeautifulSoup
import os
import time
from io import StringIO

# function to get the race results informaton
def race_results(driver, race_link, season, race_num, track):
  
    # for _ in range(5):
    #   try:
    #     driver.get(race_link)
    #     break
    #   except TimeoutException:
    #     print('Current season took too long to load. Trying again...')
    #     driver.quit()
    #     time.sleep(120)
    #     driver = webdriver.Firefox()
    #     driver.get(race_link)
    
    # get the HTML of the page and parse with BeautifulSoup
    soup = BeautifulSoup(driver.page_source, 'html.parser')
    
    # select only the table with class 'race-results-tbl'
    table = soup.select_one('.race-results-tbl')
    
    # convert the table to a pandas DataFrame
    race_table = pd.read_html(StringIO(str(table)))[0]
    
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
def xfinity_racing(start, stop):
    
    base_url = 'https://www.racing-reference.info/season-stats/{}/B/'
    
    seasons = list(np.arange(start, stop+1))
    
    all_race_tables = []
    
    # open firefox
    driver = webdriver.Firefox()
    # wait max 5 minutes to load page
    driver.set_page_load_timeout(600)

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
          for attempt in range(5):
            try:
              driver.get(race_link)
              race_table = race_results(driver, race_link, season, i+1, tracks[i])
              season_race_tables.append(race_table)
              break
            except Exception as e:
              print(f'Error loading page: {e}')
              if attempt < 4:
                print(f'Trying {season} season again...')
                driver.quit()
                time.sleep(120)  # wait 2 minutes before reattempting
                driver = webdriver.Firefox()
                driver.set_page_load_timeout(600)  # max wait 10 minutes to load
              else:
                print(f'All attempts failed for {season} season.')
                driver.quit()
                return
        
        # concatenate all race tables into one dataframe for the season
        season_df = pd.concat(season_race_tables)
        
        # save the dataframe for the season to a CSV file
        season_df.to_csv(
            os.path.join('data', 'busch-xfinity-series', f'xfinity-{season}.csv'), 
            index=False
        )
        
        # add the season data to the main data
        all_race_tables.append(season_df)
        
        # add time delay before moving to next season
        time.sleep(30) # seconds
        
    # close Firefox after scraping the season info
    driver.quit()
    
    # concatenate all race tables into one dataframe
    all_races_df = pd.concat(all_race_tables)
    
    # save the main dataframe to a CSV file
    all_races_df.to_csv(
        os.path.join('data', 'busch-xfinity-series', 'all-xfinity-series-results.csv'), 
        index=False
    )
    
    return all_races_df


# %%
# test
# xfinity = xfinity_racing(2012, 2012)

# %%
import time
start_time = time.time()

xfinity = xfinity_racing(1982, 2024)
# xfinity = xfinity_racing(1997, 2024)
# xfinity = xfinity_racing(2020, 2024)

end_time = time.time()

print(f'The process took {end_time-start_time} seconds.')



# %%
import polars as pl
xfinity_pl = pl.from_pandas(xfinity)
xfinity_pl.head() 
xfinity_pl.columns
