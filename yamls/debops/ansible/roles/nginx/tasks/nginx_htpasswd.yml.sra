(playbook "debops/ansible/roles/nginx/tasks/nginx_htpasswd.yml"
  (tasks
    (task "Create directory for htpasswd files"
      (ansible.builtin.file 
        (path (jinja "{{ nginx_private_path }}"))
        (state "directory")
        (owner "root")
        (group (jinja "{{ nginx_user }}"))
        (mode "0750")))
    (task "Remove htpasswd files if requested"
      (ansible.builtin.file 
        (dest (jinja "{{ nginx_private_path + \"/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", nginx__htpasswd
                           + nginx__default_htpasswd
                           + nginx__dependent_htpasswd
                           + nginx_htpasswd | d([])) }}"))
      (when "(item.name | d() and (item.state | d() and item.state == 'absent'))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Manage users in htpasswd files"
      (community.general.htpasswd 
        (path (jinja "{{ nginx_private_path + \"/\" + item.0.name }}"))
        (name (jinja "{{ item.1 }}"))
        (crypt_scheme (jinja "{{ nginx__htpasswd_crypt_scheme }}"))
        (password (jinja "{{ item.0.password
                  if item.0.password | d()
                  else lookup(\"password\", nginx_htpasswd_secret_path + \"/\" + item.0.name + \"/\" + item.1
                  + \" length=\" + nginx__htpasswd_password_length | string
                  + \" chars=\" + nginx__htpasswd_password_characters) }}"))
        (state (jinja "{{ \"present\" if not (item.0.delete | d(False) | bool) else \"absent\" }}"))
        (owner "root")
        (group (jinja "{{ nginx_user }}"))
        (mode "0640"))
      (with_subelements (list
          (jinja "{{ nginx__htpasswd + nginx__default_htpasswd + nginx__dependent_htpasswd + nginx_htpasswd | d([]) }}")
          "users"))
      (when "(item.0.name | d() and item.0.state | d('present') != 'absent' and item.1 | d())")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
