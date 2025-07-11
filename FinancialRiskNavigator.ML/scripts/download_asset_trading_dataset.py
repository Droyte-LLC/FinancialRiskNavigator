import kagglehub

# Download latest version
path = kagglehub.dataset_download("saketk511/2019-2024-us-stock-market-data")

print("Path to dataset files:", path)