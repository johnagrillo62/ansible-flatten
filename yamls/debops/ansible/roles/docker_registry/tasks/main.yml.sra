(playbook "debops/ansible/roles/docker_registry/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ (docker_registry__base_packages
               + docker_registry__packages) | flatten }}"))
        (state "present"))
      (register "docker_registry__register_packages")
      (until "docker_registry__register_packages is succeeded"))
    (task "Divert the original docker-registry config file"
      (debops.debops.dpkg_divert 
        (path "/etc/docker/registry/config.yml"))
      (notify (list
          "Restart docker-registry")))
    (task "Create Docker Registry UNIX group"
      (ansible.builtin.group 
        (name (jinja "{{ docker_registry__group }}"))
        (state "present")
        (system "True")))
    (task "Create Docker Registry UNIX account"
      (ansible.builtin.user 
        (name (jinja "{{ docker_registry__user }}"))
        (group (jinja "{{ docker_registry__group }}"))
        (groups (jinja "{{ docker_registry__additional_groups | flatten }}"))
        (home (jinja "{{ docker_registry__home }}"))
        (comment (jinja "{{ docker_registry__comment }}"))
        (shell (jinja "{{ docker_registry__shell }}"))
        (state "present")
        (system "True")))
    (task "Create required directories"
      (ansible.builtin.file 
        (name (jinja "{{ item.path }}"))
        (state "directory")
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode }}")))
      (with_items (list
          
          (path (jinja "{{ docker_registry__config_file | dirname }}"))
          (mode "0755")
          
          (path (jinja "{{ docker_registry__storage_dir | dirname }}"))
          (mode "0755")
          
          (path (jinja "{{ docker_registry__storage_dir }}"))
          (owner (jinja "{{ docker_registry__user }}"))
          (group (jinja "{{ docker_registry__group }}"))
          (mode (jinja "{{ docker_registry__storage_mode }}")))))
    (task "Build Docker Registry from upstream"
      (block (list
          
          (name "Create required build directories")
          (ansible.builtin.file 
            (name (jinja "{{ item.path }}"))
            (state "directory")
            (mode (jinja "{{ item.mode }}")))
          (with_items (list
              
              (path (jinja "{{ docker_registry__src }}"))
              (mode "0755")
              
              (path (jinja "{{ docker_registry__git_dir | dirname }}"))
              (mode "0755")))
          
          (name "Clone Docker Registry source code")
          (ansible.builtin.git 
            (repo (jinja "{{ docker_registry__git_repo }}"))
            (dest (jinja "{{ docker_registry__git_dest }}"))
            (version (jinja "{{ docker_registry__git_version }}"))
            (separate_git_dir (jinja "{{ docker_registry__git_dir }}"))
            (verify_commit "True"))
          (register "docker_registry__register_source")
          
          (name "Build Docker Registry binaries")
          (environment 
            (GOPATH (jinja "{{ docker_registry__gopath }}"))
            (GOCACHE (jinja "{{ docker_registry__gopath + \"/cache\" }}")))
          (ansible.builtin.command "make clean binaries")
          (args 
            (chdir (jinja "{{ docker_registry__git_dest }}")))
          (when "docker_registry__register_source is changed")
          (register "docker_registry__register_build")
          (changed_when "docker_registry__register_build.changed | bool")))
      (become "True")
      (become_user (jinja "{{ docker_registry__user }}"))
      (when "docker_registry__upstream | bool"))
    (task "Install Docker Registry binary"
      (ansible.builtin.copy 
        (src (jinja "{{ docker_registry__git_dest + \"/bin/registry\" }}"))
        (dest "/usr/local/bin/docker-registry")
        (remote_src "True")
        (mode "0755"))
      (notify (list
          "Restart docker-registry"))
      (when "docker_registry__upstream | bool and docker_registry__register_build is changed"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Docker Registry local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/docker_registry.fact.j2")
        (dest "/etc/ansible/facts.d/docker_registry.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Generate Docker Registry configuration"
      (ansible.builtin.template 
        (src "etc/docker/registry/config.yml.j2")
        (dest (jinja "{{ docker_registry__config_file }}"))
        (owner (jinja "{{ docker_registry__user }}"))
        (group (jinja "{{ docker_registry__group }}"))
        (mode "0600"))
      (notify (list
          "Restart docker-registry"))
      (register "docker_registry__register_config"))
    (task "Generate Docker Registry systemd unit"
      (ansible.builtin.template 
        (src "etc/systemd/system/docker-registry.service.j2")
        (dest "/etc/systemd/system/docker-registry.service")
        (mode "0644"))
      (register "docker_registry__register_systemd"))
    (task "Enable Docker Registry service"
      (ansible.builtin.systemd 
        (name "docker-registry")
        (daemon_reload (jinja "{{ True if docker_registry__register_systemd is changed else omit }}"))
        (enabled "True")))
    (task "Install garbage collector script"
      (ansible.builtin.template 
        (src (jinja "{{ item.path }}") ".j2")
        (dest "/" (jinja "{{ item.path }}"))
        (mode (jinja "{{ item.mode }}")))
      (loop (list
          
          (path "usr/local/bin/docker-registry-gc")
          (mode "0755")
          
          (path "etc/sudoers.d/docker-registry-gc")
          (mode "0440")))
      (when "docker_registry__garbage_collector_enabled | bool"))
    (task "Configure garbage collection in cron"
      (ansible.builtin.cron 
        (name "Perform garbage collection in Docker Registry")
        (cron_file "docker-registry-gc")
        (user (jinja "{{ docker_registry__user }}"))
        (job "/usr/local/bin/docker-registry-gc")
        (special_time (jinja "{{ docker_registry__garbage_collector_interval }}"))
        (state (jinja "{{ \"present\"
               if docker_registry__garbage_collector_enabled | bool
               else \"absent\" }}"))))))
