(playbook "debops/ansible/roles/tinc/defaults/main.yml"
  (tinc__default_networks 
    (mesh0 
      (port "655")))
  (tinc__networks )
  (tinc__group_networks )
  (tinc__host_networks )
  (tinc__combined_networks (jinja "{{ lookup(\"template\",
                             \"lookup/tinc__combined_networks.j2\",
                             convert_data=False) | from_yaml }}"))
  (tinc__base_packages (list
      "tinc"))
  (tinc__packages (list))
  (tinc__inventory_hosts (jinja "{{ groups.debops_service_tinc | d([]) }}"))
  (tinc__inventory_self (list
      (jinja "{{ tinc__hostname }}")
      (jinja "{{ tinc__inventory_hostname }}")))
  (tinc__inventory_hostname (jinja "{{ inventory_hostname }}"))
  (tinc__hostname (jinja "{{ inventory_hostname_short }}"))
  (tinc__user "tinc-vpn")
  (tinc__group "tinc-vpn")
  (tinc__home "/etc/tinc")
  (tinc__ulimit_memlock (jinja "{{ (1024 * tinc__rsa_key_length | int * 16) }}"))
  (tinc__ulimit_options "-l " (jinja "{{ tinc__ulimit_memlock }}"))
  (tinc__extra_options "")
  (tinc__systemd (jinja "{{ True
                   if (ansible_service_mgr | d(\"unknown\") == \"systemd\")
                   else False }}"))
  (tinc__vcs_ignore_patterns (list
      "rsa_key.priv"))
  (tinc__rsa_key_length "8192")
  (tinc__hwaddr_prefix "de")
  (tinc__metric "100")
  (tinc__host_addresses (jinja "{{ tinc__host_addresses_fqdn +
                          tinc__host_addresses_ip_public }}"))
  (tinc__host_addresses_fqdn (jinja "{{ [ansible_fqdn]
                               if ((ansible_all_ipv4_addresses | d([])
                                    + (ansible_all_ipv6_addresses | d([])
                                       | difference(ansible_all_ipv6_addresses | d([])
                                                    | ansible.utils.ipaddr(\"link-local\"))))
                                   | ansible.utils.ipaddr(\"public\"))
                               else [] }}"))
  (tinc__host_addresses_ip_public (jinja "{{ (ansible_all_ipv4_addresses | d([])
                                     + (ansible_all_ipv6_addresses | d([])
                                        | difference(ansible_all_ipv6_addresses | d([])
                                                     | ansible.utils.ipaddr(\"link-local\"))))
                                    | ansible.utils.ipaddr(\"public\") }}"))
  (tinc__host_addresses_ip_private (jinja "{{ (ansible_all_ipv4_addresses | d([])
                                      + (ansible_all_ipv6_addresses | d([])
                                         | difference(ansible_all_ipv6_addresses | d([])
                                                      | ansible.utils.ipaddr(\"link-local\"))))
                                     | ansible.utils.ipaddr(\"private\") }}"))
  (tinc__exclude_addresses (jinja "{{ lookup(\"template\",
                             \"lookup/tinc__exclude_addresses.j2\",
                             convert_data=False) | from_yaml }}"))
  (tinc__modprobe "True")
  (tinc__modprobe_modules (list
      "tun"))
  (tinc__secret__directories (jinja "{{ lookup(\"template\",
                               \"lookup/tinc__secret_directories.j2\",
                               convert_data=False) | from_yaml }}"))
  (tinc__etc_services__dependent_list (jinja "{{ lookup(\"template\",
                                        \"lookup/tinc__etc_services__dependent_list.j2\",
                                        convert_data=False) | from_yaml }}"))
  (tinc__ferm__dependent_rules (jinja "{{ lookup(\"template\",
                                 \"lookup/tinc__ferm__dependent_rules.j2\",
                                 convert_data=False) | from_yaml }}"))
  (tinc__persistent_paths__dependent_paths 
    (50_debops_tinc 
      (by_role "debops.tinc")
      (paths (jinja "{{ [
  '/etc/tinc',
  '/etc/systemd/system/tinc.service',
  '/etc/systemd/system/tinc@.service',
  '/etc/systemd/system/multi-user.target.wants/tinc.service',
] + ((ansible_local.tinc.networks.keys() | map(\"regex_replace\", \"^\", \"/etc/default/tinc-\") | list)
     if (ansible_local.tinc.networks | d())
     else [])
}}") "
"))))
