(playbook "kubespray/roles/bootstrap_os/defaults/main.yml"
  (centos_fastestmirror_enabled "false")
  (rh_subscription_check_timeout "180")
  (coreos_locksmithd_disable "false")
  (epel_enabled "false")
  (use_oracle_public_repo "true")
  (ubuntu_kernel_unattended_upgrades_disabled "false")
  (ubuntu_stop_unattended_upgrades "false")
  (fedora_coreos_packages (list
      "python"
      "python3-libselinux"
      "ethtool"
      "ipset"
      "conntrack-tools"
      "containernetworking-plugins"))
  (override_system_hostname "true")
  (is_fedora_coreos "false")
  (skip_http_proxy_on_os_packages "false"))
