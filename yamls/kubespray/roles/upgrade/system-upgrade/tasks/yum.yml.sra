(playbook "kubespray/roles/upgrade/system-upgrade/tasks/yum.yml"
  (tasks
    (task "YUM upgrade all packages"
      (yum 
        (name "*")
        (state "latest"))
      (register "yum_upgrade"))
    (task "Reboot after YUM upgrade"
      (reboot null)
      (when (list
          "yum_upgrade.changed or system_upgrade_reboot == 'always'"
          "system_upgrade_reboot != 'never'")))))
