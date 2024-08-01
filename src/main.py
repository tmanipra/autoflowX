import functions_framework
import os
from google.cloud import storage

# Triggered by a change in a storage bucket
@functions_framework.cloud_event
def gcs_to_gcs(cloud_event):
    # Get event data
    data = cloud_event.data
    bucket_name = data.get("bucket")
    file_name = data.get("name")

    # Initialize the Google Cloud Storage client
    client = storage.Client()

    # Get the source and destination buckets
    source_bucket = client.bucket(bucket_name)
    destination_bucket_name = 'autoflowx_dest'
    destination_bucket = client.bucket(destination_bucket_name)

    # Get the source blob and destination blob
    source_blob = source_bucket.blob(file_name)
    destination_blob = destination_bucket.blob(file_name)

    # Copy the blob to the destination bucket
    destination_bucket.copy_blob(source_blob, destination_bucket, file_name)

    # Delete the blob from the source bucket
    source_blob.delete()

    print(f"Moved {file_name} from {bucket_name} to {destination_bucket_name}")
