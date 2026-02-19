(playbook "debops/ansible/roles/minio/tasks/main.yml"
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
    (task "Create required UNIX system group"
      (ansible.builtin.group 
        (name (jinja "{{ minio__group }}"))
        (state "present")
        (system "True")))
    (task "Create required UNIX system account"
      (ansible.builtin.user 
        (name (jinja "{{ minio__user }}"))
        (group (jinja "{{ minio__group }}"))
        (groups (jinja "{{ minio__additional_groups }}"))
        (append "True")
        (home (jinja "{{ minio__home }}"))
        (comment (jinja "{{ minio__comment }}"))
        (shell (jinja "{{ minio__shell }}"))
        (state "present")
        (system "True")))
    (task "Create required application directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (state "directory")
        (owner (jinja "{{ minio__user }}"))
        (group (jinja "{{ minio__group }}"))
        (mode (jinja "{{ item.mode }}")))
      (loop (list
          
          (path (jinja "{{ minio__config_dir }}"))
          (mode "0750")
          
          (path (jinja "{{ minio__volumes_dir }}"))
          (mode "0750")
          
          (path (jinja "{{ minio__tls_certs_dir }}"))
          (mode "0700"))))
    (task "Create volume directories"
      (ansible.builtin.file 
        (path (jinja "{{ (\"\"
               if ((item.path | d(item)).startswith(\"/\"))
               else (minio__volumes_dir + \"/\"))
              + (item.path | d(item)) }}"))
        (state "directory")
        (owner (jinja "{{ minio__user }}"))
        (group (jinja "{{ minio__group }}"))
        (mode "0750"))
      (loop (jinja "{{ minio__volumes + minio__group_volumes + minio__host_volumes }}"))
      (when "item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Symlink TLS files to MinIO home directory"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (src (jinja "{{ item.src }}"))
        (mode (jinja "{{ item.mode }}"))
        (state "link"))
      (loop (list
          
          (path (jinja "{{ minio__tls_certs_dir + \"/private.key\" }}"))
          (src (jinja "{{ minio__tls_private_key }}"))
          (mode "0640")
          
          (path (jinja "{{ minio__tls_certs_dir + \"/public.crt\" }}"))
          (src (jinja "{{ minio__tls_public_crt }}"))
          (mode "0644")))
      (when "minio__pki_enabled | bool"))
    (task "Install systemd configuration files"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (mode "0644"))
      (loop (list
          "etc/systemd/system/minio.service"
          "etc/systemd/system/minio@.service"))
      (notify (list
          "Reload service manager")))
    (task "Reload systemd daemon if required"
      (ansible.builtin.meta "flush_handlers"))
    (task "Stop and disable MinIO instances if requested"
      (ansible.builtin.systemd 
        (name "minio@" (jinja "{{ item.name }}") ".service")
        (state "stopped")
        (enabled "False"))
      (loop (jinja "{{ minio__combined_instances | debops.debops.parse_kv_items }}"))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') in ['absent']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove MinIO instance configuration files if requested"
      (ansible.builtin.file 
        (path (jinja "{{ minio__config_dir + \"/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ minio__combined_instances | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') in ['absent']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate MinIO instance configuration files"
      (ansible.builtin.template 
        (src "etc/minio/instance.j2")
        (dest (jinja "{{ minio__config_dir + \"/\" + item.name }}"))
        (owner (jinja "{{ minio__user }}"))
        (group (jinja "{{ minio__group }}"))
        (mode "0640"))
      (loop (jinja "{{ minio__combined_instances | debops.debops.parse_kv_items }}"))
      (register "minio__register_instance_config")
      (when "item.name | d() and item.port | d() and item.state | d('present') not in ['absent', 'ignore', 'init']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Start and enable MinIO instances"
      (ansible.builtin.systemd 
        (name "minio@" (jinja "{{ item.name }}") ".service")
        (state "started")
        (enabled "True"))
      (loop (jinja "{{ minio__combined_instances | debops.debops.parse_kv_items }}"))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.port | d() and item.state | d('present') not in ['absent', 'ignore', 'init']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Start and enable MinIO service"
      (ansible.builtin.systemd 
        (name "minio.service")
        (state "started")
        (enabled "True"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Restart MinIO instances if configuration was modified"
      (ansible.builtin.systemd 
        (name "minio@" (jinja "{{ item.item.name }}") ".service")
        (state "restarted"))
      (loop (jinja "{{ minio__register_instance_config.results }}"))
      (when "item is changed"))
    (task "Install PKI hook script"
      (ansible.builtin.template 
        (src "etc/pki/hooks/minio.j2")
        (dest "/etc/pki/hooks/minio")
        (mode "0755"))
      (when "ansible_service_mgr == 'systemd' and minio__pki_enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save MinIO local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/minio.fact.j2")
        (dest "/etc/ansible/facts.d/minio.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
