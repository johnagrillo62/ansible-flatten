(playbook "ansible-for-devops/docker-hubot/main.yml"
    (play
    (hosts "localhost")
    (connection "local")
    (gather_facts "false")
    (vars
      (base_image "node:14")
      (container_name "hubot_slack")
      (image_namespace "a4d")
      (image_name "hubot-slack"))
    (pre_tasks
      (task "Make the latest version of the base image available locally."
        (docker_image 
          (name (jinja "{{ base_image }}"))
          (source "pull")
          (force_source "true")))
      (task "Create the Docker container."
        (docker_container 
          (image (jinja "{{ base_image }}"))
          (name (jinja "{{ container_name }}"))
          (command "sleep infinity")))
      (task "Add the newly created container to the inventory."
        (add_host 
          (hostname (jinja "{{ container_name }}"))
          (ansible_connection "docker"))))
    (roles
      
        (name "hubot-slack")
        (delegate_to (jinja "{{ container_name }}")))
    (post_tasks
      (task "Clean up the container."
        (shell "apt-get remove --purge -y python && rm -rf /var/lib/apt/lists/*
")
        (delegate_to (jinja "{{ container_name }}")))
      (task "Commit the container."
        (command "docker commit -c 'USER hubot' -c 'WORKDIR \"/home/hubot\"' -c 'CMD [\"bin/hubot\", \"--adapter\", \"slack\"]' -c 'VOLUME [\"/home/hubot/scripts\"]' " (jinja "{{ container_name }}") " " (jinja "{{ image_namespace }}") "/" (jinja "{{ image_name }}") ":latest
"))
      (task "Remove the container."
        (docker_container 
          (name (jinja "{{ container_name }}"))
          (state "absent"))))))
