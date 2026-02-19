(playbook "tools/grafana/datasources/loki_source.yml"
  (apiVersion "1")
  (datasources (list
      
      (name "Loki")
      (type "loki")
      (access "proxy")
      (url "http://loki:3100")
      (jsonData 
        (timeout "60")
        (maxLines "100000")))))
