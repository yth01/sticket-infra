provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}

resource "kubernetes_deployment" "sticket_server" {
  metadata {
    name = "sticket-server"
    labels = {
      App = "sticketServer"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "sticketServer"
      }
    }
    template {
      metadata {
        labels = {
          App = "sticketServer"
        }
      }
      spec {
        container {
          image             = var.ecr_image_uri
          name              = "sticket-server"
          image_pull_policy = "Always"

          port {
            container_port = 8080
          }

          env {
            name  = "DATABASE_URL"
            value = var.db_url
          }
          env {
            name  = "DATABASE_USER"
            value = var.db_username
          }
          env {
            name  = "DATABASE_PASSWORD"
            value = var.db_password
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "sticket_service" {
  metadata {
    name = "sticket-service"
  }
  spec {
    selector = {
      App = kubernetes_deployment.sticket_server.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}
