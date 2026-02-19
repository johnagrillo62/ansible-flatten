(playbook "debops/ansible/roles/metricbeat/defaults/main.yml"
  (metricbeat__base_packages (list
      "metricbeat"))
  (metricbeat__packages (list))
  (metricbeat__version (jinja "{{ ansible_local.metricbeat.version | d(\"0.0.0\") }}"))
  (metricbeat__original_configuration (list
      
      (name "metricbeat_config_modules")
      (config 
        (metricbeat.config.modules 
          (path "${path.config}/modules.d/*.yml")
          (reload.enabled "False")))
      
      (name "setup_template_settings")
      (config 
        (setup.template.settings 
          (index.number_of_shards "1")
          (index.codec "best_compression")))
      
      (name "setup_kibana")
      (config 
        (setup.kibana null))
      
      (name "output_elasticsearch")
      (config 
        (output.elasticsearch 
          (hosts (list
              "localhost:9200"))))
      
      (name "processors")
      (config 
        (processors (list
            
            (add_host_metadata null)
            
            (add_cloud_metadata null)
            
            (add_docker_metadata null)
            
            (add_kubernetes_metadata null))))))
  (metricbeat__default_configuration (list
      
      (name "metricbeat_config_modules")
      (config 
        (metricbeat.config.modules 
          (path "${path.config}/modules.d/*.yml")
          (reload.enabled "True")
          (reload.period "30s")))))
  (metricbeat__configuration (list))
  (metricbeat__group_configuration (list))
  (metricbeat__host_configuration (list))
  (metricbeat__combined_configuration (jinja "{{ metricbeat__original_configuration
                                        + metricbeat__default_configuration
                                        + metricbeat__configuration
                                        + metricbeat__group_configuration
                                        + metricbeat__host_configuration }}"))
  (metricbeat__default_snippets (list
      
      (name "modules.d/system.yml")
      (divert "True")
      (config (list
          
          (module "system")
          (period "10s")
          (metricsets (list
              "cpu"
              "load"
              "memory"
              "network"
              "process"
              "process_summary"
              "socket_summary"))
          (process.include_top_n 
            (by_cpu "5")
            (by_memory "5"))
          
          (module "system")
          (period "1m")
          (metricsets (list
              "filesystem"
              "fsstat"))
          (processors (list
              
              (drop_event.when.regexp 
                (system.filesystem.mount_point "^/(sys|cgroup|proc|dev|etc|host|lib|snap)($|/)"))))
          
          (module "system")
          (period "15m")
          (metricsets (list
              "uptime"))))))
  (metricbeat__snippets (list))
  (metricbeat__group_snippets (list))
  (metricbeat__host_snippets (list))
  (metricbeat__combined_snippets (jinja "{{ metricbeat__default_snippets
                                   + metricbeat__snippets
                                   + metricbeat__group_snippets
                                   + metricbeat__host_snippets }}"))
  (metricbeat__keys (list))
  (metricbeat__group_keys (list))
  (metricbeat__host_keys (list))
  (metricbeat__combined_keys (jinja "{{ metricbeat__keys
                               + metricbeat__group_keys
                               + metricbeat__host_keys }}"))
  (metricbeat__extrepo__dependent_sources (list
      "elastic")))
