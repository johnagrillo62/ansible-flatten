(playbook "tools/loki/local-config.yaml"
  (auth_enabled "false")
  (server 
    (http_listen_port "3100")
    (grpc_server_max_recv_msg_size "524288000")
    (grpc_server_max_send_msg_size "524288000"))
  (frontend_worker 
    (match_max_concurrent "true")
    (grpc_client_config 
      (max_send_msg_size "524288000")))
  (ingester 
    (max_chunk_age "8766h"))
  (common 
    (path_prefix "/loki")
    (storage 
      (filesystem 
        (chunks_directory "/loki/chunks")
        (rules_directory "/loki/rules")))
    (replication_factor "1")
    (ring 
      (kvstore 
        (store "inmemory"))))
  (schema_config 
    (configs (list
        
        (from "2020-10-24")
        (store "boltdb-shipper")
        (object_store "filesystem")
        (schema "v11")
        (index 
          (prefix "index_")
          (period "24h")))))
  (storage_config 
    (boltdb_shipper 
      (active_index_directory "/loki/index")
      (cache_location "/loki/boltdb-cache")))
  (ruler 
    (alertmanager_url "http://localhost:9093"))
  (limits_config 
    (retention_period "3y")
    (split_queries_by_interval "1d")
    (max_query_length "3y")
    (reject_old_samples "false")
    (reject_old_samples_max_age "365d")
    (ingestion_rate_mb "32")
    (ingestion_burst_size_mb "32")
    (per_stream_rate_limit "32M")
    (per_stream_rate_limit_burst "32M")
    (ingestion_rate_strategy "local")
    (max_global_streams_per_user "100000000")
    (max_entries_limit_per_query "100000000")
    (max_query_series "1000000")
    (max_query_parallelism "32")
    (max_streams_per_user "100000000"))
  (frontend 
    (max_outstanding_per_tenant "2048"))
  (query_scheduler 
    (max_outstanding_requests_per_tenant "2048"))
  (query_range 
    (parallelise_shardable_queries "false")
    (split_queries_by_interval "0")))
