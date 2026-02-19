(playbook "tools/otel/otel-collector-config.yaml"
  (receivers 
    (otlp 
      (protocols 
        (grpc null)
        (http null))))
  (exporters 
    (debug 
      (verbosity "detailed"))
    (file 
      (path "/awx-logs/awx-logs.json.zstd")
      (rotation 
        (max_days "14")
        (localtime "false")
        (max_megabytes "300")
        (max_backups "200"))
      (format "json")
      (compression "zstd"))
    (loki 
      (endpoint "http://loki:3100/loki/api/v1/push")
      (tls 
        (insecure "true"))
      (headers 
        (X-Scope-OrgID "1"))
      (default_labels_enabled 
        (exporter "true")
        (job "true")
        (instance "true")
        (level "true"))))
  (processors 
    (batch null))
  (extensions 
    (health_check null)
    (zpages 
      (endpoint ":55679")))
  (service 
    (pipelines 
      (logs 
        (receivers (list
            "otlp"))
        (processors (list
            "batch"))
        (exporters (list
            "file"
            "loki"))))
    (extensions (list
        "health_check"
        "zpages"))))
