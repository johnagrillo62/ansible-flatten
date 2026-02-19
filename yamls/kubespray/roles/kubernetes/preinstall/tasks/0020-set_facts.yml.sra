(playbook "kubespray/roles/kubernetes/preinstall/tasks/0020-set_facts.yml"
  (tasks
    (task "Set os_family fact for other redhat-based operating systems"
      (set_fact 
        (ansible_os_family "RedHat")
        (ansible_distribution_major_version "8"))
      (when "ansible_distribution in redhat_os_family_extensions")
      (tags (list
          "facts")))
    (task "Check resolvconf"
      (command "which resolvconf")
      (register "resolvconf")
      (failed_when "false")
      (changed_when "false")
      (check_mode "false"))
    (task "Check existence of /etc/resolvconf/resolv.conf.d"
      (stat 
        (path "/etc/resolvconf/resolv.conf.d")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (failed_when "false")
      (register "resolvconfd_path"))
    (task "Check status of /etc/resolv.conf"
      (stat 
        (path "/etc/resolv.conf")
        (follow "false")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (failed_when "false")
      (register "resolvconf_stat"))
    (task "Fetch resolv.conf"
      (slurp 
        (src "/etc/resolv.conf"))
      (when "resolvconf_stat.stat.exists")
      (register "resolvconf_slurp"))
    (task "NetworkManager | Check if host has NetworkManager"
      (command "systemctl is-active --quiet NetworkManager.service")
      (register "networkmanager_enabled")
      (failed_when "false")
      (changed_when "false")
      (check_mode "false"))
    (task "Check systemd-resolved"
      (command "systemctl is-active systemd-resolved")
      (register "systemd_resolved_enabled")
      (failed_when "false")
      (changed_when "false")
      (check_mode "false"))
    (task "Set default dns if remove_default_searchdomains is false"
      (set_fact 
        (default_searchdomains (list
            "default.svc." (jinja "{{ dns_domain }}")
            "svc." (jinja "{{ dns_domain }}"))))
      (when "not remove_default_searchdomains | default() | bool or (remove_default_searchdomains | default() | bool and searchdomains | length == 0)"))
    (task "Set dns facts"
      (set_fact 
        (resolvconf (jinja "{%- if resolvconf.rc == 0 and resolvconfd_path.stat.isdir is defined and resolvconfd_path.stat.isdir -%}") "true" (jinja "{%- else -%}") "false" (jinja "{%- endif -%}"))))
    (task "Check if kubelet is configured"
      (stat 
        (path (jinja "{{ kube_config_dir }}") "/kubelet.env")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "kubelet_configured")
      (changed_when "false"))
    (task "Check if early DNS configuration stage"
      (set_fact 
        (dns_early (jinja "{{ not kubelet_configured.stat.exists }}"))))
    (task "Target resolv.conf files"
      (set_fact 
        (resolvconffile "/etc/resolv.conf")
        (base (jinja "{%- if resolvconf | bool -%}") "/etc/resolvconf/resolv.conf.d/base" (jinja "{%- endif -%}"))
        (head (jinja "{%- if resolvconf | bool -%}") "/etc/resolvconf/resolv.conf.d/head" (jinja "{%- endif -%}")))
      (when "not ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"] and not is_fedora_coreos"))
    (task "Target temporary resolvconf cloud init file (Flatcar Container Linux by Kinvolk / Fedora CoreOS)"
      (set_fact 
        (resolvconffile "/tmp/resolveconf_cloud_init_conf"))
      (when "ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"] or is_fedora_coreos"))
    (task "Check if /etc/dhclient.conf exists"
      (stat 
        (path "/etc/dhclient.conf")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "dhclient_stat"))
    (task "Target dhclient conf file for /etc/dhclient.conf"
      (set_fact 
        (dhclientconffile "/etc/dhclient.conf"))
      (when "dhclient_stat.stat.exists"))
    (task "Check if /etc/dhcp/dhclient.conf exists"
      (stat 
        (path "/etc/dhcp/dhclient.conf")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "dhcp_dhclient_stat"))
    (task "Target dhclient conf file for /etc/dhcp/dhclient.conf"
      (set_fact 
        (dhclientconffile "/etc/dhcp/dhclient.conf"))
      (when "dhcp_dhclient_stat.stat.exists"))
    (task "Target dhclient hook file for Red Hat family"
      (set_fact 
        (dhclienthookfile "/etc/dhcp/dhclient.d/zdnsupdate.sh"))
      (when "ansible_os_family == \"RedHat\""))
    (task "Target dhclient hook file for Debian family"
      (set_fact 
        (dhclienthookfile "/etc/dhcp/dhclient-exit-hooks.d/zdnsupdate"))
      (when "ansible_os_family == \"Debian\""))
    (task "Set etcd vars if using kubeadm mode"
      (set_fact 
        (etcd_cert_dir (jinja "{{ kube_cert_dir }}"))
        (kube_etcd_cacert_file "etcd/ca.crt")
        (kube_etcd_cert_file "apiserver-etcd-client.crt")
        (kube_etcd_key_file "apiserver-etcd-client.key"))
      (when (list
          "etcd_deployment_type == \"kubeadm\"")))
    (task "Check /usr readonly"
      (stat 
        (path "/usr")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "usr"))
    (task "Set alternate flexvolume path"
      (set_fact 
        (kubelet_flexvolumes_plugins_dir "/var/lib/kubelet/volumeplugins"))
      (when "not usr.stat.writeable"))))
