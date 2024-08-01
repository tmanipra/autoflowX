import os
from google.cloud import storage

def gcs_to_gcs(event, context):
    bucket_name = event['bucket']
    file_name = event['name']

    if not file_name.endswith('.csv'):
        return

    client = storage.Client()
    source_bucket = client.bucket(bucket_name)
    destination_bucket_name = os.environ['DEST_BUCKET']
    destination_bucket = client.bucket(destination_bucket_name)
    blob = source_bucket.blob(file_name)

    # Copy the file to the destination bucket
    source_bucket.copy_blob(blob, destination_bucket, file_name)

    # Optionally delete the file from the source bucket
    blob.delete()
