gcloud functions deploy GCF_Access_Log --region us-central1 --entry-point main --runtime python37 --stage-bucket GCF_Access_Log_Bucket --env-vars-file env.yaml --trigger-topic pubsub_topic
