(playbook "ansible-for-devops/first-ansible-playbook/playbook.yml"
    (play
    (hosts "all")
    (become "yes")
    (tasks
      (task "Ensure chrony (for time synchronization) is installed."
        (dnf 
          (name "chrony")
          (state "present")))
      (task "Ensure chrony is running."
        (service 
          (name "chronyd")
          (state "started")
          (enabled "yes")))))
    (play
    (hosts "all")
    (become "yes")
    (tasks
      (task
        (dnf "name=chrony state=present"))
      (task
        (service "name=chronyd state=started enabled=yes")))))
