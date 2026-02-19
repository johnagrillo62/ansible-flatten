(playbook "debops/ansible/roles/gitlab/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save information about GitLab in Ansible Facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/gitlab.fact.j2")
        (dest "/etc/ansible/facts.d/gitlab.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Flush handlers if needed"
      (ansible.builtin.meta "flush_handlers"))
    (task "Create GitLab UNIX system group"
      (ansible.builtin.group 
        (name (jinja "{{ gitlab__group }}"))
        (state "present")
        (system "True")))
    (task "Create GitLab UNIX system account"
      (ansible.builtin.user 
        (name (jinja "{{ gitlab__user }}"))
        (group (jinja "{{ gitlab__group }}"))
        (groups (jinja "{{ gitlab__additional_groups }}"))
        (comment (jinja "{{ gitlab__comment }}"))
        (home (jinja "{{ gitlab__home }}"))
        (shell (jinja "{{ gitlab__shell }}"))
        (state "present")
        (append "True")
        (system "True")))
    (task "Create GitLab configuration directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (state "directory")
        (mode (jinja "{{ item.mode }}")))
      (loop (list
          
          (path "/etc/gitlab/ssl")
          (mode "0755")
          
          (path "/etc/gitlab/trusted-certs")
          (mode "0755"))))
    (task "Manage CA certificate symlinks in GitLab environment"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/gitlab/trusted-certs/\" + item.link }}"))
        (src (jinja "{{ item.src }}"))
        (state (jinja "{{ item.state | d(\"link\") }}")))
      (loop (jinja "{{ q(\"flattened\", (gitlab__ssl_default_cacerts + gitlab__ssl_cacerts)) }}"))
      (notify (list
          "Restart GitLab Omnibus"))
      (when "gitlab__pki_enabled | bool"))
    (task "Manage private key and SSL certificate symlinks in GitLab environment"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/gitlab/ssl/\" + item.link }}"))
        (src (jinja "{{ item.src }}"))
        (state (jinja "{{ item.state | d(\"link\") }}")))
      (loop (jinja "{{ q(\"flattened\", (gitlab__ssl_default_symlinks + gitlab__ssl_symlinks)) }}"))
      (notify (list
          "Restart GitLab Omnibus"))
      (when "gitlab__pki_enabled | bool"))
    (task "Generate GitLab Omnibus configuration"
      (ansible.builtin.template 
        (src "etc/gitlab/gitlab.rb.j2")
        (dest "/etc/gitlab/gitlab.rb")
        (mode "0600"))
      (notify (list
          "Reconfigure GitLab Omnibus"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove GitLab Omnibus backup cron job if requested"
      (ansible.builtin.file 
        (path "/etc/cron.d/backup-gitlab-omnibus")
        (state "absent"))
      (when "not gitlab__backup_enabled | bool"))
    (task "Configure GitLab Omnibus backup cron job"
      (ansible.builtin.template 
        (src "etc/cron.d/backup-gitlab-omnibus.j2")
        (dest "/etc/cron.d/backup-gitlab-omnibus")
        (mode "0644"))
      (when "gitlab__backup_enabled | bool"))
    (task "Make sure that PKI hook directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ gitlab__pki_hook_path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "gitlab__pki_enabled | bool"))
    (task "Manage PKI gitlab hook"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/pki/hooks/gitlab.j2\") }}"))
        (dest (jinja "{{ gitlab__pki_hook_path + \"/gitlab\" }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "gitlab__pki_enabled | bool"))
    (task "Install GitLab APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", gitlab__base_packages + gitlab__packages) }}"))
        (state "present"))
      (environment 
        (GITLAB_ROOT_PASSWORD (jinja "{{ gitlab__initial_root_password }}")))
      (register "gitlab__register_packages")
      (until "gitlab__register_packages is succeeded"))))
