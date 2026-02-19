(playbook "kubespray/roles/kubernetes/preinstall/tasks/main.yml"
  (tasks
    (task "Disable swap"
      (import_tasks "0010-swapoff.yml")
      (when (list
          "not dns_late"
          "kubelet_fail_swap_on")))
    (task "Set facts"
      (import_tasks "0020-set_facts.yml")
      (tags (list
          "resolvconf"
          "facts")))
    (task "Check settings"
      (import_tasks "0040-verify-settings.yml")
      (when (list
          "not dns_late"))
      (tags (list
          "asserts")))
    (task "Create directories"
      (import_tasks "0050-create_directories.yml")
      (when (list
          "not dns_late")))
    (task "Apply resolvconf settings"
      (import_tasks "0060-resolvconf.yml")
      (when (list
          "dns_mode != 'none'"
          "resolvconf_mode == 'host_resolvconf'"
          "systemd_resolved_enabled.rc != 0"
          "networkmanager_enabled.rc != 0"))
      (tags (list
          "bootstrap_os"
          "resolvconf")))
    (task "Apply systemd-resolved settings"
      (import_tasks "0061-systemd-resolved.yml")
      (when (list
          "dns_mode != 'none'"
          "resolvconf_mode == 'host_resolvconf'"
          "systemd_resolved_enabled.rc == 0"))
      (tags (list
          "bootstrap_os"
          "resolvconf")))
    (task "Apply networkmanager unmanaged devices settings"
      (import_tasks "0062-networkmanager-unmanaged-devices.yml")
      (when (list
          "networkmanager_enabled.rc == 0"))
      (tags (list
          "bootstrap_os")))
    (task "Apply networkmanager DNS settings"
      (import_tasks "0063-networkmanager-dns.yml")
      (when (list
          "dns_mode != 'none'"
          "resolvconf_mode == 'host_resolvconf'"
          "networkmanager_enabled.rc == 0"))
      (tags (list
          "bootstrap_os"
          "resolvconf")))
    (task "Apply system configurations"
      (import_tasks "0080-system-configurations.yml")
      (when (list
          "not dns_late"))
      (tags (list
          "bootstrap_os")))
    (task "Configure NTP"
      (import_tasks "0081-ntp-configurations.yml")
      (when (list
          "not dns_late"
          "ntp_enabled"))
      (tags (list
          "bootstrap_os")))
    (task "Configure dhclient"
      (import_tasks "0100-dhclient-hooks.yml")
      (when (list
          "dns_mode != 'none'"
          "resolvconf_mode == 'host_resolvconf'"
          "dhclientconffile is defined"
          "not ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"))
      (tags (list
          "bootstrap_os"
          "resolvconf")))
    (task "Configure dhclient dhclient hooks"
      (import_tasks "0110-dhclient-hooks-undo.yml")
      (when (list
          "dns_mode != 'none'"
          "resolvconf_mode != 'host_resolvconf'"
          "dhclientconffile is defined"
          "not ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"))
      (tags (list
          "bootstrap_os"
          "resolvconf")))
    (task "Flush handlers"
      (meta "flush_handlers"))
    (task "Check if we are running inside a Azure VM"
      (stat 
        (path "/var/lib/waagent/")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "azure_check")
      (when (list
          "not dns_late"))
      (tags (list
          "bootstrap_os")))
    (task "Run calico checks"
      (include_role 
        (name "network_plugin/calico")
        (tasks_from "check"))
      (when (list
          "kube_network_plugin == 'calico'"
          "not ignore_assert_errors")))))
