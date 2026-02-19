(playbook "kubespray/roles/kubernetes/preinstall/defaults/main.yml"
  (ignore_assert_errors "false")
  (leave_etc_backup_files "true")
  (nameservers (list))
  (cloud_resolver (list))
  (disable_host_nameservers "false")
  (dns_late "false")
  (disable_ipv6_dns "false")
  (remove_default_searchdomains "false")
  (kube_owner "kube")
  (kube_cert_group "kube-cert")
  (kube_config_dir "/etc/kubernetes")
  (kube_cert_dir (jinja "{{ kube_config_dir }}") "/ssl")
  (kube_cert_compat_dir "/etc/kubernetes/pki")
  (kubelet_flexvolumes_plugins_dir "/usr/libexec/kubernetes/kubelet-plugins/volume/exec")
  (resolveconf_cloud_init_conf "/etc/resolveconf_cloud_init.conf")
  (sysctl_file_path "/etc/sysctl.d/99-sysctl.conf")
  (minimal_node_memory_mb "1024")
  (minimal_master_memory_mb "1500")
  (ntp_manage_config "false")
  (ntp_servers (list
      "0.pool.ntp.org iburst"
      "1.pool.ntp.org iburst"
      "2.pool.ntp.org iburst"
      "3.pool.ntp.org iburst"))
  (ntp_restrict (list
      "127.0.0.1"
      "::1"))
  (ntp_filter_interface "false")
  (ntp_driftfile (jinja "{% if ntp_package == \"ntpsec\" -%}") " /var/lib/ntpsec/ntp.drift " (jinja "{%- else -%}") " /var/lib/ntp/ntp.drift " (jinja "{%- endif -%}"))
  (ntp_tinker_panic "false")
  (ntp_force_sync_immediately "false")
  (ntp_timezone "")
  (supported_os_distributions (list
      "RedHat"
      "CentOS"
      "Fedora"
      "Ubuntu"
      "Debian"
      "Flatcar"
      "Flatcar Container Linux by Kinvolk"
      "Suse"
      "openSUSE Leap"
      "openSUSE Tumbleweed"
      "ClearLinux"
      "OracleLinux"
      "AlmaLinux"
      "Rocky"
      "Amazon"
      "Kylin Linux Advanced Server"
      "UnionTech"
      "UniontechOS"
      "openEuler"))
  (redhat_os_family_extensions (list
      "UnionTech"
      "UniontechOS"))
  (systemd_resolved_disable_stub_listener (jinja "{{ ansible_os_family in ['Flatcar', 'Flatcar Container Linux by Kinvolk'] }}"))
  (disable_fapolicyd "true"))
