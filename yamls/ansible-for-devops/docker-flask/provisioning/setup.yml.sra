(playbook "ansible-for-devops/docker-flask/provisioning/setup.yml"
  (tasks
    (task "Add vagrant user to docker group."
      (user 
        (name "vagrant")
        (groups "docker")
        (append "true")))
    (task "Install Pip."
      (apt "name=python3-pip state=present"))
    (task "Install Docker Python library."
      (pip "name=docker state=present"))))
