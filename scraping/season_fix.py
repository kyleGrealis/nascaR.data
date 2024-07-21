import os
import pandas as pd

# Directory where all CSV files are stored
directory = 'data/xfinity-series/scraped/'  # Replace with your actual directory path

# Initialize an empty DataFrame to store combined data
combined_df = pd.DataFrame()

# Iterate over files in the directory
for filename in os.listdir(directory):
    if filename.endswith(".csv") and 'full-import' not in filename:  # Exclude the current full-import.csv
        filepath = os.path.join(directory, filename)
        # Read each CSV file into a DataFrame
        df = pd.read_csv(filepath)
        # Append the DataFrame to combined_df
        combined_df = pd.concat([combined_df, df], ignore_index=True)

# Optionally, you can sort combined_df by date or any relevant columns

# Save the combined DataFrame to a new CSV file
combined_df.to_csv('data/xfinity-series/scraped/xfinity-series-full-import.csv', index=False) 
