(playbook "ansible-for-devops/deployments/playbooks/provision.yml"
    (play
    (hosts "all")
    (become "yes")
    (vars_files (list
        "vars.yml"))
    (roles
      "geerlingguy.git"
      "geerlingguy.nodejs"
      "geerlingguy.ruby"
      "geerlingguy.passenger")
    (tasks
      (task "Install app dependencies."
        (apt 
          (name (list
              "libsqlite3-dev"
              "libreadline-dev"
              "tzdata"))
          (state "present")))
      (task "Ensure app directory exists and is writeable."
        (file 
          (path (jinja "{{ app_directory }}"))
          (state "directory")
          (owner (jinja "{{ app_user }}"))
          (group (jinja "{{ app_user }}"))
          (mode "0755"))))))
