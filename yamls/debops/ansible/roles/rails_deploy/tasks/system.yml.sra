(playbook "debops/ansible/roles/rails_deploy/tasks/system.yml"
  (tasks
    (task "Install app packages"
      (ansible.builtin.package 
        (name (jinja "{{ item }}"))
        (state "present"))
      (with_items (jinja "{{ rails_deploy_packages + [\"git\"] }}"))
      (register "rails_deploy__register_packages")
      (until "rails_deploy__register_packages is succeeded"))
    (task "Create app group"
      (ansible.builtin.group 
        (name (jinja "{{ rails_deploy_service }}"))
        (state "present")
        (system "True"))
      (when "rails_deploy_service is defined and rails_deploy_service"))
    (task "Create app user"
      (ansible.builtin.user 
        (name (jinja "{{ rails_deploy_service }}"))
        (group (jinja "{{ rails_deploy_service }}"))
        (home (jinja "{{ rails_deploy_home }}"))
        (generate_ssh_key "True")
        (comment (jinja "{{ rails_deploy_service }}"))
        (groups (jinja "{{ rails_deploy_user_groups | join(\",\") }}"))
        (shell "/bin/bash")
        (append "True")
        (system "True")
        (state "present"))
      (when "rails_deploy_service is defined and rails_deploy_service"))
    (task "Allow ssh access from the app user"
      (ansible.posix.authorized_key 
        (key (jinja "{{ rails_deploy_user_sshkey }}"))
        (user (jinja "{{ rails_deploy_service }}"))
        (manage_dir "False"))
      (when "rails_deploy_service is defined and rails_deploy_service and 'sshusers' in rails_deploy_user_groups and rails_deploy_user_sshkey"))
    (task "Create backup copy of the host's ssh keys"
      (ansible.builtin.fetch 
        (dest (jinja "{{ secret }}") "/storage/sensitive/" (jinja "{{ rails_deploy_service }}"))
        (src (jinja "{{ item }}"))
        (validate_md5 "True"))
      (when "rails_deploy_service is defined and rails_deploy_service and secret is defined and secret")
      (with_items (list
          (jinja "{{ rails_deploy_home }}") "/.ssh/id_rsa"
          (jinja "{{ rails_deploy_home }}") "/.ssh/id_rsa.pub"))
      (tags "system_backup"))
    (task "Secure app home directory"
      (ansible.builtin.file 
        (path (jinja "{{ rails_deploy_home }}"))
        (state "directory")
        (owner (jinja "{{ rails_deploy_service }}"))
        (group (jinja "{{ rails_deploy_service }}"))
        (mode "0751"))
      (when "rails_deploy_service is defined and rails_deploy_service"))
    (task "Create src, log and run state paths"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ rails_deploy_service }}"))
        (group (jinja "{{ rails_deploy_service }}"))
        (mode "0755"))
      (when "rails_deploy_service is defined and rails_deploy_service")
      (with_items (list
          (jinja "{{ rails_deploy_src }}")
          (jinja "{{ rails_deploy_log }}")
          (jinja "{{ rails_deploy_run }}"))))
    (task "Create logrotate file"
      (ansible.builtin.template 
        (src "etc/logrotate.d/service.j2")
        (dest "/etc/logrotate.d/" (jinja "{{ rails_deploy_service }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "rails_deploy_service is defined and rails_deploy_service"))
    (task "Create /etc/default/app file"
      (ansible.builtin.template 
        (src "etc/default/app.j2")
        (dest "/etc/default/" (jinja "{{ rails_deploy_service }}"))
        (owner (jinja "{{ rails_deploy_service }}"))
        (group (jinja "{{ rails_deploy_service }}"))
        (mode "0644"))
      (when "rails_deploy_service is defined and rails_deploy_service"))
    (task "Create application service"
      (ansible.builtin.template 
        (src "etc/init.d/service.j2")
        (dest "/etc/init.d/" (jinja "{{ rails_deploy_service }}"))
        (owner (jinja "{{ rails_deploy_service }}"))
        (group (jinja "{{ rails_deploy_service }}"))
        (mode "0755"))
      (when "rails_deploy_service is defined and rails_deploy_service and rails_deploy_backend")
      (with_items (list
          "service")))
    (task "Create background worker service"
      (ansible.builtin.template 
        (src "etc/init.d/service.j2")
        (dest "/etc/init.d/" (jinja "{{ rails_deploy_worker }}"))
        (owner (jinja "{{ rails_deploy_service }}"))
        (group (jinja "{{ rails_deploy_service }}"))
        (mode "0755"))
      (when "rails_deploy_worker_enabled and rails_deploy_worker is defined and rails_deploy_worker")
      (with_items (list
          "worker")))))
