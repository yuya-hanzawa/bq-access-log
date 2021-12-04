provider "google" {
  project     = var.project
  region      = var.region
}

resource "google_bigquery_dataset" "data_source_for_access_log" {
  dataset_id                  = "data_source_for_access_log"
  description                 = "自作のホームページのアクセスログを集計するデータソーステーブル"
  location                    = "US"
}

resource "google_bigquery_dataset" "data_mart_for_access_log" {
  dataset_id                  = "data_mart_for_access_log"
  description                 = "自作のホームページのアクセスログを集計するデータマートテーブル"
  location                    = "US"
}

resource "google_pubsub_topic" "topic" {
  name    = "pubsub_topic"
  project = var.project
}

resource "google_cloud_scheduler_job" "pubsub_scheduler" {
  name        = "cloud_functions_scheduler"
  region      = var.region
  project     = var.project
  schedule    = "0 12 * * *"
  time_zone   = "Asia/Tokyo"

  pubsub_target {
    topic_name = google_pubsub_topic.topic.id
    data       = base64encode("cloud_functions_scheduler")
  }
}
