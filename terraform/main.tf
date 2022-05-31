provider "google" {
  project = var.PROJECT
  region  = var.REGION
}

resource "google_storage_bucket" "Create_GCS_For_Cloud_Functions" {
  name          = var.BUCKET
  storage_class = "REGIONAL"
  location      = var.REGION
}

resource "google_bigquery_dataset" "Create_Lake_Table" {
  dataset_id  = "HP_access_data_lake"
  description = "自作のホームページのアクセスログを集計するデータレイクテーブル"
  location    = "US"
}

resource "google_bigquery_dataset" "Creata_Mart_Table" {
  dataset_id  = "HP_access_data_mart"
  description = "自作のホームページのアクセスログを集計するデータマートテーブル"
  location    = "US"
}

resource "google_pubsub_topic" "Make_Topic_For_GCF" {
  name    = "access_log_topic"
  project = var.PROJECT
}

resource "google_cloud_scheduler_job" "pubsub_scheduler" {
  name      = "cloud_functions_scheduler"
  schedule  = "0 12 * * *"
  time_zone = "Asia/Tokyo"

  pubsub_target {
    topic_name = google_pubsub_topic.Make_Topic_For_GCF.id
    data       = base64encode("cloud_functions_scheduler")
  }
}
