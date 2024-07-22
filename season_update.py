'''
This Python script is designed to scrape NASCAR race data from a website using Selenium and BeautifulSoup. It contains four main functions: race_results, series_racing, run_script, and update_all_series.

The race_results function takes a Selenium WebDriver instance, a race link, a season, a race number, and a site as arguments. It loads the page source into BeautifulSoup, selects a specific table with race results, and converts it into a pandas DataFrame. It also extracts additional information about the track from the page and adds it to the DataFrame.

The series_racing function updates the season for the current calendar year. This will enable a chronjob or similar routine updating without the need to alter the script. It generates a list of race links for that season. For each race link, it attempts to load the page and get the race results up to 5 times, handling timeouts by quitting and restarting the driver. If all attempts fail, it stops the function. If the page loads successfully, it adds the race results to a list. After processing all races, it concatenates all race into a single DataFrame and returns it. The function also includes a delay between seasons to avoid being blocked by the website's robots.txt file.

The run_script will access the data cleaning files withing the processing_scripts directory and execute each Python file for the respective series. This function is called once per series within the final update_all_series script. That script will combine all previously-mentioned functions into one whereby it will perform the scraping, update the current season CSV file, append the new results to the full race results for the respective series, clean & process the data for export to R, and provide user feedback throughout the process.
'''


from bs4 import BeautifulSoup
from datetime import datetime
from io import StringIO
import os
import pandas as pd
import platform
import re
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
import subprocess
import sys


# Add the project root to the Python path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))


# function to get the race results informaton
def race_results(driver, race_link, season, race_num, site):
    # get the HTML of the page and parse with BeautifulSoup
    driver.get(race_link)
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


# function to update across all series to current data when running this script
def series_racing(series, season):

    # base urls for the racing results
    base_urls = {
        'cup': 'https://www.racing-reference.info/season-stats/{}/W/',
        'xfinity': 'https://www.racing-reference.info/season-stats/{}/B/',
        'truck': 'https://www.racing-reference.info/season-stats/{}/C/'
    }

    base_url = base_urls[series]

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

    # get the race track location from the "Site" column in the main season table
    site_divs = soup.find_all('div', class_='track')
    sites = [a.text for div in site_divs for a in div.find_all('a')]

    # list to store all of the race results tables for the current season
    season_race_tables = []

    # get race info for each race
    for i, race_link in enumerate(race_links):
        # maximize 5 attempts to load the page
        for attempt in range(5):
            # maximum load time set to 30 seconds
            driver.set_page_load_timeout(30)

            try:
                driver.get(race_link)
                season_race_tables.append(
                    race_results(driver, race_link, season, i + 1, sites[i])
                )
                break
            except TimeoutException:
                print(f'Timeout loading page, attempt {attempt + 1} of 5.')
                driver.quit()
                if attempt < 4:
                    driver = webdriver.Chrome()
                    driver.set_page_load_timeout(30)
                else:
                    print(f'All attempts failed for {season} race {i + 1}.')
                    return

    # concatenate all race tables into one dataframe for the season
    season_df = pd.concat(season_race_tables)

    # save the dataframe for the season to a CSV file
    season_df.to_csv(
        f'scraping/data/{series}-series/scraped/{series}-{season}.csv',
        index=False
    )

    # close Chrome after scraping the season info
    driver.quit()

    return season_df


# to help with debugging
def run_script(script_path):
    try:
        result = subprocess.run(
            [sys.executable, script_path],
            capture_output=True,
            text=True,
            env=os.environ.copy()
        )
        if result.returncode != 0:
            print(f"Error running {script_path}:")
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        else:
            print(f"{script_path} executed successfully.")
            print(result.stdout)
    except Exception as e:
        print(f"Exception running {script_path}: {e}")


# function to scrape, clean, & process the new data
def update_all_series(season):
    series_list = ['cup', 'xfinity', 'truck']
    
    for series in series_list:
        print(f'Updating {series.capitalize()} series data for {season}...')
        
        # Define paths
        csv_path = f'scraping/data/{series}-series/scraped/{series}-series-full-import.csv'
        processing_script = f'scraping/processing_scripts/{series}_processing.py'
        
        # Read existing data
        existing_df = pd.read_csv(csv_path, low_memory=False)
        
        # Filter out rows where Season matches current season
        existing_df = existing_df[existing_df['Season'] != season]
        
        # Scrape new data
        new_df = series_racing(series, season)
        
        # Concatenate existing and new data
        combined_df = pd.concat([existing_df, new_df], ignore_index=True)
        
        # Save combined data back to CSV
        combined_df.to_csv(csv_path, index=False)
        
        # Run processing script
        print(f'Running {series.capitalize()} processing script...')
        run_script(processing_script)
        
        print(f'{series.capitalize()} series data updated.')



# run the update for all series
season = datetime.now().year
update_all_series(season)


# run the R script to write the new data to appropriate .rda file for the R package:
subprocess.run(['Rscript', 'scraping/processing_scripts/write_rda_files.R'], check=True)



# add, commit, and push the changes to GitHub
# define function to commit and push the latest changes for both projects
def run_shell_script():
    # Determine the correct shell to use based on the platform
    shell = 'bash' if platform.system() != 'Windows' else 'sh'

    # Get the directory of the current Python script
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Construct the full path to the shell script
    script_path = os.path.join(current_dir, 'nav_script.sh')

    try:
        # Run the shell script
        result = subprocess.run(
            [shell, script_path], 
            capture_output=True, 
            text=True, 
            check=True
        )
        
        # Print the output of the script
        print(result.stdout)
    
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while running the script: {e}")
        print(f"Error output: {e.stderr}")

# Call the function to run the shell script
# run_shell_script()