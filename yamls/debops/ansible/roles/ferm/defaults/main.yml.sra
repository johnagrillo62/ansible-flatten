(playbook "debops/ansible/roles/ferm/defaults/main.yml"
  (ferm__enabled (jinja "{{ True
                   if (ansible_system_capabilities is undefined or
                       (((ansible_system_capabilities_enforced | d()) | bool and
                         \"cap_net_admin\" in ansible_system_capabilities) or
                        not (ansible_system_capabilities_enforced | d(True)) | bool))
                   else False }}"))
  (ferm__flush (jinja "{{ ferm__enabled | bool }}"))
  (ferm__iptables_backend_enabled (jinja "{{ False
                                    if ansible_distribution_release in
                                    [\"stretch\", \"trusty\", \"xenial\",
                                     \"bionic\", \"focal\"]
                                    else True }}"))
  (ferm__iptables_backend_type "legacy")
  (ferm__base_packages (list
      "ferm"
      "patch"
      "iptables"
      "arptables"
      "ebtables"))
  (ferm__packages (list))
  (ferm__domains (jinja "{{ lookup(\"flattened\",
                          (([\"ip\"] if (ansible_all_ipv4_addresses | d()) else [])
                           + ([\"ip6\"] if (ansible_all_ipv6_addresses | d()) else [])),
                          wantlist=True) }}"))
  (ferm__ansible_controllers (list))
  (ferm__ansible_controllers_ports (list
      "ssh"))
  (ferm__ansible_controllers_interfaces (list))
  (ferm__fast_mode "False")
  (ferm__use_cache "False")
  (ferm__extra_options "")
  (ferm__default_policy_input "DROP")
  (ferm__default_policy_output "ACCEPT")
  (ferm__default_policy_forward "DROP")
  (ferm__filter_icmp "True")
  (ferm__filter_icmp_limit "10/second")
  (ferm__filter_icmp_burst "10")
  (ferm__filter_icmp_expire (jinja "{{ (60 * 60) }}"))
  (ferm__filter_syn "True")
  (ferm__filter_syn_limit "40/second")
  (ferm__filter_syn_burst "40")
  (ferm__filter_syn_expire (jinja "{{ (60 * 60) }}"))
  (ferm__filter_recent "True")
  (ferm__filter_recent_name "badguys")
  (ferm__filter_recent_time (jinja "{{ (60 * 60 * 2) }}"))
  (ferm__mark_portscan "False")
  (ferm__log "True")
  (ferm__log_type "LOG")
  (ferm__log_map 
    (LOG "LOG log-ip-options log-prefix \"$msg\"")
    (ULOG "ULOG ulog-nlgroup " (jinja "{{ ferm__log_group }}") " ulog-prefix \"$msg\"")
    (NFLOG "NFLOG nflog-group " (jinja "{{ ferm__log_group }}") " nflog-prefix \"$msg\""))
  (ferm__log_target (jinja "{{ ferm__log_map[ferm__log_type] }}"))
  (ferm__log_limit "2/min")
  (ferm__log_burst "5")
  (ferm__log_group "32")
  (ferm__include_legacy "True")
  (ferm__mdns_state "present")
  (ferm__mdns_allow (list))
  (ferm__dependent_rules (list))
  (ferm__fix_dependent_rules (jinja "{{ lookup(\"template\",
                               \"lookup/ferm__fix_dependent_rules.j2\",
                               convert_data=False) | from_yaml }}"))
  (ferm__rules (list))
  (ferm__group_rules (list))
  (ferm__host_rules (list))
  (ferm__combined_rules (jinja "{{ ferm__default_rules
                          + ferm__fix_dependent_rules
                          + ferm__rules
                          + ferm__group_rules
                          + ferm__host_rules }}"))
  (ferm__parsed_rules (jinja "{{ lookup(\"template\",
                        \"lookup/ferm__parsed_rules.j2\",
                        convert_data=False) | from_yaml }}"))
  (ferm_input_list (list))
  (ferm_input_group_list (list))
  (ferm_input_host_list (list))
  (ferm_input_dependent_list (list))
  (ferm__default_weight_map 
    (pre-hook "00")
    (function "00")
    (custom "00")
    (loopback "01")
    (default_policy "05")
    (policy "05")
    (ansible-controller "05")
    (any-whitelist "10")
    (filter-icmp "15")
    (connection-tracking "20")
    (filter-syn "25")
    (any-blacklist "30")
    (sshd-chain "40")
    (any-forward "60")
    (default "100")
    (accept "100")
    (any-service "100")
    (reject "900")
    (any-reject "900")
    (post-hook "950"))
  (ferm__weight_map )
  (ferm__combined_weight_map (jinja "{{ ferm__default_weight_map
                               | combine(ferm__weight_map) }}"))
  (ferm__default_rules (list
      
      (name "policy_filter_input")
      (type "default_policy")
      (chain "INPUT")
      (policy (jinja "{{ ferm__default_policy_input }}"))
      
      (name "policy_filter_forward")
      (type "default_policy")
      (chain "FORWARD")
      (policy (jinja "{{ ferm__default_policy_forward }}"))
      
      (name "policy_filter_output")
      (type "default_policy")
      (chain "OUTPUT")
      (policy (jinja "{{ ferm__default_policy_output }}"))
      
      (name "firewall_hooks")
      (type "custom")
      (comment "Run custom hooks at various firewall stages")
      (rules "@hook pre   \"run-parts /etc/ferm/hooks/pre.d\";
@hook post  \"run-parts /etc/ferm/hooks/post.d\";
@hook flush \"run-parts /etc/ferm/hooks/flush.d\";
")
      
      (name "firewall_variables")
      (type "custom")
      (comment "Define custom variables available in the firewall")
      (rules "@def $domains      = (" (jinja "{{ ferm__domains | unique | join(\" \") }}") ");
@def $ipv4_enabled = " (jinja "{{ \"1\" if \"ip\" in ferm__domains else \"0\" }}") ";
@def $ipv6_enabled = " (jinja "{{ \"1\" if \"ip6\" in ferm__domains else \"0\" }}") ";
")
      
      (name "firewall_log")
      (type "custom")
      (comment "Custom log function used by other rules")
      (rules "@def &log($msg) = {
    mod limit limit " (jinja "{{ ferm__log_limit }}") "
              limit-burst " (jinja "{{ ferm__log_burst }}") "
        " (jinja "{{ ferm__log_target }}") ";
}
")
      (rule_state (jinja "{{ \"present\" if (ferm__log | bool) else \"absent\" }}"))
      
      (name "accept_loopback")
      (type "accept")
      (weight_class "loopback")
      (interface "lo")
      
      (name "accept_ansible_controller")
      (type "ansible_controller")
      (weight_class "ansible-controller")
      (comment "Accept SSH connections from Ansible Controllers")
      (dport (jinja "{{ ferm__ansible_controllers_ports }}"))
      (interface (jinja "{{ ferm__ansible_controllers_interfaces }}"))
      (multiport "True")
      (accept_any "False")
      
      (name "filter_icmp_flood")
      (type "hashlimit")
      (weight_class "filter-icmp")
      (protocol "icmp")
      (rule_state (jinja "{{ \"present\" if (ferm__filter_icmp | bool) else \"absent\" }}"))
      (hashlimit (jinja "{{ ferm__filter_icmp_limit }}"))
      (hashlimit_burst (jinja "{{ ferm__filter_icmp_burst }}"))
      (hashlimit_expire (jinja "{{ ferm__filter_icmp_expire }}"))
      (hashlimit_target "ACCEPT")
      (target "DROP")
      
      (name "connection_tracking")
      (type "connection_tracking")
      (weight_class "connection-tracking")
      (chain (list
          "INPUT"
          "OUTPUT"
          "FORWARD"))
      
      (name "filter_syn_flood")
      (type "hashlimit")
      (weight_class "filter-syn")
      (protocol "tcp")
      (protocol_syn "True")
      (rule_state (jinja "{{ \"present\" if (ferm__filter_syn | bool) else \"absent\" }}"))
      (hashlimit (jinja "{{ ferm__filter_syn_limit }}"))
      (hashlimit_burst (jinja "{{ ferm__filter_syn_burst }}"))
      (hashlimit_expire (jinja "{{ ferm__filter_syn_expire }}"))
      (hashlimit_target "RETURN")
      (target "DROP")
      
      (name "block_recent_badguys")
      (type "recent")
      (weight_class "any-blacklist")
      (comment "Reject packets marked as \"badguys\"")
      (rule_state (jinja "{{ \"present\" if (ferm__filter_recent | bool) else \"absent\" }}"))
      (recent_name (jinja "{{ ferm__filter_recent_name }}"))
      (recent_update "True")
      (recent_seconds (jinja "{{ ferm__filter_recent_time }}"))
      (recent_target "REJECT")
      
      (name "clean_recent_badguys")
      (type "recent")
      (weight_class "any-blacklist")
      (comment "Reject packets marked as \"badguys\"")
      (rule_state (jinja "{{ \"present\" if (ferm__filter_recent | bool) else \"absent\" }}"))
      (recent_name (jinja "{{ ferm__filter_recent_name }}"))
      (recent_remove "True")
      (recent_log "False")
      
      (name "accept_dhcpv6_client_solicit")
      (type "accept")
      (weight_class "any-service")
      (comment "Initial DHCPv6 Solicit message is sent to multicast")
      (domain (list
          "ip6"))
      (saddr (list
          "fe80::/10"))
      (daddr (list
          "ff02::1:2/128"))
      (protocol (list
          "udp"))
      (sport (list
          "dhcpv6-client"))
      (dport (list
          "dhcpv6-server"))
      (rule_state (jinja "{{ \"present\" if (\"ip6\" in ferm__domains) else \"absent\" }}"))
      
      (name "accept_dhcpv6_client")
      (type "accept")
      (weight_class "any-service")
      (comment "DHCPv6 responses seem to be neither RELATED nor ESTABLISHED.")
      (domain (list
          "ip6"))
      (saddr (list
          "fe80::/10"))
      (daddr (list
          "fe80::/10"))
      (protocol (list
          "udp"))
      (sport (list
          "dhcpv6-server"))
      (dport (list
          "dhcpv6-client"))
      (rule_state (jinja "{{ \"present\" if (\"ip6\" in ferm__domains) else \"absent\" }}"))
      
      (name "accept_mdns")
      (type "accept")
      (dport "mdns")
      (comment "Accept Multicast DNS packets from other hosts")
      (saddr (jinja "{{ ferm__mdns_allow }}"))
      (daddr (list
          "224.0.0.251"
          "ff02::fb"))
      (accept_any "True")
      (protocol "udp")
      (rule_state (jinja "{{ ferm__mdns_state }}"))
      
      (name "avahi")
      (type "accept")
      (dport "mdns")
      (saddr (jinja "{{ avahi__allow | d([]) }}"))
      (protocol "udp")
      (accept_any "True")
      (rule_state (jinja "{{ \"present\"
                    if ((ansible_local.nsswitch.conf | d() and
                         (\"mdns4_minimal\" in q(\"flattened\",
                                               ansible_local.nsswitch.conf.hosts | d([])) or
                          \"mdns_minimal\" in q(\"flattened\",
                                              ansible_local.nsswitch.conf.hosts | d([])))) and
                        (ansible_local | d(True) and ansible_local.avahi | d(True) and
                         ((ansible_local[\"avahi\"] | d({})).enabled | d(True)) | bool))
                    else \"absent\" }}"))
      
      (name "jump_to_legacy_input_rules")
      (type "accept")
      (weight "-10")
      (weight_class "reject")
      (comment "Jump to legacy firewall rules")
      (target "debops-legacy-input-rules")
      (rule_state (jinja "{{ \"present\" if (ferm__include_legacy | bool) else \"absent\" }}"))
      
      (name "include_legacy_input_rules")
      (type "include")
      (weight_class "post-hook")
      (chain "debops-legacy-input-rules")
      (comment "Include legacy firewall rules")
      (include "/etc/ferm/filter-input.d/")
      (rule_state (jinja "{{ \"present\" if (ferm__include_legacy | bool) else \"absent\" }}"))
      
      (name "block_portscans")
      (type "recent")
      (weight "85")
      (comment "Mark potential port scanners as bad guys")
      (recent_set_name (jinja "{{ ferm__filter_recent_name }}"))
      (rule_state (jinja "{{ \"present\" if (ferm__mark_portscan | bool) else \"absent\" }}"))
      
      (name "reject_all")
      (type "reject")
      
      (name "fail2ban-hook")
      (type "fail2ban")
      (comment "Reload fail2ban rules")
      (rule_state (jinja "{{ \"present\" if (ferm__fail2ban | bool) else \"absent\" }}"))
      (rules "@hook post \"type fail2ban-server > /dev/null && (fail2ban-client ping > /dev/null && systemctl restart fail2ban > /dev/null || true) || true\";
@hook flush \"type fail2ban-server > /dev/null && (fail2ban-client ping > /dev/null && systemctl restart fail2ban > /dev/null || true) || true\";
")
      (weight_class "post-hook")
      
      (name "forward_external_in")
      (rule_state "absent")
      (weight "1")
      (weight_class "any-forward")
      (type "accept")
      (chain "FORWARD")
      
      (name "forward_external_out")
      (rule_state "absent")
      (weight "2")
      (weight_class "any-forward")
      (type "accept")
      (chain "FORWARD")
      
      (name "forward_internal")
      (rule_state "absent")
      (weight "3")
      (weight_class "any-forward")
      (type "accept")
      (chain "FORWARD")
      
      (name "fix_bootpc_checksum")
      (type "custom")
      (rules "# Add checksums to BOOTP packets from virtual machines and containers.
# https://www.redhat.com/archives/libvir-list/2010-August/msg00035.html
@hook post \"iptables -A POSTROUTING -t mangle -p udp --dport bootpc -j CHECKSUM --checksum-fill\";
")
      (rule_state "ignore")))
  (ferm__custom_files (list))
  (ferm__group_custom_files (list))
  (ferm__host_custom_files (list))
  (ferm__fail2ban "True"))
