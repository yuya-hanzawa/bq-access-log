# bq-access-log

## 目的
自作のホームページからアクセスログを収集し、Google Cloud PlatformのBigQueryにログデータを格納するパイプラインを作成する。

</br>

## ワークフロー
![access-log](https://user-images.githubusercontent.com/58725085/172891660-e67f7d5c-8494-4c97-9155-a11b28345d45.png)

</br>

## 学んだこと＆発見
1. Terraformの書き方、特にmoduleの理解が深まった。
2. Jsonlをpandasで処理すると想定外の挙動をしたので改めて調査する。
3. 作業の途中でBigQueryテーブルのバックアップを取りたい場面があったので以下のコマンドでCloud Storageに格納した。
```
for i in $(bq ls -n 1000 HP_access_data_lake | grep "TABLE" | awk '{ print $1 }'); do
  bq extract HP_access_data_lake.${i} gs://ファイルのパス/${i}.csv
done
```
4. 3の後に反対に以下のコマンドでCloud StorageのデータをBigQueryに戻した。
```
for file in $(gsutil ls gs://ファイルのパス/); do
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
```
cd functions
bash deploy.sh
```

</br>

## 環境
- macOS Big Sur 11.4 Apple M1
  - Homebrew 3.3.6

</br>

- Google Cloud SDK 365.0.1
  - bq 2.0.71
  - core 2021.11.19
  - gsutil 5.5

</br>

- Tools
  - Terraform v1.0.11
