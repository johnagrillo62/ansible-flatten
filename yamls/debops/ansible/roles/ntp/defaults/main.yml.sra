(playbook "debops/ansible/roles/ntp/defaults/main.yml"
  (ntp__daemon_enabled (jinja "{{ \"True\"
                         if (ntp__daemon | d(False) and
                             not (ansible_virtualization_role | d(\"\") == \"guest\" and
                                  ansible_virtualization_type | d(\"\")
                                    in [\"container\", \"lxc\"]) and
                             not (ansible_system_capabilities_enforced | d(True) | bool and
                                  \"cap_sys_time\" not in ansible_system_capabilities))
                         else \"False\" }}"))
  (ntp__daemon (jinja "{{ (ansible_local.ntp.daemon
                  if (ansible_local.ntp.daemon | d())
                  else (\"systemd-timesyncd\"
                        if (ansible_service_mgr == \"systemd\")
                        else \"openntpd\")) }}"))
  (ntp__ignore_ntpdate "False")
  (ntp__servers (jinja "{{ (ntp__servers_map[ansible_distribution][1]
                   | d(ntp__servers_map[\"default\"][1]))
                   if (ntp__daemon in [\"chrony\"])
                   else ntp__servers_map[ansible_distribution]
                        | d(ntp__servers_map[\"default\"]) }}"))
  (ntp__servers_map 
    (Debian (list
        "0.debian.pool.ntp.org"
        "1.debian.pool.ntp.org"
        "2.debian.pool.ntp.org"
        "3.debian.pool.ntp.org"))
    (Ubuntu (list
        "0.ubuntu.pool.ntp.org"
        "1.ubuntu.pool.ntp.org"
        "2.ubuntu.pool.ntp.org"
        "3.ubuntu.pool.ntp.org"))
    (default (list
        "0.pool.ntp.org"
        "1.pool.ntp.org"
        "2.pool.ntp.org"
        "3.pool.ntp.org")))
  (ntp__fudge "True")
  (ntp__servers_as_pool "True")
  (ntp__base_packages (list
      (jinja "{{ \"chrony\" if (ntp__daemon == \"chrony\") else [] }}")
      (jinja "{{ \"ntp\" if (ntp__daemon == \"ntpd\") else [] }}")
      (jinja "{{ \"openntpd\" if (ntp__daemon == \"openntpd\") else [] }}")
      (jinja "{{ \"systemd-timesyncd\" if (ntp__daemon == \"systemd-timesyncd\" and
                                ansible_distribution_release
                                not in [\"stretch\", \"buster\"]) else [] }}")
      (jinja "{{ \"ntpdate\" if (ntp__daemon == \"ntpdate\") else [] }}")))
  (ntp__packages (list))
  (ntp__purge_packages (list
      (jinja "{{ \"chrony\" if (ntp__daemon != \"chrony\") else [] }}")
      (jinja "{{ \"ntp\" if (ntp__daemon not in [\"ntpd\", \"openntpd\"]) else [] }}")
      (jinja "{{ \"openntpd\" if (ntp__daemon != \"openntpd\") else [] }}")
      (jinja "{{ \"systemd-timesyncd\" if (ntp__daemon != \"systemd-timesyncd\") else [] }}")
      (jinja "{{ \"ntpdate\" if (ntp__daemon != \"ntpdate\" and
                      not ntp__ignore_ntpdate | bool) else [] }}")))
  (ntp__openntpd_options "-f /etc/openntpd/ntpd.conf -s")
  (ntp__chrony_cmdport "0")
  (ntp__listen (list))
  (ntp__firewall_access "False")
  (ntp__allow (list))
  (ntp__ferm_chain "filter-ntp")
  (ntp__ferm_weight "40")
  (ntp__ferm_recent_seconds (jinja "{{ (60 * 60) }}"))
  (ntp__ferm_recent_hitcount "5")
  (ntp__ferm_recent_target "DROP")
  (ntp__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "ntp"))
      (protocol "udp")
      (weight (jinja "{{ ntp__ferm_weight }}"))
      (role "ntp")
      (role_weight "10")
      (name "jump-filter-ntp")
      (target (jinja "{{ ntp__ferm_chain }}"))
      (rule_state (jinja "{{ \"present\"
                    if (ntp__daemon in [\"openntpd\", \"ntpd\", \"chrony\"] and
                        ntp__firewall_access | bool)
                    else \"absent\" }}"))
      
      (chain (jinja "{{ ntp__ferm_chain }}"))
      (type "recent")
      (dport (list
          "ntp"))
      (protocol "udp")
      (saddr (jinja "{{ ntp__allow }}"))
      (weight (jinja "{{ ntp__ferm_weight }}"))
      (role "ntp")
      (role_weight "20")
      (name "mark")
      (subchain "False")
      (recent_set_name "ntp-new")
      (recent_log "False")
      (rule_state (jinja "{{ \"present\"
                    if (ntp__daemon in [\"openntpd\", \"ntpd\", \"chrony\"] and
                        ntp__firewall_access | bool)
                    else \"absent\" }}"))
      
      (chain (jinja "{{ ntp__ferm_chain }}"))
      (type "recent")
      (dport (list
          "ntp"))
      (protocol (list
          "udp"))
      (weight (jinja "{{ ntp__ferm_weight }}"))
      (role "ntp")
      (role_weight "30")
      (name "filter")
      (subchain "False")
      (recent_name "ntp-new")
      (recent_update "True")
      (recent_seconds (jinja "{{ ntp__ferm_recent_seconds }}"))
      (recent_hitcount (jinja "{{ ntp__ferm_recent_hitcount }}"))
      (recent_target (jinja "{{ ntp__ferm_recent_target }}"))
      (recent_log_prefix "ipt-recent-ntp: ")
      (rule_state (jinja "{{ \"present\"
                    if (ntp__daemon in [\"openntpd\", \"ntpd\", \"chrony\"] and
                        ntp__firewall_access | bool)
                    else \"absent\" }}"))
      
      (chain (jinja "{{ ntp__ferm_chain }}"))
      (type "accept")
      (dport (list
          "ntp"))
      (protocol "udp")
      (state "NEW")
      (saddr (jinja "{{ ntp__allow }}"))
      (weight (jinja "{{ ntp__ferm_weight }}"))
      (role "ntp")
      (role_weight "40")
      (rule_state (jinja "{{ \"present\"
                    if (ntp__daemon in [\"openntpd\", \"ntpd\", \"chrony\"] and
                        ntp__firewall_access | bool)
                    else \"absent\" }}")))))
