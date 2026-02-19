(playbook "debops/ansible/roles/ntp/tasks/install.yml"
  (tasks
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ (ntp__base_packages + ntp__packages) | flatten }}"))
        (state "present"))
      (register "ntp__register_apt_install")
      (until "ntp__register_apt_install is succeeded"))
    (task "Query available systemd services"
      (ansible.builtin.service_facts null)
      (when "ansible_service_mgr == \"systemd\""))
    (task "Manage systemd-timesyncd state"
      (ansible.builtin.service 
        (name "systemd-timesyncd")
        (state (jinja "{{ \"started\" if (ntp__daemon in [\"systemd-timesyncd\"]) else \"stopped\" }}"))
        (enabled (jinja "{{ True if (ntp__daemon in [\"systemd-timesyncd\"]) else False }}")))
      (when (list
          "ansible_service_mgr == \"systemd\""
          "(\"systemd-timesyncd.service\" in ansible_facts.services and ansible_facts.services['systemd-timesyncd.service'].status != 'not-found')")))
    (task "Install chrony"
      (ansible.builtin.include_tasks "chrony.yml")
      (when "ntp__daemon == 'chrony'"))
    (task "Install ntpd"
      (ansible.builtin.include_tasks "ntpd.yml")
      (when "ntp__daemon in [ 'ntpd', 'ntpdate' ]"))
    (task "Install OpenNTPd"
      (ansible.builtin.include_tasks "openntpd.yml")
      (when "ntp__daemon == 'openntpd'"))
    (task "Include systemd-timesyncd configuration"
      (ansible.builtin.include_tasks "systemd-timesyncd.yml")
      (when "(ansible_service_mgr == \"systemd\" and ntp__daemon == 'systemd-timesyncd')"))))
