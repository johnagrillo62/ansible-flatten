(playbook "debops/ansible/roles/owncloud/tasks/main_env.yml"
  (tasks
    (task "Ensure the custom nginx client body temp directory does exist"
      (ansible.builtin.file 
        (path (jinja "{{ owncloud__nginx_client_body_temp_path }}"))
        (state "directory")
        (owner (jinja "{{ ansible_local.nginx.user | d(\"www-data\") }}"))
        (group "root")
        (mode "0700"))
      (when "(owncloud__webserver in [\"nginx\"] and owncloud__nginx_client_body_temp_path | d())"))
    (task "Ensure the custom temp directories are setup"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (state "directory")
        (owner (jinja "{{ owncloud__app_user }}"))
        (group (jinja "{{ owncloud__app_group }}"))
        (mode (jinja "{{ item.mode | d(\"1750\") }}")))
      (when "item.path | d()")
      (with_items (list
          
          (path (jinja "{{ owncloud__temp_path }}"))
          
          (path (jinja "{{ owncloud__php_temp_path }}")))))
    (task "Make sure that Ansible local facts directory is present"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save ownCloud local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/owncloud.fact.j2")
        (dest "/etc/ansible/facts.d/owncloud.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Gather facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
