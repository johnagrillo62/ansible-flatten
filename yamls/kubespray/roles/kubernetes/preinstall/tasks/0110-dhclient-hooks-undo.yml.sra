(playbook "kubespray/roles/kubernetes/preinstall/tasks/0110-dhclient-hooks-undo.yml"
  (tasks
    (task "Remove kubespray specific config from dhclient config"
      (blockinfile 
        (path (jinja "{{ dhclientconffile }}"))
        (state "absent")
        (backup (jinja "{{ leave_etc_backup_files }}"))
        (marker "# Ansible entries {mark}"))
      (notify "Preinstall | propagate resolvconf to k8s components"))
    (task "Remove kubespray specific dhclient hook"
      (file 
        (path (jinja "{{ dhclienthookfile }}"))
        (state "absent"))
      (notify "Preinstall | propagate resolvconf to k8s components"))))
