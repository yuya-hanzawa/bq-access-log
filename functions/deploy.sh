gcloud functions deploy access_log --region us-central1 --entry-point main --runtime python37 --env-vars-file env.yaml --trigger-topic pubsub_topic
