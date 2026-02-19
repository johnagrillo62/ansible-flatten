(playbook "debops/ansible/roles/lxc/defaults/main.yml"
  (lxc__base_packages (list
      (list
        "lxc"
        "lxcfs"
        "debootstrap"
        "xz-utils")
      (jinja "{{ [\"dnsmasq-base\"] if (lxc__net_deploy_state == \"present\") else [] }}")
      (jinja "{{ []
        if (ansible_distribution_release in [\"stretch\", \"trusty\", \"xenial\"])
        else [\"apparmor\", \"lxc-templates\"] }}")))
  (lxc__packages (list))
  (lxc__version (jinja "{{ ansible_local.lxc.version | d(\"0.0.0\") }}"))
  (lxc__root_subuid_start (jinja "{{ ansible_local.root_account.subuids[0][\"start\"]
                            if (ansible_local.root_account.subuids | d())
                            else \"100000\" }}"))
  (lxc__root_subuid_count (jinja "{{ ansible_local.root_account.subuids[0][\"count\"]
                            if (ansible_local.root_account.subuids | d())
                            else \"65536\" }}"))
  (lxc__root_subgid_start (jinja "{{ ansible_local.root_account.subgids[0][\"start\"]
                            if (ansible_local.root_account.subgids | d())
                            else \"100000\" }}"))
  (lxc__root_subgid_count (jinja "{{ ansible_local.root_account.subgids[0][\"count\"]
                            if (ansible_local.root_account.subgids | d())
                            else \"65536\" }}"))
  (lxc__net_deploy_state (jinja "{{ \"absent\"
                           if ((ansible_virtualization_type in [\"lxc\", \"docker\", \"openvz\"] and
                                ansible_virtualization_role == \"guest\") or
                               (inventory_hostname in groups[\"debops_service_lxd\"] | d([])) or
                               (ansible_local.lxd.installed | d(False)) | bool)
                           else \"present\" }}"))
  (lxc__net_resolver (jinja "{{ \"resolvconf\"
                       if ((ansible_local.resolvconf.deploy_state | d(\"absent\")) == \"present\")
                       else (\"systemd-resolved\"
                             if ((ansible_local.resolved.state | d(\"disabled\")) == \"enabled\")
                             else \"none\") }}"))
  (lxc__net_bridge "lxcbr0")
  (lxc__net_address "10.0.3.1/24")
  (lxc__net_router "True")
  (lxc__net_dhcp_start "2")
  (lxc__net_dhcp_end "-2")
  (lxc__net_base_domain (jinja "{{ ansible_domain }}"))
  (lxc__net_domain (jinja "{{ \"lxc\" + ((\".\" + lxc__net_base_domain)
                              if lxc__net_base_domain | d()
                              else \"\") }}"))
  (lxc__net_use_nft "false")
  (lxc__net_fqdn (jinja "{{ ansible_hostname + \".\"
                   + ansible_local.lxc.net_domain | d(lxc__net_domain) }}"))
  (lxc__net_dnsmasq_conf "/etc/lxc/lxc-net-dnsmasq.conf")
  (lxc__net_dnsmasq_options "")
  (lxc__default_configuration (list
      
      (name "lxc")
      (comment "System-wide LXC configuration options")
      (options (list
          
          (name "lxc.lxcpath")
          (comment "Path where LXC containers are stored")
          (value "/var/lib/lxc")
          
          (name "lxc.cgroup.use")
          (value "@all")
          (state (jinja "{{ \"present\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"absent\" }}"))
          
          (name "lxc.default_config")
          (comment "Default configuration file used for new LXC containers if not
specified otherwise
")
          (value "/etc/lxc/privileged.conf")
          
          (name "lxc.default_unprivileged_config")
          (comment "Default configuration file used for new unprivileged LXC containers,
created by the 'lxc-new-unprivileged' script
")
          (value "/etc/lxc/internal-unprivileged.conf")))
      
      (name "unprivileged")
      (options (list
          
          (name (jinja "{{ \"lxc.network.type\"
                  if (lxc__version is version(\"2.1.0\", \"<\"))
                  else \"lxc.net.0.type\" }}"))
          (value "veth")
          
          (name (jinja "{{ \"lxc.network.link\"
                  if (lxc__version is version(\"2.1.0\", \"<\"))
                  else \"lxc.net.0.link\" }}"))
          (value (jinja "{{ \"br0\"
                   if ((ansible_local | d() and ansible_local.ifupdown | d() and
                        (ansible_local.ifupdown.configured | d()) | bool) or
                       (ansible_local.networkd.state | d(\"disabled\")) == \"enabled\")
                   else (lxc__net_bridge
                         if (lxc__net_deploy_state == \"present\")
                         else \"br0\") }}"))
          
          (name (jinja "{{ \"lxc.network.flags\"
                  if (lxc__version is version(\"2.1.0\", \"<\"))
                  else \"lxc.net.0.flags\" }}"))
          (value "up")
          
          (name "lxc.id_map_user")
          (alias (jinja "{{ \"lxc.id_map\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"lxc.idmap\" }}"))
          (value "u 0 " (jinja "{{ lxc__root_subuid_start }}") " " (jinja "{{ lxc__root_subuid_count }}"))
          (separator "True")
          
          (name "lxc.id_map_group")
          (alias (jinja "{{ \"lxc.id_map\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"lxc.idmap\" }}"))
          (value "g 0 " (jinja "{{ lxc__root_subgid_start }}") " " (jinja "{{ lxc__root_subgid_count }}"))
          
          (name "lxc.start.auto")
          (value "0")
          (separator "True")
          
          (name "lxc.cap.drop_secure")
          (alias "lxc.cap.drop")
          (value (jinja "{{ [\"mknod\", \"sys_rawio\", \"syslog\", \"wake_alarm\", \"sys_time\"]
                  + ([] if (lxc__version is version(\"3.0.0\", \"<\") or
                            lxc__version is version(\"4.0.0\", \">=\"))
                  else [\"sys_admin\"]) }}"))
          
          (name "lxc.cgroup.cpuset.cpus")
          (value "0-" (jinja "{{ ansible_processor_vcpus | int - 1 }}"))
          (state "comment")
          (separator "True")
          
          (name "lxc.cgroup.memory.limit_in_bytes")
          (value (jinja "{{ (ansible_memtotal_mb | int / 1024) | round | int }}") "G")
          (state "comment")
          
          (name "lxc.cgroup.memory.memsw.limit_in_bytes")
          (value (jinja "{{ ((ansible_memtotal_mb | int + ansible_swaptotal_mb | int) / 1024) | round | int }}") "G")
          (state "comment")
          
          (name "lxc.apparmor.profile")
          (value "unconfined")
          (state "present")
          
          (name "lxc.apparmor.allow_nesting")
          (value "1")
          (state (jinja "{{ \"absent\"
                   if (lxc__version is version(\"3.0.0\", \"<\") or
                       lxc__version is version(\"4.1.0\", \">=\"))
                   else \"present\" }}"))))
      
      (name "privileged")
      (options (list
          
          (name (jinja "{{ \"lxc.network.type\"
                  if (lxc__version is version(\"2.1.0\", \"<\"))
                  else \"lxc.net.0.type\" }}"))
          (value "veth")
          
          (name (jinja "{{ \"lxc.network.link\"
                  if (lxc__version is version(\"2.1.0\", \"<\"))
                  else \"lxc.net.0.link\" }}"))
          (value (jinja "{{ \"br0\"
                   if ((ansible_local | d() and ansible_local.ifupdown | d() and
                        (ansible_local.ifupdown.configured | d()) | bool) or
                       (ansible_local.networkd.state | d(\"disabled\")) == \"enabled\")
                   else (lxc__net_bridge
                         if (lxc__net_deploy_state == \"present\")
                         else \"br0\") }}"))
          
          (name (jinja "{{ \"lxc.network.flags\"
                  if (lxc__version is version(\"2.1.0\", \"<\"))
                  else \"lxc.net.0.flags\" }}"))
          (value "up")
          
          (name "lxc.start.auto")
          (value "0")
          (separator "True")
          
          (name "lxc.cap.drop_secure")
          (alias "lxc.cap.drop")
          (value (jinja "{{ [\"mknod\", \"sys_rawio\", \"syslog\", \"wake_alarm\", \"sys_time\"]
                  + ([] if (lxc__version is version(\"3.0.0\", \"<\") or
                            lxc__version is version(\"4.0.0\", \">=\"))
                            else [\"sys_admin\"]) }}"))))
      
      (name "internal-unprivileged")
      (state (jinja "{{ \"present\" if (lxc__net_deploy_state == \"present\") else \"absent\" }}"))
      (options (list
          
          (name (jinja "{{ \"lxc.network.type\"
                  if (lxc__version is version(\"2.1.0\", \"<\"))
                  else \"lxc.net.0.type\" }}"))
          (value "veth")
          
          (name (jinja "{{ \"lxc.network.link\"
                  if (lxc__version is version(\"2.1.0\", \"<\"))
                  else \"lxc.net.0.link\" }}"))
          (value (jinja "{{ lxc__net_bridge }}"))
          
          (name (jinja "{{ \"lxc.network.flags\"
                  if (lxc__version is version(\"2.1.0\", \"<\"))
                  else \"lxc.net.0.flags\" }}"))
          (value "up")
          
          (name "lxc.id_map_user")
          (alias (jinja "{{ \"lxc.id_map\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"lxc.idmap\" }}"))
          (value "u 0 " (jinja "{{ lxc__root_subuid_start }}") " " (jinja "{{ lxc__root_subuid_count }}"))
          (separator "True")
          
          (name "lxc.id_map_group")
          (alias (jinja "{{ \"lxc.id_map\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"lxc.idmap\" }}"))
          (value "g 0 " (jinja "{{ lxc__root_subgid_start }}") " " (jinja "{{ lxc__root_subgid_count }}"))
          
          (name "lxc.start.auto")
          (value "0")
          (separator "True")
          
          (name "lxc.cap.drop_secure")
          (alias "lxc.cap.drop")
          (value (jinja "{{ [\"mknod\", \"sys_rawio\", \"syslog\", \"wake_alarm\", \"sys_time\"]
                  + ([] if (lxc__version is version(\"3.0.0\", \"<\") or
                            lxc__version is version(\"4.0.0\", \">=\"))
                            else [\"sys_admin\"]) }}"))
          
          (name "lxc.cgroup.cpuset.cpus")
          (value "0-" (jinja "{{ ansible_processor_vcpus | int - 1 }}"))
          (state "comment")
          (separator "True")
          
          (name "lxc.cgroup.memory.limit_in_bytes")
          (value (jinja "{{ (ansible_memtotal_mb | int / 1024) | round | int }}") "G")
          (state "comment")
          
          (name "lxc.cgroup.memory.memsw.limit_in_bytes")
          (value (jinja "{{ ((ansible_memtotal_mb | int + ansible_swaptotal_mb | int) / 1024) | round | int }}") "G")
          (state "comment")
          
          (name "lxc.apparmor.profile")
          (value "unconfined")
          (state "present")
          
          (name "lxc.apparmor.allow_nesting")
          (value "1")
          (state (jinja "{{ \"absent\"
                   if (lxc__version is version(\"3.0.0\", \"<\") or
                       lxc__version is version(\"4.1.0\", \">=\"))
                   else \"present\" }}"))))
      
      (name "external-internal")
      (options (list
          
          (name "lxc.network.type_net0")
          (alias (jinja "{{ \"lxc.network.type\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"lxc.net.0.type\" }}"))
          (value "veth")
          
          (name "lxc.network.link_net0")
          (alias (jinja "{{ \"lxc.network.link\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"lxc.net.0.link\" }}"))
          (value (jinja "{{ \"br0\"
                   if ((ansible_local | d() and ansible_local.ifupdown | d() and
                        (ansible_local.ifupdown.configured | d()) | bool) or
                       (ansible_local.networkd.state | d(\"disabled\")) == \"enabled\")
                   else (lxc__net_bridge
                         if (lxc__net_deploy_state == \"present\")
                         else \"br0\") }}"))
          
          (name "lxc.network.flags_net0")
          (alias (jinja "{{ \"lxc.network.flags\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"lxc.net.0.flags\" }}"))
          (value "up")
          
          (name "lxc.network.type_net1")
          (alias (jinja "{{ \"lxc.network.type\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"lxc.net.1.type\" }}"))
          (value "veth")
          (separator "True")
          
          (name "lxc.network.link_net1")
          (alias (jinja "{{ \"lxc.network.link\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"lxc.net.1.link\" }}"))
          (value "br1")
          
          (name "lxc.network.flags_net1")
          (alias (jinja "{{ \"lxc.network.flags\"
                   if (lxc__version is version(\"2.1.0\", \"<\"))
                   else \"lxc.net.1.flags\" }}"))
          (value "up")
          
          (name "lxc.start.auto")
          (value "0")
          (separator "True")
          
          (name "lxc.cap.drop_secure")
          (alias "lxc.cap.drop")
          (value (jinja "{{ [\"mknod\", \"sys_rawio\", \"syslog\", \"wake_alarm\", \"sys_time\"]
                  + ([] if (lxc__version is version(\"3.0.0\", \"<\") or
                            lxc__version is version(\"4.0.0\", \">=\"))
                  else [\"sys_admin\"]) }}"))))))
  (lxc__configuration (list))
  (lxc__group_configuration (list))
  (lxc__host_configuration (list))
  (lxc__combined_configuration (jinja "{{ lxc__default_configuration
                                 + lxc__configuration
                                 + lxc__group_configuration
                                 + lxc__host_configuration }}"))
  (lxc__common_default_conf (list
      
      (name "static-hwaddr")
      (comment "Generate static, predictable MAC addresses for container network
interfaces before the container is started. Containers will have to be
restarted for new MAC addresses to be used.
")
      (options (list
          
          (name "lxc.hook.pre-start_hwaddr")
          (alias "lxc.hook.pre-start")
          (value "/usr/local/bin/lxc-hwaddr-static")))
      
      (name "destroy-systemd-instance")
      (comment "At container destruction, ensure that its corresponding systemd service
instance is disabled.
")
      (options (list
          
          (name "lxc.hook.destroy_systemd_instance")
          (alias "lxc.hook.destroy")
          (value "/usr/local/lib/lxc/lxc-destroy-systemd-instance")))))
  (lxc__common_conf (list))
  (lxc__common_group_conf (list))
  (lxc__common_host_conf (list))
  (lxc__common_combined_conf (jinja "{{ lxc__common_default_conf
                               + lxc__common_conf
                               + lxc__common_group_conf
                               + lxc__common_host_conf }}"))
  (lxc__default_container_config "/etc/lxc/unprivileged.conf")
  (lxc__default_container_ssh "True")
  (lxc__default_container_ssh_root_sshkeys (list))
  (lxc__default_container_template "download")
  (lxc__default_container_distribution (jinja "{{ ansible_local.core.distribution | d(ansible_distribution) }}"))
  (lxc__default_container_release (jinja "{{ ansible_local.core.distribution_release | d(ansible_distribution_release) }}"))
  (lxc__default_container_architecture (jinja "{{ \"amd64\"
                                         if (ansible_architecture == \"x86_64\")
                                         else ansible_architecture }}"))
  (lxc__default_container_backing_store "dir")
  (lxc__containers (list))
  (lxc__apt_preferences__dependent_list (list))
  (lxc__python__dependent_packages3 (list
      "python3-lxc"))
  (lxc__python__dependent_packages2 (list
      "python-lxc"))
  (lxc__ferm__dependent_rules (list
      
      (type "custom")
      (by_role "debops.lxc")
      (filename "lxc_bootp_checksum")
      (weight "30")
      (rule_state "absent")
      
      (type "custom")
      (by_role "debops.lxc")
      (name "bootp_checksum")
      (weight "30")
      (rules "# Add checksums to BOOTP packets for LXC containers
# https://www.redhat.com/archives/libvir-list/2010-August/msg00035.html
@hook post \"iptables -A POSTROUTING -t mangle -p udp --dport bootpc -j CHECKSUM --checksum-fill\";
")))
  (lxc__sysctl__dependent_parameters (list
      
      (name "lxc-inotify")
      (divert "True")
      (weight "30")
      (options (list
          
          (name "fs.inotify.max_user_instances")
          (comment "Defines the maximum number of inotify listeners.
By default, this value is 128, which is quickly exhausted when using
systemd-based LXC containers (15 containers are enough).
When the limit is reached, systemd becomes mostly unusable, throwing
\"Too many open files\" all around (both on the host and in containers).
See https://kdecherf.com/blog/2015/09/12/systemd-and-the-fd-exhaustion/
Increase the user inotify instance limit to allow for about
100 containers to run before the limit is hit again
")
          (value "1024"))))))
