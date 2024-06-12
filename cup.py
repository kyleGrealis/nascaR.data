# %%

import numpy as np
import pandas as pd
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from bs4 import BeautifulSoup
import os
import re
import time
from io import StringIO

# function to get the race results informaton
def race_results(driver, race_link, season, race_num, site):
  
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

    '''
    The track-specific details are obtained from this section:
        NASCAR Cup Series race number 16 of 36
        Sunday, June 9, 2024 at Sonoma Raceway, Sonoma, CA
        110 laps on a 1.990 mile road course (218.900 miles)
    
    The following sections use string extraction methods and HTML parsing to locate and store the appropriate information.

    track = the track name, such as Daytona International Speedway or Bristol Speedway
    track_length = length in miles
    track_type = racing surface (dirt or paved) and layout (track or road course) 
    '''

    # find the track name; not always the same as the location/city
    track = next((p.find('a', href=lambda h: "tracks" in h).text for p in soup.find_all('p') if p.text and "race number" in p.text), None)

    # find the track length and convert it to a float
    track_length = next((float(re.search(r'(\d+\.?\d*) mile', p.text).group(1)) for p in soup.find_all('p') if p.text and re.search(r'(\d+\.?\d*) mile', p.text)), None)

    # find the track type (dirt track, road course, speedway, etc)
    track_type = next((p.text.split('mile')[1].split('(')[0].strip() for p in soup.find_all('p') if p.text and 'mile' in p.text and '(' in p.text), None)

    # add season, race number, and site to the DataFrame
    race_table['Season'] = season
    race_table['Race'] = race_num
    race_table['Site'] = site
    race_table['Track'] = track
    race_table['Track_length'] = track_length
    race_table['Track_type'] = track_type

    # reorder the columns
    race_table = race_table[
       ['Season', 'Race', 'Site', 'Track', 'Track_length', 'Track_type'] 
       + original_columns
    ]

    return race_table

# function to get all season race results from start to stop year
def cup_racing(start, stop):
    
    # base url for the racing results
    base_url = 'https://www.racing-reference.info/season-stats/{}/W/'
    
    # create a list of the seasons
    seasons = list(np.arange(start, stop+1))
    
    # list to store all of the race results tables by season
    all_race_tables = []
    
    # open firefox
    driver = webdriver.Firefox()
    # set the maximum page load timeout
    driver.set_page_load_timeout(600)

    # loop over each season
    for season in seasons:
        # list to store all of the race results tables by race
        season_race_tables = []
        
        # load the season page that contains hyperlinks to the results for each race
        driver.get(base_url.format(season))
        
        # get the HTML of the page and parse with BeautifulSoup
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        # get each race link
        divs = soup.find_all('div', class_='race-number')
        race_links = [a['href'] for div in divs for a in div.find_all('a')]
        
        # get the race track locaton from the "Site" column in the main season table
        site_divs = soup.find_all('div', class_='track')
        sites = [a.text for div in site_divs for a in div.find_all('a')]
        
        # get race info for each race
        '''
        This section of code is designed to try and access the race result information up to 5 times. If an exception occurs (for example, if the page fails to load), it will print an error message, wait for 2 minutes, and then try again. If it still can't access the page after 5 attempts, it will print a message saying that all attempts have failed, quit the driver, and then return from the function.
        '''
        for i, race_link in enumerate(race_links):
          for attempt in range(5):
            try:
              driver.get(race_link)
              race_table = race_results(driver, race_link, season, i+1, sites[i])
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
            os.path.join('data', 'cup-series', f'cup-{season}.csv'), 
            index=False
        )
        
        # add the new season data to the main data
        all_race_tables.append(season_df)
        
        # add time delay before moving to next season to prevent being blocked by robots.txt
        time.sleep(30) # seconds
        
    # close Firefox after scraping the season info
    driver.quit()
    
    # concatenate all race tables into one dataframe
    all_races_df = pd.concat(all_race_tables)
    
    # save the main dataframe to a CSV file
    all_races_df.to_csv(
        os.path.join('data', 'cup-series', 'all-cup-series-results.csv'), 
        index=False
    )
    
    return all_races_df


# %%
# test
# cup = cup_racing(1949, 1949)

# %%
import time
start_time = time.time()

cup = cup_racing(1949, 2024)

end_time = time.time()

print(f'The process took {end_time-start_time} seconds.')


# %%
