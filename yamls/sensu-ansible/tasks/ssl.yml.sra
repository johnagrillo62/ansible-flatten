(playbook "sensu-ansible/tasks/ssl.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml")))
    (task "Ensure Sensu SSL directory exists"
      (file 
        (dest (jinja "{{ sensu_config_path }}") "/ssl")
        (state "directory")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (when "sensu_ssl_manage_certs"))
    (task
      (include_tasks (jinja "{{ role_path }}") "/tasks/ssl_generate.yml")
      (when "sensu_ssl_gen_certs"))
    (task "Deploy the Sensu client SSL cert/key"
      (copy 
        (src (jinja "{{ item.src }}"))
        (owner (jinja "{{ sensu_user_name }}"))
        (remote_src (jinja "{{ sensu_ssl_deploy_remote_src }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (dest (jinja "{{ sensu_config_path }}") "/ssl/" (jinja "{{ item.dest }}"))
        (mode " " (jinja "{{ item.perm }}")))
      (loop (list
          
          (src (jinja "{{ sensu_ssl_client_cert }}"))
          (dest "cert.pem")
          (perm "0640")
          
          (src (jinja "{{ sensu_ssl_client_key }}"))
          (dest "key.pem")
          (perm "0640")))
      (notify "restart sensu-client service")
      (when "sensu_ssl_manage_certs"))))
