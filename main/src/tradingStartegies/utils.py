import pandas as pd

# List of file names
path = 'data/15m2024_02_04_to_2024_02_10/'
file_names = ['ADA.csv', 'BTC.csv', 'SOL.csv', 'ETH.csv', 'XRP.csv']
file_names = [path + file_name for file_name in file_names]


# Read each CSV file into a pandas DataFrame
dfs = {}
for file_name in file_names:
    dfs[file_name] = pd.read_csv(file_name)

# Find the common 'open_time' values across all files
common_open_times = set.intersection(*(set(df['open_time']) for df in dfs.values()))

# Filter each DataFrame to include only rows with common 'open_time' values
filtered_dfs = {}
for file_name, df in dfs.items():
    filtered_dfs[file_name] = df[df['open_time'].isin(common_open_times)]

# Save each filtered DataFrame to a separate CSV file
for file_name, df in filtered_dfs.items():
    output_file = f"filtered_{file_name}"
    df.to_csv(output_file, index=False)
    print(f"Filtered data for '{file_name}' saved to '{output_file}'")
