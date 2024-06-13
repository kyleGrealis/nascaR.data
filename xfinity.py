'''
This Python script is designed to scrape NASCAR race data from a website using Selenium and BeautifulSoup. It contains two main functions: race_results and xfinity_racing.

The race_results function takes a Selenium WebDriver instance, a race link, a season, a race number, and a site as arguments. It loads the page source into BeautifulSoup, selects a specific table with race results, and converts it into a pandas DataFrame. It also extracts additional information about the track from the page and adds it to the DataFrame.

The xfinity_racing function takes a start year and an optional stop year as arguments. If no stop year is provided, it defaults to the current year. It generates a list of seasons from the start year to the stop year, and for each season, it opens a WebDriver instance, loads the season page, and gets all the race links. For each race link, it attempts to load the page and get the race results up to 5 times, handling timeouts by quitting and restarting the driver. If all attempts fail, it stops the function. If the page loads successfully, it adds the race results to a list. After processing all races for a season, it concatenates all race tables into a single DataFrame and saves it to a CSV file. It then adds the DataFrame to a list of all race tables. After all seasons are processed, it concatenates all race tables into a single DataFrame and returns it. The function also includes a delay between seasons to avoid being blocked by the website's robots.txt file.

NOTE: Combining all individual season CSV files will be handled in the data cleaning script. This has been separated so that quicker updateds can be applied mid-season. More specifically, there is no need to be redundant in scraping all the data. Rather, each updated iteration set can be separately cleaned and applied to the main dataset.
'''

# %%
import numpy as np
import pandas as pd
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from bs4 import BeautifulSoup
from datetime import datetime
import os
import re
import time
from io import StringIO

# %%
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


# function to get all season race results from the `start` year until current year
def xfinity_racing(start, stop=None):
    
    if stop is None:
        stop = datetime.now().year
    
    # base url for the racing results
    base_url = 'https://www.racing-reference.info/season-stats/{}/B/'

    # create a list of the seasons 
    seasons = list(np.arange(start, stop+1))

    # list to store all of the race results tables by season
    all_race_tables = []

    # loop over each season
    for season in seasons:
        # list to store all of the race results tables by race
        season_race_tables = []

        # open Chrome
        driver = webdriver.Chrome()
        # set the maximum page load timeout to 1 minute
        driver.set_page_load_timeout(60)

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
        for i, race_link in enumerate(race_links):
            # maximize 5 attempts to load the page
            for attempt in range(5):
                # maximum load time set to 30 seconds
                driver.set_page_load_timeout(30)

                try:
                    driver.get(race_link)
                    season_race_tables.append(
                        race_results(driver, race_link, season, i+1, sites[i])
                    )
                    break
                except TimeoutException:
                    print(f'Timeout loading page, attempt {attempt+1} of 5.')
                    driver.quit()
                    if attempt < 4:
                        driver = webdriver.Chrome()
                        driver.set_page_load_timeout(30)
                    else:
                        print(f'All attemtps failed for {season} race {i+1}.')
                        return

        # concatenate all race tables into one dataframe for the season
        season_df = pd.concat(season_race_tables)

        # save the dataframe for the season to a CSV file
        season_df.to_csv(
            os.path.join('data', 'busch-xfinity-series', f'xfinity-{season}.csv'),
            index=False
        )

        # add the new season data to the main data
        all_race_tables.append(season_df)

        # add time delay before moving to next season to prevent being blocked by robots.txt
        time.sleep(15)  # seconds

        # close Chrome after scraping the season info
        driver.quit()
    
    # concatenate all race tables into one dataframe
    all_races_df = pd.concat(all_race_tables)

    # save the main dataframe to a CSV file
    # all_races_df.to_csv(
    #     os.path.join('data', 'busch-xfinity-series', 'all-xfinity-series-results.csv'),
    #     index=False
    # )

    return all_races_df


# %%
# test
# xfinity = xfinity_racing(2012, 2012)


# %%
import time
start_time = time.time()

xfinity = xfinity_racing(1982)

end_time = time.time()

print(f'The process took {end_time-start_time} seconds.')

