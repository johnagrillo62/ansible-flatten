(playbook "debops/ansible/roles/icinga/handlers/main.yml"
  (tasks
    (task "Check icinga2 configuration and restart it on the master node"
      (ansible.builtin.command "icinga2 daemon -C")
      (register "icinga__register_check_config")
      (changed_when "icinga__register_check_config.changed | bool")
      (notify (list
          "Restart icinga2 on the master node"))
      (delegate_to (jinja "{{ icinga__master_delegate_to }}")))
    (task "Restart icinga2 on the master node"
      (ansible.builtin.service 
        (name "icinga2")
        (state "restarted"))
      (delegate_to (jinja "{{ icinga__master_delegate_to }}")))
    (task "Trigger Icinga Director configuration deployment"
      (ansible.builtin.uri 
        (body_format "json")
        (headers 
          (Accept "application/json"))
        (method "POST")
        (url (jinja "{{ icinga__director_deploy_api_url }}"))
        (user (jinja "{{ icinga__director_deploy_api_user }}"))
        (password (jinja "{{ icinga__director_deploy_api_password }}")))
      (run_once "True")
      (when "icinga__director_deploy | bool")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
