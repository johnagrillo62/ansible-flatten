(playbook "debops/ansible/roles/docker_server/defaults/main.yml"
  (docker_server__upstream "False")
  (docker_server__base_packages (list
      (jinja "{{ [\"docker-ce\", \"docker-compose-plugin\"]
        if docker_server__upstream | bool
        else [\"docker.io\", \"docker-compose\"] }}")))
  (docker_server__packages (list))
  (docker_server__version (jinja "{{ ansible_local.docker_server.version | d(\"0.0.0\") }}"))
  (docker_server__ferm_post_hook (jinja "{{ ansible_local.ferm.enabled | d() | bool }}"))
  (docker_server__resolved_integration (jinja "{{ True
                                         if ((ansible_local.resolved.state | d()) == \"enabled\")
                                         else False }}"))
  (docker_server__resolved_address "172.17.0.1")
  (docker_server__resolved_networks (list
      "172.17.0.0/16"))
  (docker_server__swarm_support "False")
  (docker_server__swarm_networks (list
      (jinja "{{ ansible_default_ipv4.network
                                     + \"/\" + ansible_default_ipv4.prefix }}")))
  (docker_server__admins (jinja "{{ ansible_local.core.admin_users | d([]) }}"))
  (docker_server__default_configuration (list
      
      (name "log-driver")
      (config 
        (log-driver "journald"))
      (state (jinja "{{ \"present\"
               if ((ansible_local.journald.enabled | d()) | bool)
               else \"ignore\" }}"))
      
      (name "remote-nameservers")
      (config 
        (dns (jinja "{{ ansible_dns.nameservers }}")))
      (state (jinja "{{ \"present\"
               if (not ansible_dns.nameservers
                   | intersect([\"127.0.0.1\", \"127.0.0.53\"]))
               else \"ignore\" }}"))
      
      (name "resolved-nameserver")
      (config 
        (dns (list
            (jinja "{{ docker_server__resolved_address }}"))))
      (state (jinja "{{ \"present\"
               if (docker_server__resolved_integration | bool)
               else \"ignore\" }}"))))
  (docker_server__configuration (list))
  (docker_server__group_configuration (list))
  (docker_server__host_configuration (list))
  (docker_server__combined_configuration (jinja "{{ docker_server__default_configuration
                                           + docker_server__configuration
                                           + docker_server__group_configuration
                                           + docker_server__host_configuration }}"))
  (docker_server__extrepo__dependent_sources (list
      
      (name "docker-ce")
      (state (jinja "{{ \"present\"
               if (docker_server__upstream | bool)
               else \"absent\" }}"))))
  (docker_server__systemd__dependent_units (list))
  (docker_server__etc_services__dependent_list (list
      
      (name "docker-manager")
      (port "2377")
      (protocols (list
          "tcp"))
      (comment "Communication with and between Docker manager nodes")
      
      (name "docker-discovery")
      (port "7946")
      (comment "Docker Swarm overlay network node discovery")
      
      (name "docker-overlay")
      (port "4789")
      (protocols (list
          "udp"))
      (comment "Docker Swarm overlay network traffic")))
  (docker_server__ferm__dependent_rules (list
      
      (name "docker_server_resolved_listener")
      (type "accept")
      (daddr (jinja "{{ docker_server__resolved_address }}"))
      (dport "53")
      (saddr (jinja "{{ docker_server__resolved_networks }}"))
      (protocol "udp")
      (rule_state (jinja "{{ \"present\"
                    if (docker_server__resolved_integration | bool)
                    else \"absent\" }}"))
      
      (name "docker_server_swarm_manager")
      (type "accept")
      (saddr (jinja "{{ docker_server__swarm_networks }}"))
      (dport "docker-manager")
      (protocol "tcp")
      (rule_state (jinja "{{ \"present\"
                    if (docker_server__swarm_support | bool)
                    else \"absent\" }}"))
      
      (name "docker_server_swarm_discovery")
      (type "accept")
      (saddr (jinja "{{ docker_server__swarm_networks }}"))
      (dport "docker-discovery")
      (protocol (list
          "tcp"
          "udp"))
      (rule_state (jinja "{{ \"present\"
                    if (docker_server__swarm_support | bool)
                    else \"absent\" }}"))
      
      (name "docker_server_swarm_overlay")
      (type "accept")
      (saddr (jinja "{{ docker_server__swarm_networks }}"))
      (dport "docker-overlay")
      (protocol "udp")
      (rule_state (jinja "{{ \"present\"
                    if (docker_server__swarm_support | bool)
                    else \"absent\" }}")))))
