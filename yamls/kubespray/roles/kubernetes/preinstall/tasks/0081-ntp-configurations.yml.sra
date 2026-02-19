(playbook "kubespray/roles/kubernetes/preinstall/tasks/0081-ntp-configurations.yml"
  (tasks
    (task "Disable systemd-timesyncd"
      (service 
        (name "systemd-timesyncd.service")
        (enabled "false")
        (state "stopped"))
      (failed_when "false"))
    (task "Set fact NTP settings"
      (set_fact 
        (ntp_config_file (jinja "{% if ntp_package == \"ntp\" -%}") " /etc/ntp.conf " (jinja "{%- elif ntp_package == \"ntpsec\" -%}") " /etc/ntpsec/ntp.conf " (jinja "{%- elif ansible_os_family in ['RedHat', 'Suse'] -%}") " /etc/chrony.conf " (jinja "{%- else -%}") " /etc/chrony/chrony.conf " (jinja "{%- endif -%}"))
        (ntp_service_name (jinja "{% if ntp_package == \"chrony\" -%}") " chronyd " (jinja "{%- elif ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\", \"RedHat\", \"Suse\"] -%}") " ntpd " (jinja "{%- else -%}") " ntp " (jinja "{%- endif %}"))))
    (task "Generate NTP configuration file."
      (template 
        (src (jinja "{{ ntp_config_file | basename }}") ".j2")
        (dest (jinja "{{ ntp_config_file }}"))
        (mode "0644"))
      (notify "Preinstall | restart ntp")
      (when (list
          "ntp_manage_config")))
    (task "Stop the NTP Deamon For Sync Immediately"
      (service 
        (name (jinja "{{ ntp_service_name }}"))
        (state "stopped"))
      (when (list
          "ntp_force_sync_immediately")))
    (task "Force Sync NTP Immediately"
      (command "timeout -k 60s 60s " (jinja "{% if ntp_package == \"chrony\" -%}") " chronyd -q " (jinja "{%- else -%}") " ntpd -gq " (jinja "{%- endif -%}"))
      (when (list
          "ntp_force_sync_immediately")))
    (task "Ensure NTP service is started and enabled"
      (service 
        (name (jinja "{{ ntp_service_name }}"))
        (state "started")
        (enabled "true")))
    (task "Ensure tzdata package"
      (package 
        (name (list
            "tzdata"))
        (state "present"))
      (when (list
          "ntp_timezone"
          "not is_fedora_coreos"
          "not ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]")))
    (task "Gather selinux facts"
      (ansible.builtin.setup 
        (gather_subset "selinux"))
      (when (list
          "ntp_timezone"
          "ansible_os_family == \"RedHat\"")))
    (task "Put SELinux in permissive mode, logging actions that would be blocked."
      (ansible.posix.selinux 
        (policy "targeted")
        (state "permissive"))
      (when (list
          "ntp_timezone"
          "ansible_os_family == \"RedHat\""
          "ansible_facts.selinux.status == 'enabled'"
          "ansible_facts.selinux.mode == 'enforcing'")))
    (task "Set ntp_timezone"
      (community.general.timezone 
        (name (jinja "{{ ntp_timezone }}")))
      (when (list
          "ntp_timezone")))
    (task "Re-enable SELinux"
      (ansible.posix.selinux 
        (policy "targeted")
        (state (jinja "{{ preinstall_selinux_state }}")))
      (when (list
          "ntp_timezone"
          "ansible_os_family == \"RedHat\""
          "ansible_facts.selinux.status == 'enabled'")))))
