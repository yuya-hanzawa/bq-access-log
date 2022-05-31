provider "google" {
  project     = var.PROJECT
  region      = var.REGION
}

resource "google_bigquery_dataset" "HP_access_data_lake" {
  dataset_id                  = "HP_access_data_lake"
  description                 = "自作のホームページのアクセスログを集計するデータレイクテーブル"
  location                    = "US"
}

resource "google_bigquery_dataset" "HP_access_data_mart" {
  dataset_id                  = "HP_access_data_mart"
  description                 = "自作のホームページのアクセスログを集計するデータマートテーブル"
  location                    = "US"
}

resource "google_pubsub_topic" "topic" {
  name    = "pubsub_topic"
  project = var.PROJECT
}

resource "google_cloud_scheduler_job" "pubsub_scheduler" {
  name        = "cloud_functions_scheduler"
  region      = var.REGION
  project     = var.PROJECT
  schedule    = "0 12 * * *"
  time_zone   = "Asia/Tokyo"

  pubsub_target {
    topic_name = google_pubsub_topic.topic.id
    data       = base64encode("cloud_functions_scheduler")
  }
}
