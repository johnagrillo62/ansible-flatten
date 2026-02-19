(playbook "kubespray/roles/bootstrap_os/tasks/ubuntu.yml"
  (tasks
    (task "Import Debian bootstrap"
      (import_tasks "debian.yml"))
    (task "Check unattended-upgrades file exist"
      (stat 
        (path "/etc/apt/apt.conf.d/50unattended-upgrades"))
      (register "unattended_upgrades_file_stat")
      (when (list
          "ubuntu_kernel_unattended_upgrades_disabled")))
    (task "Disable kernel unattended-upgrades"
      (lineinfile 
        (path (jinja "{{ unattended_upgrades_file_stat.stat.path }}"))
        (insertafter "Unattended-Upgrade::Package-Blacklist")
        (line "\"linux-\";")
        (state "present"))
      (become "true")
      (when (list
          "ubuntu_kernel_unattended_upgrades_disabled"
          "unattended_upgrades_file_stat.stat.exists")))
    (task "Stop unattended-upgrades service"
      (service 
        (name "unattended-upgrades")
        (state "stopped")
        (enabled "false"))
      (become "true")
      (when "ubuntu_stop_unattended_upgrades"))))
