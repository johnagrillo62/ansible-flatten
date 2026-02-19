(playbook "sensu-ansible/molecule/shared/destroy.yml"
    (play
    (name "Destroy")
    (hosts "localhost")
    (connection "local")
    (gather_facts "false")
    (no_log (jinja "{{ not lookup('env', 'MOLECULE_DEBUG') | bool }}"))
    (tasks
      (task "Destroy molecule instance(s)"
        (docker_container 
          (name (jinja "{{ item.name }}"))
          (docker_host (jinja "{{ item.docker_host | default('unix://var/run/docker.sock') }}"))
          (state "absent")
          (force_kill (jinja "{{ item.force_kill | default(true) }}")))
        (async "7200")
        (poll "0")
        (register "server")
        (loop (jinja "{{ molecule_yml.platforms }}")))
      (task "Wait for instance(s) deletion to complete"
        (async_status 
          (jid (jinja "{{ item.ansible_job_id }}")))
        (register "docker_jobs")
        (until "docker_jobs.finished")
        (retries "300")
        (loop (jinja "{{ server.results }}")))
      (task "Delete docker network(s)"
        (docker_network 
          (name (jinja "{{ item }}"))
          (docker_host (jinja "{{ item.docker_host | default('unix://var/run/docker.sock') }}"))
          (state "absent"))
        (loop (jinja "{{ molecule_yml.platforms | molecule_get_docker_networks }}"))))))
