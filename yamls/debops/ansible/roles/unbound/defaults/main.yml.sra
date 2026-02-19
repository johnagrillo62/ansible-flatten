(playbook "debops/ansible/roles/unbound/defaults/main.yml"
  (unbound__base_packages (list
      "unbound"))
  (unbound__packages (list))
  (unbound__default_server (list
      
      (name "localhost-allow_snoop")
      (option "access-control")
      (comment "By default unbound blocks non-recursive queries to prevent abuse; this
prevents commands like 'dig +trace' from working correctly. Since query
tracing is a useful debugging and diagnostic tool, non-recursive queries
will be allowed when the host is managed locally with assumption that
this is an administrator's machine.
")
      (value (list
          
          (name "127.0.0.0/8")
          (args "allow_snoop")
          
          (name "::1/128")
          (args "allow_snoop")))
      (state (jinja "{{ \"present\"
               if (unbound__fact_ansible_connection == \"local\")
               else \"ignore\" }}"))))
  (unbound__server (list))
  (unbound__group_server (list))
  (unbound__host_server (list))
  (unbound__combined_server (jinja "{{ unbound__default_server
                              + unbound__server
                              + unbound__group_server
                              + unbound__host_server }}"))
  (unbound__default_remote_control (list
      
      (name "control-enable")
      (comment "Enable remote control of the 'unbound' daemon by default. This is needed
for the 'systemctl reload unbound.service' command to work correctly.
")
      (value "True")))
  (unbound__remote_control (list))
  (unbound__group_remote_control (list))
  (unbound__host_remote_control (list))
  (unbound__combined_remote_control (jinja "{{ unbound__default_remote_control
                                      + unbound__remote_control
                                      + unbound__group_remote_control
                                      + unbound__host_remote_control }}"))
  (unbound__default_zones (list
      
      (name "block-dns-over-https")
      (comment "Blocking the 'use-application-dns.net' domain instructs the applications
that support DNS over HTTPS to not use it and rely on the system resolver
instead. This might be required for certain applications to support
access to internal services, resolve split-DNS correctly, etc.

Ref: https://support.mozilla.org/en-US/kb/canary-domain-use-application-dnsnet
")
      (zone "use-application-dns.net.")
      (type "local")
      (local_zone_type "always_nxdomain")
      
      (name "lxc-net")
      (comment "Support for resolving LXC container hosts that use the 'lxc-net' bridge
configuration
")
      (zone (jinja "{{ (ansible_local.lxc.net_domain + \".\")
              if (ansible_local.lxc.net_domain | d())
              else \"\" }}"))
      (revdns (jinja "{{ ansible_local.lxc.net_subnet | d(\"\") }}"))
      (nameserver (jinja "{{ ansible_local.lxc.net_address | d(\"\") }}"))
      (state (jinja "{{ \"present\"
               if (ansible_local.lxc.net_domain | d())
               else \"absent\" }}"))
      
      (name "consul")
      (comment "Support for Consul Agent DNS service on localhost
Ref: https://www.consul.io/docs/agent/dns.html
")
      (zone "consul.")
      (type "stub")
      (options (list
          
          (stub-addr "127.0.0.1@8600")))
      (server_options (list
          
          (do-not-query-localhost "False")
          
          (domain-insecure "consul.")))
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.consul | d() and
                   (ansible_local.consul.installed | d()) | bool)
               else \"absent\" }}"))))
  (unbound__zones (list))
  (unbound__group_zones (list))
  (unbound__host_zones (list))
  (unbound__combined_zones (jinja "{{ unbound__default_zones
                             + unbound__zones
                             + unbound__group_zones
                             + unbound__host_zones }}"))
  (unbound__parsed_zones (jinja "{{ unbound__combined_zones
                                | debops.debops.parse_kv_items(merge_keys=[\"server_options\"]) }}"))
  (unbound__python__dependent_packages3 (list
      "python3-unbound"))
  (unbound__python__dependent_packages2 (list
      "python-unbound"))
  (unbound__etc_services__dependent_list (list
      
      (name "unbound-ctrl")
      (port "8953")
      (comment "Unbound control service"))))
