import os
import datetime
import pandas as pd
from paramiko import SSHClient, AutoAddPolicy
from scp import SCPClient
from google.cloud import bigquery
from linebot import LineBotApi
from linebot.models import TextSendMessage
from linebot.exceptions import LineBotApiError

project_id = os.environ.get('PROJECT_ID')
detaset_id = os.environ.get('DATASET_ID')
port = os.environ.get('PORTS')
username = os.environ.get('USERNAME')
password = os.environ.get('PASSWORD')
channel_access_token = os.environ.get("CHANNEL_ACCESS_TOKEN")
user_id = os.environ.get("USER_ID")

day = f"{datetime.datetime.now():%Y%m%d}"

def LINE_errir_notification(channel_access_token, user_id, message):
    line_bot_api = LineBotApi(channel_access_token)

    try:
        line_bot_api.push_message(user_id, TextSendMessage(text=message))

    except LineBotApiError as e:
        raise(e)

def ssh_get_log_file(port, username, password):
    with SSHClient() as ssh:
        ssh.set_missing_host_key_policy(AutoAddPolicy())

        ssh.connect(hostname='yuya-hanzawa.com', 
                    port=port, 
                    username=username,
                    password=password
                   )
    
        with SCPClient(ssh.get_transport()) as scp:
            scp.get('/var/log/nginx/access.log-{day}', '/tmp')

def main(event, context):
    try:
        ssh_get_log_file(port, username, password)

    except Exception as e:
        LINE_errir_notification(channel_access_token, user_id, 
                                   message=e)
        raise(e)

    with open('/tmp/access.log-{day}', errors='ignore') as log:
        df = pd.read_json(log, orient='records', lines=True)

    job_config = bigquery.LoadJobConfig(
        schema=[
            bigquery.SchemaField("time", "STRING", mode='NULLABLE', description='標準フォーマットのローカルタイム'),
            bigquery.SchemaField("host", "STRING", mode='NULLABLE', description='クライアントの IP アドレス'),
            bigquery.SchemaField("vhost", "STRING", mode='NULLABLE', description='マッチしたサーバ名もしくはHostヘッダの値、なければリクエスト内のホスト'),
            bigquery.SchemaField("user", "STRING", mode='NULLABLE', description='クライアントのユーザー名'),
            bigquery.SchemaField("status", "STRING", mode='NULLABLE', description='レスポンスのHTTPステータスコード'),
            bigquery.SchemaField("protocol", "STRING", mode='NULLABLE', description='リクエストプロトコル'),
            bigquery.SchemaField("method", "STRING", mode='NULLABLE', description='リクエストされたHTTPメソッド'),
            bigquery.SchemaField("path", "STRING", mode='NULLABLE', description='リクエストに含まれるクエリストリング付きのオリジナルのURI'),
            bigquery.SchemaField("req", "STRING", mode='NULLABLE', description='リクエスト URL および HTTP プロトコル'),
            bigquery.SchemaField("size", "STRING", mode='NULLABLE', description='クライアントへの送信バイト数'),
            bigquery.SchemaField("reqtime", "STRING", mode='NULLABLE', description='リクエストの処理時間'),
            bigquery.SchemaField("apptime", "STRING", mode='NULLABLE', description='サーバーがリクエストの処理にかかった時間'),
            bigquery.SchemaField("ua", "STRING", mode='NULLABLE', description='クライアントのブラウザ情報'),
            bigquery.SchemaField("forwardedfor", "STRING", mode='NULLABLE', description='接続元IPアドレス'),
            bigquery.SchemaField("forwardedproto", "STRING", mode='NULLABLE', description='HTTP／HTTPS判定'),
            bigquery.SchemaField("referrer", "STRING", mode='NULLABLE', description='Webページの参照元')
        ]
    )
        
    client = bigquery.Client(project=project_id)
    dataset = client.dataset(detaset_id)
    
    try:
        job = client.load_table_from_dataframe(
            df,
            dataset.table('access_log_{day}'),
            job_config=job_config
        )

        job.result()
    
    except Exception as e:
        LINE_errir_notification(channel_access_token, user_id, 
                                   message=e)
        raise(e)
