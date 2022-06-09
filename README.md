# bq-access-log

## 目的
自作のホームページからアクセスログを収集し、Google Cloud PlatformのBigQueryにログデータを格納する。

</br>

## ワークフロー
![access-log](https://user-images.githubusercontent.com/58725085/172891660-e67f7d5c-8494-4c97-9155-a11b28345d45.png)

</br>

## 学んだこと＆発見
### 1.

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

- Google Cloud SDK 365.0.1
  - bq 2.0.71
  - core 2021.11.19
  - gsutil 5.5

- Tools
  - Terraform v1.0.11
