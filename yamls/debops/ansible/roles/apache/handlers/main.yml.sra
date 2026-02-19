(playbook "debops/ansible/roles/apache/handlers/main.yml"
  (tasks
    (task "Test apache and reload"
      (ansible.builtin.command "apache2ctl configtest")
      (register "apache__register_reload")
      (changed_when "apache__register_reload.changed | bool")
      (notify (list
          "Reload apache")))
    (task "Reload apache"
      (ansible.builtin.service 
        (name (jinja "{{ apache__service_name }}"))
        (state "reloaded")))))
