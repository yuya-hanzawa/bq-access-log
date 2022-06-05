gcloud functions deploy GCF_Access_Log \
--region us-central1 \
--entry-point main \
--runtime python37 \
--stage-bucket gcf-access-log-bucket \
--env-vars-file env.yaml \
--trigger-topic access-log-topic

bq query \
--destination_table='HP_access_data_mart.daily_pv' \
--display_name='transform_log' \
--schedule='every day 06:00' \
--use_legacy_sql=false \
--replace=true \
< ./query.sql
