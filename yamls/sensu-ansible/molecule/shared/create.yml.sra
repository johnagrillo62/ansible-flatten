(playbook "sensu-ansible/molecule/shared/create.yml"
    (play
    (name "Create")
    (hosts "localhost")
    (connection "local")
    (gather_facts "false")
    (no_log (jinja "{{ not lookup('env', 'MOLECULE_DEBUG') | bool }}"))
    (tasks
      (task "Log into a Docker registry"
        (docker_login 
          (username (jinja "{{ item.registry.credentials.username }}"))
          (password (jinja "{{ item.registry.credentials.password }}"))
          (email (jinja "{{ item.registry.credentials.email | default(omit) }}"))
          (registry (jinja "{{ item.registry.url }}"))
          (docker_host (jinja "{{ item.docker_host | default('unix://var/run/docker.sock') }}")))
        (loop (jinja "{{ molecule_yml.platforms }}"))
        (when (list
            "item.registry is defined"
            "item.registry.credentials is defined"
            "item.registry.credentials.username is defined")))
      (task "Create Dockerfiles from image names"
        (template 
          (src (jinja "{{ molecule_scenario_directory }}") "/Dockerfile.j2")
          (dest (jinja "{{ molecule_ephemeral_directory }}") "/Dockerfile_" (jinja "{{ item.image | regex_replace('[^a-zA-Z0-9_]', '_') }}")))
        (loop (jinja "{{ molecule_yml.platforms }}"))
        (register "platforms"))
      (task "Discover local Docker images"
        (docker_image_facts 
          (name "molecule_local/" (jinja "{{ item.item.name }}"))
          (docker_host (jinja "{{ item.item.docker_host | default('unix://var/run/docker.sock') }}")))
        (loop (jinja "{{ platforms.results }}"))
        (register "docker_images"))
      (task "Build an Ansible compatible image"
        (docker_image 
          (path (jinja "{{ molecule_ephemeral_directory }}"))
          (name "molecule_local/" (jinja "{{ item.item.image }}"))
          (docker_host (jinja "{{ item.item.docker_host | default('unix://var/run/docker.sock') }}"))
          (dockerfile (jinja "{{ item.item.dockerfile | default(item.invocation.module_args.dest) }}"))
          (force (jinja "{{ item.item.force | default(true) }}")))
        (loop (jinja "{{ platforms.results }}"))
        (when "platforms.changed or docker_images.results | map(attribute='images') | select('equalto', []) | list | count >= 0"))
      (task "Create docker network(s)"
        (docker_network 
          (name (jinja "{{ item }}"))
          (docker_host (jinja "{{ item.docker_host | default('unix://var/run/docker.sock') }}"))
          (state "present"))
        (loop (jinja "{{ molecule_yml.platforms | molecule_get_docker_networks }}")))
      (task "Create molecule instance(s)"
        (docker_container 
          (name (jinja "{{ item.name }}"))
          (docker_host (jinja "{{ item.docker_host | default('unix://var/run/docker.sock') }}"))
          (hostname (jinja "{{ item.name }}"))
          (image "molecule_local/" (jinja "{{ item.image }}"))
          (state "started")
          (recreate "false")
          (log_driver "json-file")
          (command (jinja "{{ item.command | default('bash -c \\\"while true; do sleep 10000; done\\\"') }}"))
          (privileged (jinja "{{ item.privileged | default(omit) }}"))
          (volumes (jinja "{{ item.volumes | default(omit) }}"))
          (capabilities (jinja "{{ item.capabilities | default(omit) }}"))
          (exposed_ports (jinja "{{ item.exposed_ports | default(omit) }}"))
          (published_ports (jinja "{{ item.published_ports | default(omit) }}"))
          (ulimits (jinja "{{ item.ulimits | default(omit) }}"))
          (networks (jinja "{{ item.networks | default(omit) }}"))
          (dns_servers (jinja "{{ item.dns_servers | default(omit) }}")))
        (async "7200")
        (poll "0")
        (register "server")
        (loop (jinja "{{ molecule_yml.platforms }}")))
      (task "Wait for instance(s) creation to complete"
        (async_status 
          (jid (jinja "{{ item.ansible_job_id }}")))
        (register "docker_jobs")
        (until "docker_jobs.finished")
        (retries "300")
        (loop (jinja "{{ server.results }}"))))))
