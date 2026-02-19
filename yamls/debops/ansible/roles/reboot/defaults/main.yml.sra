(playbook "debops/ansible/roles/reboot/defaults/main.yml"
  (reboot__boot_time_command "uptime")
  (reboot__force "False")
  (reboot__default_search_paths (list
      "/lib/molly-guard"
      "/sbin"
      "/usr/sbin"
      "/usr/local/sbin"))
  (reboot__search_paths (list))
  (reboot__timeout "600"))
