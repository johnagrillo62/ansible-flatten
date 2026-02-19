(playbook "kubespray/roles/kubernetes-apps/registry/defaults/main.yml"
  (registry_namespace "kube-system")
  (registry_storage_class "")
  (registry_storage_access_mode "ReadWriteOnce")
  (registry_disk_size "10Gi")
  (registry_port "5000")
  (registry_replica_count "1")
  (registry_service_type "ClusterIP")
  (registry_service_cluster_ip "")
  (registry_service_loadbalancer_ip "")
  (registry_service_annotations )
  (registry_service_nodeport "")
  (registry_tls_secret "")
  (registry_htpasswd "")
  (registry_config 
    (version "0.1")
    (log 
      (fields 
        (service "registry")))
    (storage 
      (cache 
        (blobdescriptor "inmemory")))
    (http 
      (addr ":" (jinja "{{ registry_port }}"))
      (headers 
        (X-Content-Type-Options (list
            "nosniff"))))
    (health 
      (storagedriver 
        (enabled "true")
        (interval "10s")
        (threshold "3"))))
  (registry_ingress_annotations )
  (registry_ingress_host "")
  (registry_ingress_tls_secret ""))
