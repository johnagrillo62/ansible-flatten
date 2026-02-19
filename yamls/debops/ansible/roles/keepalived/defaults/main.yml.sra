(playbook "debops/ansible/roles/keepalived/defaults/main.yml"
  (keepalived__base_packages (list
      "keepalived"))
  (keepalived__packages (list))
  (keepalived__host_group "debops_service_keepalived")
  (keepalived__host_count (jinja "{{ (groups[keepalived__host_group] | count - 1) }}"))
  (keepalived__host_index (jinja "{{ groups[keepalived__host_group].index(inventory_hostname) }}"))
  (keepalived__allow (list))
  (keepalived__group_allow (list))
  (keepalived__host_allow (list))
  (keepalived__default_configuration (list
      
      (name "global_defs")
      (raw "global_defs {
    process_names
    router_id " (jinja "{{ ansible_hostname }}") "
}
")
      (state "present")))
  (keepalived__configuration (list))
  (keepalived__group_configuration (list))
  (keepalived__host_configuration (list))
  (keepalived__combined_configuration (jinja "{{ keepalived__default_configuration
                                        + keepalived__configuration
                                        + keepalived__group_configuration
                                        + keepalived__host_configuration }}"))
  (keepalived__scripts (list))
  (keepalived__group_scripts (list))
  (keepalived__host_scripts (list))
  (keepalived__sysctl__dependent_parameters (list
      
      (name "keepalived")
      (weight "80")
      (options (list
          
          (name "net.ipv4.ip_nonlocal_bind")
          (comment "This parameter allows processes to bind to IPv4 addresses that are
not local to permit failover.
")
          (value "1")
          
          (name "net.ipv6.ip_nonlocal_bind")
          (comment "This parameter allows processes to bind to IPv6 addresses that are
not local to permit failover.
")
          (value "1")))))
  (keepalived__ferm__dependent_rules (list
      
      (name "accept_vrrp_keepalived")
      (type "accept")
      (protocol "vrrp")
      (saddr (jinja "{{ keepalived__allow + keepalived__group_allow + keepalived__host_allow }}"))
      (daddr (list
          "224.0.0.18"
          "ff02::12"))
      (accept_any "False")
      (weight "50")
      (by_role "debops.keepalived"))))
