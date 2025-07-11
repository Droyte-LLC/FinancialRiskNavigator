from azureml.core import Workspace, Dataset, Datastore

# Connect to workspace
ws = Workspace.from_config()

# Get default datastore (usually your workspace blob storage)
datastore = ws.get_default_datastore()

# Upload local file to datastore (this uploads to the root of the datastore container)
datastore.upload_files(files=['../data/StockMarketDataset_Sanitized_Labeled.csv'], target_path='datasets/', overwrite=True, show_progress=True)

# Create a Dataset pointing to the file in the datastore
datapath = [(datastore, 'datasets/StockMarketDataset_Sanitized_Labeled.csv')]
ds = Dataset.Tabular.from_delimited_files(path=datapath)

# Register dataset
ds = ds.register(workspace=ws, name='risk_labeled_data', create_new_version=True)

print("Dataset registered successfully.")
