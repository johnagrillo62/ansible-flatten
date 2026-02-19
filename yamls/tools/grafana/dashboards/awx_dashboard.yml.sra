(playbook "tools/grafana/dashboards/awx_dashboard.yml"
  (apiVersion "1")
  (providers (list
      
      (name "awx-dashboards")
      (type "file")
      (allowUiUpdates "true")
      (options 
        (foldersFromFilesStructure "true")
        (path "/etc/grafana/provisioning/dashboards/")))))
