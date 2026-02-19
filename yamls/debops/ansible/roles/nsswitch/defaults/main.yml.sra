(playbook "debops/ansible/roles/nsswitch/defaults/main.yml"
  (nsswitch__enabled "True")
  (nsswitch__default_services (list
      "compat"
      "files"
      "dns"
      "db"
      "nis"))
  (nsswitch__services (list))
  (nsswitch__group_services (list))
  (nsswitch__host_services (list))
  (nsswitch__dependent_services (list))
  (nsswitch__remove_services (list))
  (nsswitch__combined_services (jinja "{{ lookup(\"flattened\", (nsswitch__default_services
                                 + nsswitch__services + nsswitch__group_services
                                 + nsswitch__host_services + nsswitch__dependent_services)
                                 | difference(nsswitch__remove_services)).split(\",\") }}"))
  (nsswitch__default_database_map 
    (passwd (list
        "compat"
        "mymachines"
        "systemd"
        "sss"
        "ldap"
        "winbind"))
    (group (list
        "compat"
        "mymachines"
        "systemd"
        "sss"
        "ldap"
        "winbind"))
    (shadow (list
        "compat"
        "sss"))
    (gshadow (list
        "files"))
    (initgroups (list))
    (hosts (list
        "files"
        "mymachines"
        (list
          "mdns_minimal"
          "[NOTFOUND=return]")
        
        (replace "mdns4_minimal")
        (service (jinja "{{ \"mdns_minimal\" if (ansible_local | d() and ansible_local.avahi | d() and
                                      ansible_local.avahi.ipv6 | bool) else \"mdns4_minimal\" }}"))
        (action "[NOTFOUND=return]")
        (list
          "resolve"
          "[!UNAVAIL=return]")
        "dns"
        "libvirt"
        "libvirt_guest"
        "wins"
        "myhostname"))
    (networks (list
        "files"))
    (protocols (list
        "db"
        "files"))
    (services (list
        "db"
        "files"
        "sss"
        "ldap"))
    (ethers (list
        "db"
        "files"))
    (rpc (list
        "db"
        "files"))
    (netgroup (list
        "nis"
        "sss"
        "ldap"))
    (publickey (list))
    (aliases (list))
    (sudoers (list
        
        (service "files")
        (require "False")
        
        (service "sss")
        (require "False")
        
        (service "ldap")
        (require "False")))
    (automount (list
        
        (service "files")
        (require "False")
        
        (service "sss")
        (require "False")
        
        (service "ldap")
        (require "False"))))
  (nsswitch__database_map )
  (nsswitch__group_database_map )
  (nsswitch__host_database_map )
  (nsswitch__combined_database_map (jinja "{{ nsswitch__default_database_map
                                     | combine(nsswitch__database_map)
                                     | combine(nsswitch__group_database_map)
                                     | combine(nsswitch__host_database_map) }}"))
  (nsswitch__database_groups (list
      (list
        "passwd"
        "group"
        "shadow"
        "gshadow"
        "initgroups")
      (list
        "hosts"
        "networks")
      (list
        "protocols"
        "services"
        "ethers"
        "rpc")
      (list
        "netgroup")
      (list
        "aliases"
        "sudoers"
        "automount"))))
