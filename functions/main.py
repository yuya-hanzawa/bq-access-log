import os
import datetime
import pandas as pd
from paramiko import SSHClient, AutoAddPolicy
from scp import SCPClient

from linebot import LineBotApi
from linebot.models import TextSendMessage
from linebot.exceptions import LineBotApiError

today = datetime.datetime.now()
log_file = f"{today:access.log-%Y%m%d}"

port = os.environ.get('PORTS')
username = os.environ.get('USERNAME')
password = os.environ.get('PASSWORD')
channel_access_token = os.environ.get("CHANNEL_ACCESS_TOKEN")
user_id = os.environ.get("USER_ID")

def errir_notification_to_line(channel_access_token, user_id, message):
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
            scp.get('/var/log/nginx/' + log_file, '/tmp')

def main(event, context):
    try:
        ssh_get_log_file(port, username, password)

    except Exception as e:
        errir_notification_to_line(channel_access_token, user_id, 
                                   message=e)
        raise(e)

    with open('/tmp/'+log_file, errors='ignore') as log:
        df = pd.read_json(log, orient='records', lines=True)
        
    print(df.columns)
    print(df.shape)
    print(today.strftime('%Y年%m月%d日 %H:%M:%S'))
