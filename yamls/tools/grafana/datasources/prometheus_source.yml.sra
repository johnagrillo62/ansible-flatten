(playbook "tools/grafana/datasources/prometheus_source.yml"
  (apiVersion "1")
  (datasources (list
      
      (name "Prometheus")
      (type "prometheus")
      (isDefault "true")
      (access "proxy")
      (url "http://prometheus:9090")
      (editable "true")
      (jsonData 
        (timeInterval "5s"))
      (uid "awx_prometheus"))))
