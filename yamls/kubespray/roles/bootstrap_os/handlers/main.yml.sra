(playbook "kubespray/roles/bootstrap_os/handlers/main.yml"
  (tasks
    (task "RHEL auto-attach subscription"
      (command "/sbin/subscription-manager attach --auto")
      (become "true"))))
