(playbook "kubespray/roles/container-engine/cri-o/tasks/setup-amazon.yaml"
  (tasks
    (task "Check that amzn2-extras.repo exists"
      (stat 
        (path "/etc/yum.repos.d/amzn2-extras.repo"))
      (register "amzn2_extras_file_stat"))
    (task "Find docker repo in amzn2-extras.repo file"
      (lineinfile 
        (dest "/etc/yum.repos.d/amzn2-extras.repo")
        (line "[amzn2extra-docker]"))
      (check_mode "true")
      (register "amzn2_extras_docker_repo")
      (when (list
          "amzn2_extras_file_stat.stat.exists")))
    (task "Remove docker repository"
      (community.general.ini_file 
        (dest "/etc/yum.repos.d/amzn2-extras.repo")
        (section "amzn2extra-docker")
        (option "enabled")
        (value "0")
        (backup "true")
        (mode "0644"))
      (when (list
          "amzn2_extras_file_stat.stat.exists"
          "not amzn2_extras_docker_repo.changed")))))
