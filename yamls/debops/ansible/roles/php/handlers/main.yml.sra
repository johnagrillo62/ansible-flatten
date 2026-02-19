(playbook "debops/ansible/roles/php/handlers/main.yml"
  (tasks
    (task "Restart php-fpm"
      (ansible.builtin.service 
        (name "php" (jinja "{{ php__version }}") "-fpm")
        (state "restarted"))
      (when "\"fpm\" in php__server_api_packages"))
    (task "Reload php-fpm"
      (ansible.builtin.service 
        (name "php" (jinja "{{ php__version }}") "-fpm")
        (state "reloaded"))
      (when "\"fpm\" in php__server_api_packages"))))
