(playbook "debops/ansible/roles/opensearch/defaults/main.yml"
  (opensearch__version "2.2.0")
  (opensearch__tarball "opensearch-" (jinja "{{ opensearch__version }}") "-linux-x64.tar.gz")
  (opensearch__installation_directory "/usr/local/share/opensearch")
  (opensearch__user "opensearch")
  (opensearch__group "opensearch")
  (opensearch__allow_http (list))
  (opensearch__allow_tcp (list))
  (opensearch__http_port "9200")
  (opensearch__transport_tcp_port "9300")
  (opensearch__memory_lock (jinja "{{ True
                                if (not (ansible_system_capabilities_enforced | d()) | bool or
                                    ((ansible_system_capabilities_enforced | d()) | bool and
                                     \"cap_ipc_lock\" in (ansible_system_capabilities | d([]))))
                                else False }}"))
  (opensearch__jvm_memory_heap_size_multiplier (jinja "{{ \"0.2\"
                                                    if (ansible_memtotal_mb | int / 2 <= 2048)
                                                    else \"0.45\" }}"))
  (opensearch__jvm_memory_min_heap_size (jinja "{{ (((ansible_memtotal_mb | int
                                               * opensearch__jvm_memory_heap_size_multiplier | float)
                                               | round | int) | string + \"m\")
                                             if (ansible_memtotal_mb | int / 2 <= 32768)
                                             else \"32600m\" }}"))
  (opensearch__jvm_memory_max_heap_size (jinja "{{ opensearch__jvm_memory_min_heap_size }}"))
  (opensearch__default_configuration (list
      
      (name "cluster.name")
      (comment "Use a descriptive name for your cluster")
      (value (jinja "{{ ansible_domain | replace(\".\", \"-\") }}"))
      
      (name "node.name")
      (comment "Use a descriptive name for the node")
      (value (jinja "{{ ansible_hostname }}"))
      
      (name "path.data")
      (comment "Path to directory where to store the data (separate multiple locations by
comma)
")
      (value "/var/local/opensearch")
      
      (name "path.logs")
      (comment "Path to log files")
      (value "/var/log/opensearch")
      
      (name "plugins.security.disabled")
      (comment "Disable TLS support")
      (value "True")
      
      (name "bootstrap.memory_lock")
      (comment "Lock the memory on startup")
      (value (jinja "{{ True if opensearch__memory_lock | bool else False }}"))
      
      (name "cluster.initial_master_nodes")
      (comment "Bootstrap the cluster using an initial set of master-eligible nodes
")
      (value (list
          (jinja "{{ ansible_hostname }}")))))
  (opensearch__configuration (list))
  (opensearch__group_configuration (list))
  (opensearch__host_configuration (list))
  (opensearch__combined_configuration (jinja "{{ opensearch__default_configuration
                                        + opensearch__configuration
                                        + opensearch__group_configuration
                                        + opensearch__host_configuration }}"))
  (opensearch__etc_services__dependent_list (list
      
      (name "opensearch-http")
      (port (jinja "{{ opensearch__http_port }}"))
      
      (name "opensearch-tcp")
      (port (jinja "{{ opensearch__transport_tcp_port }}"))))
  (opensearch__keyring__dependent_gpg_keys (list
      
      (id "C5B7 4989 65EF D1C2 924B  A9D5 39D3 1987 9310 D3FC")
      (url "https://artifacts.opensearch.org/publickeys/opensearch.pgp")
      (user (jinja "{{ opensearch__user }}"))
      (group (jinja "{{ opensearch__group }}"))
      (home "/var/local/opensearch")))
  (opensearch__sysctl__dependent_parameters (list
      
      (name "opensearch")
      (weight "80")
      (options (list
          
          (name "vm.max_map_count")
          (comment "The OpenSearch documentation recommends setting this as the minimum
for production workloads, see
https://opensearch.org/docs/latest/opensearch/install/important-settings/
")
          (value "262144")))))
  (opensearch__ferm__dependent_rules (list
      
      (name "opensearch_http")
      (type "accept")
      (dport (jinja "{{ opensearch__http_port }}"))
      (saddr (jinja "{{ opensearch__allow_http }}"))
      (accept_any "False")
      
      (name "opensearch_tcp")
      (type "accept")
      (dport (jinja "{{ opensearch__transport_tcp_port }}"))
      (saddr (jinja "{{ opensearch__allow_tcp }}"))
      (accept_any "False"))))
