(playbook "tools/docker-compose-minikube/minikube/defaults/main.yml"
  (sources_dest "_sources")
  (driver "docker")
  (addons (list
      "default-storageclass"
      "storage-provisioner"
      "dashboard"))
  (minikube_url_linux "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64")
  (minikube_url_macos "https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64")
  (kubectl_url_linux "https://dl.k8s.io/release/v1.25.0/bin/linux/amd64/kubectl")
  (kubectl_url_macos "https://dl.k8s.io/release/v1.25.0/bin/darwin/amd64/kubectl")
  (minikube_service_account_name "awx-devel")
  (minikube_service_account_namespace "default"))
