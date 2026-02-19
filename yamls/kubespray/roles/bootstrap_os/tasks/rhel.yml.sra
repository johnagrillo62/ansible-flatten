(playbook "kubespray/roles/bootstrap_os/tasks/rhel.yml"
  (tasks
    (task "Gather host facts to get ansible_distribution_version ansible_distribution_major_version"
      (setup 
        (gather_subset "!all")
        (filter "ansible_distribution_*version")))
    (task "Add proxy to yum.conf or dnf.conf if http_proxy is defined"
      (community.general.ini_file 
        (path (jinja "{{ ((ansible_distribution_major_version | int) < 8) | ternary('/etc/yum.conf', '/etc/dnf/dnf.conf') }}"))
        (section "main")
        (option "proxy")
        (value (jinja "{{ http_proxy | default(omit) }}"))
        (state (jinja "{{ http_proxy | default(False) | ternary('present', 'absent') }}"))
        (no_extra_spaces "true")
        (mode "0644"))
      (become "true")
      (when "not skip_http_proxy_on_os_packages"))
    (task "Add proxy to RHEL subscription-manager if http_proxy is defined"
      (command "/sbin/subscription-manager config --server.proxy_hostname=" (jinja "{{ http_proxy | regex_replace(':\\d+$') | regex_replace('^.*://') }}") " --server.proxy_port=" (jinja "{{ http_proxy | regex_replace('^.*:') }}"))
      (become "true")
      (when (list
          "not skip_http_proxy_on_os_packages"
          "http_proxy is defined")))
    (task "Check RHEL subscription-manager status"
      (command "/sbin/subscription-manager status")
      (timeout (jinja "{{ rh_subscription_check_timeout }}"))
      (register "rh_subscription_status")
      (changed_when "rh_subscription_status.rc != 0")
      (ignore_errors "true")
      (become "true"))
    (task "RHEL subscription Organization ID/Activation Key registration"
      (community.general.redhat_subscription 
        (state "present")
        (org_id (jinja "{{ rh_subscription_org_id }}"))
        (activationkey (jinja "{{ rh_subscription_activation_key }}"))
        (force_register "true"))
      (notify "RHEL auto-attach subscription")
      (become "true")
      (when (list
          "rh_subscription_org_id is defined"
          "rh_subscription_status.changed")))
    (task "RHEL subscription Username/Password registration"
      (community.general.redhat_subscription 
        (state "present")
        (username (jinja "{{ rh_subscription_username }}"))
        (password (jinja "{{ rh_subscription_password }}"))
        (auto_attach "true")
        (force_register "true")
        (syspurpose 
          (usage (jinja "{{ rh_subscription_usage }}"))
          (role (jinja "{{ rh_subscription_role }}"))
          (service_level_agreement (jinja "{{ rh_subscription_sla }}"))
          (sync "true")))
      (notify "RHEL auto-attach subscription")
      (become "true")
      (no_log (jinja "{{ not (unsafe_show_logs | bool) }}"))
      (when (list
          "rh_subscription_username is defined"
          "rh_subscription_status.changed")))
    (task "Enable RHEL 8 repos"
      (community.general.rhsm_repository 
        (name (list
            "rhel-8-for-*-baseos-rpms"
            "rhel-8-for-*-appstream-rpms"))
        (state (jinja "{{ 'enabled' if (rhel_enable_repos | default(True) | bool) else 'disabled' }}")))
      (when (list
          "ansible_distribution_major_version == \"8\""
          "(not rh_subscription_status.changed) or (rh_subscription_username is defined) or (rh_subscription_org_id is defined)")))
    (task "Check presence of fastestmirror.conf"
      (stat 
        (path "/etc/yum/pluginconf.d/fastestmirror.conf")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "fastestmirror"))
    (task "Disable fastestmirror plugin if requested"
      (lineinfile 
        (dest "/etc/yum/pluginconf.d/fastestmirror.conf")
        (regexp "^enabled=.*")
        (line "enabled=0")
        (state "present"))
      (become "true")
      (when (list
          "fastestmirror.stat.exists"
          "not centos_fastestmirror_enabled")))))
