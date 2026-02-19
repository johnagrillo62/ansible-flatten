(playbook "debops/ansible/roles/avahi/defaults/main.yml"
  (avahi__enabled "True")
  (avahi__base_packages (list
      "avahi-daemon"
      "avahi-utils"
      "libnss-mdns"))
  (avahi__packages (list))
  (avahi__domain "local")
  (avahi__use_ipv4 "True")
  (avahi__use_ipv6 (jinja "{{ True
                     if (ansible_all_ipv6_addresses
                         | difference(ansible_all_ipv6_addresses
                         | ansible.utils.ipv6(\"link-local\")))
                     else False }}"))
  (avahi__allow_interfaces (list))
  (avahi__deny_interfaces (list))
  (avahi__check_response_ttl "False")
  (avahi__use_iff_running "False")
  (avahi__enable_dbus "True")
  (avahi__disallow_other_stacks "True")
  (avahi__add_service_cookie "True")
  (avahi__publish_hinfo "False")
  (avahi__publish_workstation "False")
  (avahi__publish_device_info (jinja "{{ True
                                if not avahi__publish_workstation | bool
                                else False }}"))
  (avahi__publish_ssh "True")
  (avahi__daemon_conf_default_server 
    (use-ipv4 (jinja "{{ avahi__use_ipv4 }}"))
    (use-ipv6 (jinja "{{ avahi__use_ipv6 }}"))
    (allow-interfaces (jinja "{{ avahi__allow_interfaces }}"))
    (deny-interfaces (jinja "{{ avahi__deny_interfaces }}"))
    (check-response-ttl (jinja "{{ avahi__check_response_ttl }}"))
    (use-iff-running (jinja "{{ avahi__use_iff_running }}"))
    (enable-dbus (jinja "{{ avahi__enable_dbus }}"))
    (disallow-other-stacks (jinja "{{ avahi__disallow_other_stacks }}"))
    (ratelimit-interval-usec "1000000")
    (ratelimit-burst "1000"))
  (avahi__daemon_conf_server )
  (avahi__daemon_conf_default_wide_area 
    (enable-wide-area "True"))
  (avahi__daemon_conf_wide_area )
  (avahi__daemon_conf_default_publish 
    (add-service-cookie (jinja "{{ avahi__add_service_cookie }}"))
    (publish-hinfo (jinja "{{ avahi__publish_hinfo }}"))
    (publish-workstation (jinja "{{ avahi__publish_workstation }}")))
  (avahi__daemon_conf_publish )
  (avahi__daemon_conf_default_reflector 
    (enable-reflector "False")
    (reflect-ipv "False"))
  (avahi__daemon_conf_reflector )
  (avahi__daemon_conf_default_rlimits 
    (rlimit-as "")
    (rlimit-core "0")
    (rlimit-data "4194304")
    (rlimit-fsize "0")
    (rlimit-nofile "768")
    (rlimit-stack "4194304")
    (rlimit-nproc "32"))
  (avahi__daemon_conf_rlimits )
  (avahi__allow (list))
  (avahi__alias_enabled (jinja "{{ True
                          if (ansible_local | d() and ansible_local.python | d() and
                              (ansible_local.python.installed2 | d()) | bool)
                          else False }}"))
  (avahi__alias_install_path (jinja "{{ ansible_local.fhs.sbin | d(\"/usr/local/sbin\") }}"))
  (avahi__alias_config_file "/etc/avahi/aliases")
  (avahi__hosts )
  (avahi__group_hosts )
  (avahi__host_hosts )
  (avahi__default_services 
    (device-info 
      (comment "Set server icon for this host on compatible devices")
      (type "_device-info._tcp")
      (txt "model=RackMac")
      (state (jinja "{{ \"present\"
               if avahi__publish_device_info | bool
               else \"absent\" }}")))
    (sftp-ssh 
      (name "SFTP on %h")
      (type "_sftp-ssh._tcp")
      (port "22")
      (state (jinja "{{ \"present\"
               if avahi__publish_ssh | bool
               else \"absent\" }}")))
    (ssh 
      (name "SSH on %h")
      (type "_ssh._tcp")
      (port "22")
      (state (jinja "{{ \"present\"
               if avahi__publish_ssh | bool
               else \"absent\" }}"))))
  (avahi__dependent_services )
  (avahi__services )
  (avahi__group_services )
  (avahi__host_services )
  (avahi__combined_services (jinja "{{ lookup(\"template\",
                              \"lookup/avahi__combined_services.j2\",
                              convert_data=False) | from_yaml }}"))
  (avahi__python__dependent_packages3 (list))
  (avahi__python__dependent_packages2 (list
      "python-avahi"))
  (avahi__ferm__dependent_rules (list
      
      (name "avahi")
      (type "accept")
      (dport "mdns")
      (saddr (jinja "{{ avahi__allow }}"))
      (protocol "udp")
      (accept_any "True")
      (rule_state (jinja "{{ \"present\" if (avahi__enabled | bool) else \"absent\" }}")))))
