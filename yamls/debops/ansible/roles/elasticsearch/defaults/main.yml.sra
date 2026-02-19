(playbook "debops/ansible/roles/elasticsearch/defaults/main.yml"
  (elasticsearch__base_packages (list
      "elasticsearch"))
  (elasticsearch__packages (list))
  (elasticsearch__version (jinja "{{ ansible_local.elasticsearch.version | d(\"0.0.0\") }}"))
  (elasticsearch__user "elasticsearch")
  (elasticsearch__group "elasticsearch")
  (elasticsearch__additional_groups (jinja "{{ [\"ssl-cert\"]
                                      if elasticsearch__pki_enabled | bool
                                      else [] }}"))
  (elasticsearch__inventory_group_all "debops_service_elasticsearch")
  (elasticsearch__inventory_group_master "debops_service_elasticsearch_master")
  (elasticsearch__inventory_group_data "debops_service_elasticsearch_data")
  (elasticsearch__inventory_group_ingest "debops_service_elasticsearch_ingest")
  (elasticsearch__inventory_group_lb "debops_service_elasticsearch_lb")
  (elasticsearch__inventory_master_hosts (jinja "{{ (groups[elasticsearch__inventory_group_master]
                                            | d(groups[elasticsearch__inventory_group_all]))
                                           if elasticsearch__allow_tcp else [] }}"))
  (elasticsearch__initial_master_nodes (list
      (jinja "{{ elasticsearch__node_name }}")))
  (elasticsearch__allow_http (list))
  (elasticsearch__allow_tcp (list))
  (elasticsearch__pki_enabled (jinja "{{ (ansible_local.pki.enabled | d()) | bool }}"))
  (elasticsearch__pki_base_path (jinja "{{ ansible_local.pki.base_path | d(\"/etc/pki/realms\") }}"))
  (elasticsearch__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (elasticsearch__pki_ca_file (jinja "{{ ansible_local.pki.ca | d(\"CA.crt\") }}"))
  (elasticsearch__pki_key_file (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (elasticsearch__pki_crt_file "public/cert_intermediate.pem")
  (elasticsearch__tls_ca_certificate (jinja "{{ elasticsearch__pki_base_path + \"/\"
                                       + elasticsearch__pki_realm + \"/\"
                                       + elasticsearch__pki_ca_file }}"))
  (elasticsearch__tls_private_key (jinja "{{ elasticsearch__pki_base_path + \"/\"
                                    + elasticsearch__pki_realm + \"/\"
                                    + elasticsearch__pki_key_file }}"))
  (elasticsearch__tls_certificate (jinja "{{ elasticsearch__pki_base_path + \"/\"
                                    + elasticsearch__pki_realm + \"/\"
                                    + elasticsearch__pki_crt_file }}"))
  (elasticsearch__xpack_enabled (jinja "{{ True
                                  if (elasticsearch__pki_enabled | bool and
                                      elasticsearch__allow_tcp | d())
                                  else False }}"))
  (elasticsearch__api_base_url (jinja "{{ \"https://\" + ansible_fqdn + \":9200\" }}"))
  (elasticsearch__api_username "elastic")
  (elasticsearch__secret_path (jinja "{{ \"elasticsearch/credentials/\"
                                + elasticsearch__cluster_name + \"/built-in\" }}"))
  (elasticsearch__api_password (jinja "{{ lookup(\"password\", secret + \"/\"
                                 + elasticsearch__secret_path + \"/\"
                                 + elasticsearch__api_username + \"/password\") }}"))
  (elasticsearch__native_roles (list))
  (elasticsearch__group_native_roles (list))
  (elasticsearch__host_native_roles (list))
  (elasticsearch__combined_native_roles (jinja "{{ elasticsearch__native_roles
                                          + elasticsearch__group_native_roles
                                          + elasticsearch__host_native_roles }}"))
  (elasticsearch__native_users (list))
  (elasticsearch__group_native_users (list))
  (elasticsearch__host_native_users (list))
  (elasticsearch__combined_native_users (jinja "{{ elasticsearch__native_users
                                          + elasticsearch__group_native_users
                                          + elasticsearch__host_native_users }}"))
  (elasticsearch__network_host (jinja "{{ [\"_local_\", \"_site_\"]
                                 if (ansible_local.ferm.enabled | d() and
                                     ansible_local.ferm.enabled | bool)
                                 else [\"_local_\"] }}"))
  (elasticsearch__http_port "9200")
  (elasticsearch__transport_tcp_port "9300")
  (elasticsearch__domain (jinja "{{ ansible_domain }}"))
  (elasticsearch__cluster_name (jinja "{{ elasticsearch__domain | replace(\".\", \"-\") }}"))
  (elasticsearch__node_name (jinja "{{ ansible_hostname }}"))
  (elasticsearch__discovery_hosts (jinja "{{ elasticsearch__inventory_master_hosts }}"))
  (elasticsearch__discovery_minimum_master_nodes (jinja "{{ \"1\" if (elasticsearch__inventory_master_hosts | count <= 2)
                                                       else ((elasticsearch__inventory_master_hosts | count / 2) | round(0, \"floor\") | int + 1) }}"))
  (elasticsearch__gateway_recover_after_nodes (jinja "{{ elasticsearch__discovery_minimum_master_nodes }}"))
  (elasticsearch__node_master (jinja "{{ True
                                if (elasticsearch__inventory_group_master in group_names)
                                else (False
                                      if (elasticsearch__inventory_group_data in group_names)
                                      else (False
                                            if (elasticsearch__inventory_group_ingest in group_names)
                                            else (False
                                                  if (elasticsearch__inventory_group_lb in group_names)
                                                  else True))) }}"))
  (elasticsearch__node_data (jinja "{{ True
                              if (elasticsearch__inventory_group_data in group_names)
                              else (False
                                    if (elasticsearch__inventory_group_master in group_names)
                                    else (False
                                          if (elasticsearch__inventory_group_ingest in group_names)
                                          else (False
                                                if (elasticsearch__inventory_group_lb in group_names)
                                                else True))) }}"))
  (elasticsearch__node_ingest (jinja "{{ True
                                if (elasticsearch__inventory_group_ingest in group_names)
                                else (False
                                      if (elasticsearch__inventory_group_master in group_names)
                                      else (False
                                            if (elasticsearch__inventory_group_data in group_names)
                                            else (False
                                                  if (elasticsearch__inventory_group_lb in group_names)
                                                  else True))) }}"))
  (elasticsearch__memory_lock (jinja "{{ True
                                if (not (ansible_system_capabilities_enforced | d()) | bool or
                                    ((ansible_system_capabilities_enforced | d()) | bool and
                                     \"cap_ipc_lock\" in (ansible_system_capabilities | d([]))))
                                else False }}"))
  (elasticsearch__systemd_limit_memlock "infinity")
  (elasticsearch__jvm_memory_heap_size_multiplier (jinja "{{ \"0.2\"
                                                    if (ansible_memtotal_mb | int / 2 <= 2048)
                                                    else \"0.45\" }}"))
  (elasticsearch__jvm_memory_min_heap_size (jinja "{{ (((ansible_memtotal_mb | int
                                               * elasticsearch__jvm_memory_heap_size_multiplier | float)
                                               | round | int) | string + \"m\")
                                             if (ansible_memtotal_mb | int / 2 <= 32768)
                                             else \"32600m\" }}"))
  (elasticsearch__jvm_memory_max_heap_size (jinja "{{ elasticsearch__jvm_memory_min_heap_size }}"))
  (elasticsearch__path_data (list
      "/var/lib/elasticsearch"))
  (elasticsearch__original_configuration (list
      
      (name "cluster.name")
      (comment "Use a descriptive name for your cluster")
      (value "node-1")
      (state "comment")
      
      (name "node.name")
      (comment "Use a descriptive name for the node")
      (value "node-1")
      (state "comment")
      
      (name "node.attr.rack")
      (comment "Add custom attributes to the node")
      (value "r1")
      (state "comment")
      
      (name "path.data")
      (comment "Path to directory where to store the data
(separate multiple locations by comma)
")
      (value "/var/lib/elasticsearch")
      
      (name "path.logs")
      (comment "Path to log files")
      (value "/var/log/elasticsearch")
      
      (name "bootstrap.memory_lock")
      (comment "Lock the memory on startup

Make sure that the heap size is set to about half the memory available
on the system and that the owner of the process is allowed to use this
limit.

Elasticsearch performs poorly when the system is swapping the memory.
")
      (value "True")
      (state "comment")
      
      (name "network.host")
      (comment "Set the bind address to a specific IP (IPv4 or IPv6)")
      (value "192.160.0.1")
      (state "comment")
      
      (name "http.port")
      (comment "Set a custom port for HTTP")
      (value "9200")
      (state "comment")
      
      (name (jinja "{{ \"discovery.zen.ping.unicast.hosts\"
              if (elasticsearch__version is version(\"7.0.0\", \"<\"))
              else \"discovery.seed_hosts\" }}"))
      (comment "Pass an initial list of hosts to perform discovery when new node is started:
The default list of hosts is [\"127.0.0.1\", \"[::1]\"]
")
      (value (list
          "host1"
          "host2"))
      (state "comment")
      
      (name "cluster.initial_master_nodes")
      (comment "Bootstrap the cluster using an initial set of master-eligible nodes:")
      (value (list
          "node-1"
          "node-2"))
      (state "comment")
      
      (name "action.destructive_requires_name")
      (comment "Require explicit names when deleting indices")
      (value "True")
      (state "comment")))
  (elasticsearch__default_configuration (list
      
      (name "cluster.name")
      (value (jinja "{{ elasticsearch__cluster_name }}"))
      (state "present")
      
      (name "node.roles")
      (comment "Roles assigned to the node")
      (state (jinja "{{ \"present\" if (elasticsearch__version is version(\"7.9.0\", \">=\") and elasticsearch__node_master) else \"absent\" }}"))
      (value (list
          "master"))
      
      (name "node.roles")
      (state (jinja "{{ \"present\" if (elasticsearch__version is version(\"7.9.0\", \">=\") and elasticsearch__node_data) else \"absent\" }}"))
      (value (list
          "data"))
      
      (name "node.roles")
      (state (jinja "{{ \"present\" if (elasticsearch__version is version(\"7.9.0\", \">=\") and elasticsearch__node_ingest) else \"absent\" }}"))
      (value (list
          "ingest"))
      
      (name "node.master")
      (comment "Type of the node")
      (value (jinja "{{ elasticsearch__node_master }}"))
      (state (jinja "{{ \"present\" if (elasticsearch__version is version(\"7.9.0\", \"<\")) else \"absent\" }}"))
      
      (name "node.data")
      (value (jinja "{{ elasticsearch__node_data }}"))
      (state (jinja "{{ \"present\" if (elasticsearch__version is version(\"7.9.0\", \"<\")) else \"absent\" }}"))
      
      (name "node.ingest")
      (value (jinja "{{ elasticsearch__node_ingest }}"))
      (state (jinja "{{ \"present\" if (elasticsearch__version is version(\"7.9.0\", \"<\")) else \"absent\" }}"))
      
      (name "node.name")
      (value (jinja "{{ elasticsearch__node_name }}"))
      (state "present")
      
      (name "network.host")
      (value (jinja "{{ elasticsearch__network_host }}"))
      (state "present")
      
      (name "http.port")
      (value (jinja "{{ elasticsearch__http_port }}"))
      (state "present")
      
      (name (jinja "{{ \"transport.tcp.port\"
              if (elasticsearch__version is version(\"7.1.0\", \"<\"))
              else \"transport.port\" }}"))
      (comment "Set a custom port for TCP transport")
      (value (jinja "{{ elasticsearch__transport_tcp_port }}"))
      (state "present")
      
      (name (jinja "{{ \"discovery.zen.ping.unicast.hosts\"
              if (elasticsearch__version is version(\"7.0.0\", \"<\"))
              else \"discovery.seed_hosts\" }}"))
      (value "")
      (state "present")
      
      (name (jinja "{{ \"discovery.zen.ping.unicast.hosts\"
              if (elasticsearch__version is version(\"7.0.0\", \"<\"))
              else \"discovery.seed_hosts\" }}"))
      (value (jinja "{{ elasticsearch__discovery_hosts }}"))
      (state (jinja "{{ \"present\" if elasticsearch__discovery_hosts else \"absent\" }}"))
      
      (name "discovery.zen.minimum_master_nodes")
      (comment "Prevent the \"split brain\" by configuring the majority of nodes
(total number of master-eligible nodes / 2 + 1)
")
      (value (jinja "{{ elasticsearch__discovery_minimum_master_nodes }}"))
      (state (jinja "{{ \"present\" if (elasticsearch__version is version(\"7.0.0\", \"<\")) else \"absent\" }}"))
      
      (name "cluster.initial_master_nodes")
      (value "")
      (state "present")
      
      (name "cluster.initial_master_nodes")
      (value (jinja "{{ elasticsearch__initial_master_nodes }}"))
      (state (jinja "{{ \"absent\"
               if (elasticsearch__version is version(\"7.0.0\", \"<\"))
               else \"present\" }}"))
      
      (name "gateway.recover_after_nodes")
      (comment "Block initial recovery after a full cluster restart until N nodes are started")
      (value (jinja "{{ elasticsearch__gateway_recover_after_nodes }}"))
      (state (jinja "{{ \"present\" if (elasticsearch__version is version(\"7.7.0\", \"<\")) else \"absent\" }}"))
      
      (name "action.destructive_requires_name")
      (value "True")
      (state "present")
      
      (name "bootstrap.memory_lock")
      (value (jinja "{{ True if elasticsearch__memory_lock | bool else False }}"))
      (state "present")
      
      (name "path.data")
      (value (jinja "{{ elasticsearch__path_data }}"))
      (state "present")
      
      (name "xpack.security.enabled")
      (value "True")
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.http.ssl.enabled")
      (value "True")
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.http.ssl.verification_mode")
      (value "certificate")
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.http.ssl.client_authentication")
      (value "optional")
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.http.ssl.key")
      (value (jinja "{{ elasticsearch__tls_private_key }}"))
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.http.ssl.certificate")
      (value (jinja "{{ elasticsearch__tls_certificate }}"))
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.http.ssl.certificate_authorities")
      (value (jinja "{{ elasticsearch__tls_ca_certificate }}"))
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.transport.ssl.enabled")
      (value "True")
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.transport.ssl.verification_mode")
      (value "certificate")
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.transport.ssl.client_authentication")
      (value "required")
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.transport.ssl.key")
      (value (jinja "{{ elasticsearch__tls_private_key }}"))
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.transport.ssl.certificate")
      (value (jinja "{{ elasticsearch__tls_certificate }}"))
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))
      
      (name "xpack.security.transport.ssl.certificate_authorities")
      (value (jinja "{{ elasticsearch__tls_ca_certificate }}"))
      (state (jinja "{{ \"present\" if elasticsearch__xpack_enabled | bool else \"absent\" }}"))))
  (elasticsearch__configuration (list))
  (elasticsearch__master_configuration (list))
  (elasticsearch__data_configuration (list))
  (elasticsearch__ingest_configuration (list))
  (elasticsearch__lb_configuration (list))
  (elasticsearch__group_configuration (list))
  (elasticsearch__host_configuration (list))
  (elasticsearch__plugin_configuration (jinja "{{ lookup(\"template\",
                                         \"lookup/elasticsearch__plugin_configuration.j2\")
                                         | from_yaml }}"))
  (elasticsearch__dependent_role "")
  (elasticsearch__dependent_state "present")
  (elasticsearch__dependent_configuration (list))
  (elasticsearch__dependent_configuration_filter (jinja "{{ lookup(\"template\",
                                                   \"lookup/elasticsearch__dependent_configuration_filter.j2\")
                                                   | from_yaml }}"))
  (elasticsearch__combined_configuration (jinja "{{ lookup(\"flattened\", (elasticsearch__original_configuration
                                           + elasticsearch__default_configuration
                                           + elasticsearch__plugin_configuration
                                           + elasticsearch__dependent_configuration_filter
                                           + elasticsearch__configuration
                                           + elasticsearch__master_configuration
                                           + elasticsearch__data_configuration
                                           + elasticsearch__ingest_configuration
                                           + elasticsearch__lb_configuration
                                           + elasticsearch__group_configuration
                                           + elasticsearch__host_configuration)) }}"))
  (elasticsearch__configuration_sections (list
      
      (name "Cluster")
      (part "cluster")
      
      (name "Node")
      (part "node")
      
      (name "Paths")
      (part "path")
      
      (name "Memory")
      (part "bootstrap")
      
      (name "Network")
      (parts (list
          "network"
          "http"
          "transport"))
      
      (name "Discovery")
      (part "discovery")
      
      (name "Gateway")
      (part "gateway")
      
      (name "X-Pack")
      (part "xpack")
      
      (name "Search Guard")
      (part "searchguard")
      
      (name "ReadonlyREST")
      (part "readonlyrest")))
  (elasticsearch__plugins (list))
  (elasticsearch__master_plugins (list))
  (elasticsearch__data_plugins (list))
  (elasticsearch__ingest_plugins (list))
  (elasticsearch__lb_plugins (list))
  (elasticsearch__group_plugins (list))
  (elasticsearch__host_plugins (list))
  (elasticsearch__combined_plugins (jinja "{{ lookup(\"flattened\", (elasticsearch__plugins
                                     + elasticsearch__master_plugins
                                     + elasticsearch__data_plugins
                                     + elasticsearch__ingest_plugins
                                     + elasticsearch__lb_plugins
                                     + elasticsearch__group_plugins
                                     + elasticsearch__host_plugins)) }}"))
  (elasticsearch__java_policy "// default permissions granted to all domains
grant {
    // allows anyone to listen on dynamic ports
    permission java.net.SocketPermission \"localhost:0\", \"listen\";

    // \"standard\" properties that can be read by anyone
    permission java.util.PropertyPermission \"java.version\", \"read\";
    permission java.util.PropertyPermission \"java.vendor\", \"read\";
    permission java.util.PropertyPermission \"java.vendor.url\", \"read\";
    permission java.util.PropertyPermission \"java.class.version\", \"read\";
    permission java.util.PropertyPermission \"os.name\", \"read\";
    permission java.util.PropertyPermission \"os.version\", \"read\";
    permission java.util.PropertyPermission \"os.arch\", \"read\";
    permission java.util.PropertyPermission \"file.separator\", \"read\";
    permission java.util.PropertyPermission \"path.separator\", \"read\";
    permission java.util.PropertyPermission \"line.separator\", \"read\";
    permission java.util.PropertyPermission
                   \"java.specification.version\", \"read\";
    permission java.util.PropertyPermission \"java.specification.vendor\", \"read\";
    permission java.util.PropertyPermission \"java.specification.name\", \"read\";
    permission java.util.PropertyPermission
                   \"java.vm.specification.version\", \"read\";
    permission java.util.PropertyPermission
                   \"java.vm.specification.vendor\", \"read\";
    permission java.util.PropertyPermission
                   \"java.vm.specification.name\", \"read\";
    permission java.util.PropertyPermission \"java.vm.version\", \"read\";
    permission java.util.PropertyPermission \"java.vm.vendor\", \"read\";
    permission java.util.PropertyPermission \"java.vm.name\", \"read\";

    permission java.io.FilePermission \"" (jinja "{{ elasticsearch__pki_base_path }}") "/-\", \"read\";
    permission java.io.FilePermission \"" (jinja "{{ elasticsearch__pki_base_path }}") "/\", \"read\";
    permission java.io.FilePermission \"/etc/ssl/certs/-\", \"read\";
    permission java.io.FilePermission \"/etc/ssl/certs/\", \"read\";
};
")
  (elasticsearch__etc_services__dependent_list (list
      
      (name "elasticsearch-http")
      (port (jinja "{{ elasticsearch__http_port }}"))
      
      (name "elasticsearch-tcp")
      (port (jinja "{{ elasticsearch__transport_tcp_port }}"))))
  (elasticsearch__sysctl__dependent_parameters (list
      
      (name "elasticsearch")
      (weight "80")
      (options (list
          
          (name "vm.max_map_count")
          (comment "Elasticsearch uses a mmapfs directory by default to store its
indices. The default operating system limits on mmap counts is likely
to be too low, which may result in out of memory exceptions.
Ref: https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html
")
          (value "262144")))))
  (elasticsearch__extrepo__dependent_sources (list
      "elastic"))
  (elasticsearch__ferm__dependent_rules (list
      
      (name "elasticsearch_http")
      (type "accept")
      (dport (jinja "{{ elasticsearch__http_port }}"))
      (saddr (jinja "{{ elasticsearch__allow_http }}"))
      (accept_any "False")
      
      (name "elasticsearch_tcp")
      (type "accept")
      (dport (jinja "{{ elasticsearch__transport_tcp_port }}"))
      (saddr (jinja "{{ elasticsearch__allow_tcp }}"))
      (accept_any "False"))))
