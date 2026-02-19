(playbook "kubespray/roles/kubernetes-apps/persistent_volumes/gcp-pd-csi/defaults/main.yml"
  (gcp_pd_csi_volume_type "pd-standard")
  (gcp_pd_regional_replication_enabled "false")
  (gcp_pd_restrict_zone_replication "false")
  (gcp_pd_restricted_zones (list
      "europe-west1-b"
      "europe-west1-c")))
