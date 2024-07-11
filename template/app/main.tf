terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0.0"
    }
  }
}

provider "google" {
  user_project_override = true
}

variable "project" {
  type = string
}

resource "google_project_service" "services" {
  for_each = toset([
    "serviceusage.googleapis.com",
    "generativelanguage.googleapis.com",
    "apikeys.googleapis.com"
  ])
  project = var.project
  service = each.value
}

# Protect your project with a low initial quota
resource "google_service_usage_consumer_quota_override" "generativelanguage" {
  project        = var.project
  service        = "generativelanguage.googleapis.com"
  metric         = urlencode("generativelanguage.googleapis.com/generate_requests_per_model")
  limit          = urlencode("/min/model/project")
  override_value = "10"
  force          = true

  depends_on = [ google_project_service.services ]
}

resource "google_apikeys_key" "generativelanguage" {
  project = var.project

  name         = "gemini-api-key"
  display_name = "Gemini API Key"

  restrictions {
    api_targets {
      service = "generativelanguage.googleapis.com"
    }

    browser_key_restrictions {
      allowed_referrers = ["*"]
    }
  }
  depends_on = [ google_project_service.services ]
}

resource "google_firebase_web_app" "baking" {
  project = var.project

  display_name    = "Baking with Gemini"
  api_key_id      = google_apikeys_key.generativelanguage.uid
  deletion_policy = "DELETE"
}

resource "local_file" "api_key" {
  content  = "VITE_GEN_AI_KEY=${google_apikeys_key.generativelanguage.key_string}"
  filename = "${path.module}/.env"
}
