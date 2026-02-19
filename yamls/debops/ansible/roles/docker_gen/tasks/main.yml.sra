(playbook "debops/ansible/roles/docker_gen/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Create required directories"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (loop (list
          (jinja "{{ docker_gen__src }}")
          (jinja "{{ docker_gen__lib }}")
          (jinja "{{ docker_gen__templates }}")
          (jinja "{{ ((docker_gen__nginx_dest | dirname)
           if (docker_gen__nginx | d() and docker_gen__nginx)
           else []) }}"))))
    (task "Download docker-gen sources"
      (ansible.builtin.get_url 
        (url (jinja "{{ docker_gen__release }}"))
        (dest (jinja "{{ docker_gen__src + \"/\" + docker_gen__release | basename }}"))
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Unpack docker-gen"
      (ansible.builtin.unarchive 
        (src (jinja "{{ docker_gen__src + \"/\" + docker_gen__release | basename }}"))
        (dest (jinja "{{ docker_gen__lib }}"))
        (copy "False")
        (owner "root")
        (group "root")
        (mode "u=rwX,g=rX,o=rX"))
      (register "docker_gen__register_install"))
    (task "Copy docker-gen templates to remote host"
      (ansible.builtin.copy 
        (src "usr/local/lib/templates/")
        (dest (jinja "{{ docker_gen__templates + \"/\" }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart docker-gen")))
    (task "Configure docker-gen"
      (ansible.builtin.template 
        (src "etc/docker-gen.conf.j2")
        (dest "/etc/docker-gen.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart docker-gen")))
    (task "Configure docker-gen service options"
      (ansible.builtin.template 
        (src "etc/default/docker-gen.j2")
        (dest "/etc/default/docker-gen")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart docker-gen")))
    (task "Configure docker-gen init script"
      (ansible.builtin.template 
        (src "etc/init.d/docker-gen.j2")
        (dest "/etc/init.d/docker-gen")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Reload service manager"
          "Restart docker-gen"))
      (when "ansible_service_mgr != 'systemd'"))
    (task "Configure docker-gen systemd service"
      (ansible.builtin.template 
        (src "etc/systemd/system/docker-gen.service.j2")
        (dest "/etc/systemd/system/docker-gen.service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "docker_gen__register_service")
      (notify (list
          "Reload service manager"
          "Restart docker-gen"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Reload systemd daemons"
      (ansible.builtin.meta "flush_handlers"))
    (task "Start docker-gen on install"
      (ansible.builtin.service 
        (name "docker-gen")
        (state "started")
        (enabled "True"))
      (when "docker_gen__register_install | d() and docker_gen__register_install is changed"))))
