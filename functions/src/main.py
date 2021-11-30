import os
import datetime
import pandas as pd
from paramiko import SSHClient, AutoAddPolicy
from scp import SCPClient

today = datetime.datetime.now()
log_file = f"{today:access.log-%Y%m%d}"

port = os.environ.get('PORTS')
username = os.environ.get('USERNAME')
password = os.environ.get('PASSWORD')

def ssh_get_log_file(port, username, password):
    with SSHClient() as ssh:
        ssh.set_missing_host_key_policy(AutoAddPolicy())

        ssh.connect(hostname='yuya-hanzawa.com', 
                    port=port, 
                    username=username,
                    password=password
                   )
    
        with SCPClient(ssh.get_transport()) as scp:
            scp.get('/var/log/nginx/' + log_file, '.')

def main(event, context):
    ssh_get_log_file(port, username, password)

    with open(log_file, encoding="utf-8", errors='ignore') as log:
        df = pd.read_json(log, orient='records', lines=True)

    os.remove(log_file)

    print(df.columns)
