(playbook "debops/ansible/roles/netbase/defaults/main.yml"
  (netbase__enabled (jinja "{{ False
                      if (ansible_virtualization_type == \"docker\" and
                          ansible_virtualization_role == \"guest\")
                      else True }}"))
  (netbase__base_packages (list
      "netbase"
      "libcap2-bin"
      "dbus"))
  (netbase__packages (list))
  (netbase__hostname_config_enabled (jinja "{{ True
                                      if ((((ansible_system_capabilities_enforced | d()) | bool and
                                           \"cap_sys_admin\" in ansible_system_capabilities) or
                                          not (ansible_system_capabilities_enforced | d(True)) | bool) and
                                          (ansible_virtualization_type is undefined or
                                           ansible_virtualization_type not in [\"lxc\", \"docker\", \"openvz\"]))
                                      else False }}"))
  (netbase__hostname (jinja "{{ (inventory_hostname_short | d(inventory_hostname.split(\".\")[0]))
                       if (inventory_hostname_short | d(inventory_hostname.split(\".\")[0]) != \"localhost\")
                       else ansible_hostname }}"))
  (netbase__domain (jinja "{{ \"\"
                     if (ansible_local | d() and ansible_local.netbase | d() and
                         (((ansible_local.netbase.self_address | d()) != \"127.0.1.1\" and
                           (not ansible_local.netbase.self_local_hostname | d()) | bool) or
                          ((ansible_local.netbase.self_address | d()) == \"127.0.1.1\" and
                            ansible_local.netbase.self_domain | d() and
                            ansible_local.netbase.self_domain_source in [\"dns\"])))
                     else (ansible_local.netbase.self_domain
                           if (ansible_local | d() and ansible_local.netbase | d() and
                               (ansible_local.netbase.self_domain | d()) and
                               (ansible_local.netbase.self_local_hostname | d()) | bool)
                           else ((ansible_host | d(ansible_ssh_host | d(\"0\"))).split(\".\")[1:] | join(\".\")
                                 if (not (ansible_host | d(ansible_ssh_host | d(\"0\"))) | ansible.utils.ipaddr)
                                 else (inventory_hostname.split(\".\")[1:] | join(\".\")
                                       if (inventory_hostname.split(\".\") | count > 1)
                                       else \"\"))) }}"))
  (netbase__aliases (jinja "{{ ([netbase__hostname]
                       + ansible_local.netbase.self_aliases | d([]) | unique) }}"))
  (netbase__host_ipv4_address (jinja "{{ (ansible_default_ipv4.address | d())
                                if (ansible_domain | d() and
                                    ansible_local | d() and ansible_local.netbase | d() and
                                    ansible_local.netbase.self_domain_source in [\"dns\"])
                                else ansible_local.netbase.self_address | d(\"127.0.1.1\") }}"))
  (netbase__host_ipv6_address (jinja "{{ ansible_default_ipv6.address | d() }}"))
  (netbase__domain_host_entry (jinja "{{ ([netbase__hostname + \".\" + netbase__domain] + netbase__aliases)
                                if netbase__domain | d()
                                else (netbase__hostname
                                      if (not ansible_domain | d())
                                      else []) }}"))
  (netbase__hosts_config_type (jinja "{{ \"template\"
                                if ((netbase__hosts
                                     | combine(netbase__group_hosts, netbase__host_hosts)).keys()
                                    | count > 15)
                                else \"lineinfile\" }}"))
  (netbase__default_hosts (list
      
      (127.0.0.1 (list
          "localhost"))
      
      (127.0.1.1 (list))
      
      (::1 (list
          "localhost"
          "ip6-localhost"
          "ip6-loopback"))
      
      (ff02::1 (list
          "ip6-allnodes"))
      
      (ff02::2 (list
          "ip6-allrouters"))
      
      (name (jinja "{{ netbase__host_ipv4_address }}"))
      (value (jinja "{{ netbase__domain_host_entry }}"))
      (separator (jinja "{{ True
                   if (netbase__host_ipv4_address == \"127.0.1.1\" and
                       (ansible_local | d() and ansible_local.netbase | d() and
                        ansible_local.netbase.self_domain_source not in [\"dns\"]))
                   else False }}"))
      
      (name (jinja "{{ netbase__host_ipv6_address }}"))
      (value (jinja "{{ netbase__domain_host_entry }}"))))
  (netbase__hosts (list))
  (netbase__group_hosts (list))
  (netbase__host_hosts (list))
  (netbase__combined_hosts (jinja "{{ netbase__default_hosts
                            + netbase__hosts
                            + netbase__group_hosts
                            + netbase__host_hosts }}"))
  (netbase__networks )
  (netbase__group_networks )
  (netbase__host_networks )
  (netbase__python__dependent_packages3 (list
      "python3-dnspython"))
  (netbase__python__dependent_packages2 (list
      "python-dnspython")))
