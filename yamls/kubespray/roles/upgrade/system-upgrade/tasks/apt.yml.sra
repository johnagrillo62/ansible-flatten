(playbook "kubespray/roles/upgrade/system-upgrade/tasks/apt.yml"
  (tasks
    (task "APT Dist-Upgrade"
      (apt 
        (update_cache "true")
        (upgrade "dist")
        (autoremove "true")
        (dpkg_options "force-confold,force-confdef"))
      (register "apt_upgrade"))
    (task "Reboot after APT Dist-Upgrade"
      (reboot null)
      (when (list
          "apt_upgrade.changed or system_upgrade_reboot == 'always'"
          "system_upgrade_reboot != 'never'")))))
