(playbook "debops/ansible/roles/docker_server/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.apt 
        (name (jinja "{{ (docker_server__base_packages
               + docker_server__packages) | flatten }}"))
        (state "present")
        (install_recommends "False"))
      (notify (list
          "Refresh host facts"))
      (register "docker_server__register_packages")
      (until "docker_server__register_packages is succeeded"))
    (task "Add specified users to 'docker' group"
      (ansible.builtin.user 
        (name (jinja "{{ item }}"))
        (groups "docker")
        (append "True"))
      (loop (jinja "{{ docker_server__admins }}"))
      (tags (list
          "role::docker_server:config"
          "role::docker_server:admins")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save docker_server local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/docker_server.fact.j2")
        (dest "/etc/ansible/facts.d/docker_server.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Generate Docker configuration file"
      (ansible.builtin.template 
        (src "etc/docker/daemon.json.j2")
        (dest "/etc/docker/daemon.json")
        (mode "0644"))
      (notify (list
          "Restart docker"))
      (tags (list
          "role::docker_server:config")))
    (task "Install ferm post hook"
      (ansible.builtin.template 
        (src "etc/ferm/hooks/post.d/restart-docker.j2")
        (dest "/etc/ferm/hooks/post.d/restart-docker")
        (mode "0755"))
      (when "docker_server__ferm_post_hook | bool"))
    (task "Create resolved.conf.d override directory"
      (ansible.builtin.file 
        (path "/etc/systemd/resolved.conf.d")
        (state "directory")
        (mode "0755"))
      (when "docker_server__resolved_integration | bool"))
    (task "Remove systemd-resolved integration"
      (ansible.builtin.file 
        (path "/etc/systemd/resolved.conf.d/docker.conf")
        (state "absent"))
      (notify (list
          "Restart systemd-resolved service"))
      (when "not docker_server__resolved_integration | bool"))
    (task "Configure systemd-resolved integration"
      (ansible.builtin.template 
        (src "etc/systemd/resolved.conf.d/docker.conf.j2")
        (dest "/etc/systemd/resolved.conf.d/docker.conf")
        (mode "0644"))
      (notify (list
          "Restart systemd-resolved service"))
      (when "docker_server__resolved_integration | bool"))))
