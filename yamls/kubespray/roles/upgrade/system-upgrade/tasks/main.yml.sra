(playbook "kubespray/roles/upgrade/system-upgrade/tasks/main.yml"
  (tasks
    (task "APT upgrade"
      (include_tasks "apt.yml")
      (when (list
          "system_upgrade"
          "ansible_os_family == \"Debian\""))
      (tags (list
          "system-upgrade-apt")))
    (task "YUM upgrade"
      (include_tasks "yum.yml")
      (when (list
          "system_upgrade"
          "ansible_os_family == \"RedHat\""
          "not is_fedora_coreos"))
      (tags (list
          "system-upgrade-yum")))))
