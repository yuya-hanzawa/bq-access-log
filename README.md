# bq-access-log

## 目的
自作のホームページからアクセスログを収集し、Google Cloud PlatformのBigQueryにログデータを格納するパイプラインを作成する。

</br>

## ワークフロー
![access-log](https://user-images.githubusercontent.com/58725085/172891660-e67f7d5c-8494-4c97-9155-a11b28345d45.png)

</br>

## 学んだこと＆発見
1.Terraformの書き方、特にmoduleの理解が深まった。

</br>

2.~~Jsonlをpandasで処理すると想定外の挙動をしたので改めて調査する。~~
> sample data
```
{"size": "153","request_time": "0.000","area": "千葉県"}
{"size": "153","request_time": "0.000","area": "宮崎県"}
{"size": "555","request_time": "0.000","area": "北海道"}
{"size": "555","request_time": "0.003","area": "東京都"}
{"size": "555","request_time": "0.000","area": "石川県"}
{"size": "559","request_time": "0.004","area": "京都府"}
{"size": "157","request_time": "0.109","area": "鹿児島県"}
```


Jsonlを読み込むために`orient='records'`, `lines=True`と設定している。<br>
しかし、`request_time`のカラムがdatetime型になってしまい、想定と異なる結果になってしまう。

[参考URL](https://qiita.com/meshidenn/items/3ff72396fe85044bc74f)

```python
import pandas as pd

df = pd.read_json('jsonl_file', orient='records', lines=True)

print(df)

% python3 main.py
   size            request_time  area
0   153 1970-01-01 00:00:00.000   千葉県
1   153 1970-01-01 00:00:00.000   宮崎県
2   555 1970-01-01 00:00:00.000   北海道
3   555 1970-01-01 00:00:00.003   東京都
4   555 1970-01-01 00:00:00.000   石川県
5   559 1970-01-01 00:00:00.004   京都府
6   157 1970-01-01 00:00:00.109  鹿児島県
```

`convert_dates=False`と設定すると想定通りの結果が返ってくる。

[参考URL](https://stackoverflow.com/questions/39720332/pandas-read-json-function-converts-strings-to-datetime-objects-even-the-conve)

```python
import pandas as pd

df = pd.read_json('jsonl_file', orient='records', convert_dates=False, lines=True)

print(df)

% python3 main.py
   size  request_time  area
0   153         0.000   千葉県
1   153         0.000   宮崎県d
2   555         0.000   北海道
3   555         0.003   東京都
4   555         0.000   石川県
5   559         0.004   京都府
6   157         0.109  鹿児島県
```

</br>

3.作業の途中でBigQueryのテーブルのバックアップを取りたい場面があったので以下のコマンドでCloud Storageに格納した。
```sh
for i in $(bq ls -n 1000 HP_access_data_lake | grep "TABLE" | awk '{ print $1 }'); do
  bq extract HP_access_data_lake.${i} gs://{file_path}/${i}.csv
done
```

</br>

4.次は反対に以下のコマンドでCloud StorageのデータをBigQueryに戻した。
```sh
for file in $(gsutil ls gs://{file_path}/); do
  bq load --source_format=CSV HP_access_data_lake.access-log-$(echo ${file} | sed -e 's/[^0-9]//g') ${file} ./schema.json
done
```

</br>

## 使い方
### 1. ソースコードをクローン
```
git clone https://github.com/zawa1120/bq-access-log.git
```

### 2. Terraformやgcloudの各種初期設定

### 3. Cloud Functionsとスケジュラークエリのデプロイ
```sh
cd functions
bash deploy.sh
```

</br>

## 環境
- macOS Big Sur 11.4 Apple M1
  - Homebrew 3.4.1

</br>

- Google Cloud SDK 365.0.1
  - bq 2.0.74
  - core 2022.05.27
  - gsutil 5.10

</br>

- Tools
  - Terraform v1.0.11
