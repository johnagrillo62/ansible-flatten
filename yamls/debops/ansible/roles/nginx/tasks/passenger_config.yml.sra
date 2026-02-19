(playbook "debops/ansible/roles/nginx/tasks/passenger_config.yml"
  (tasks
    (task "Detect passenger root"
      (ansible.builtin.command "passenger-config about root")
      (register "nginx_register_passenger_root")
      (changed_when "False"))
    (task "Set passenger_root value"
      (ansible.builtin.set_fact 
        (nginx_passenger_root (jinja "{{ nginx_register_passenger_root.stdout }}")))
      (when "nginx_passenger_root is undefined or not nginx_passenger_root"))
    (task "Detect passenger ruby"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && passenger-config about ruby-command | grep Command | tail -1 | awk -F: '{print $2}'")
      (args 
        (executable "bash"))
      (register "nginx_register_passenger_ruby")
      (changed_when "False"))
    (task "Set passenger_ruby value"
      (ansible.builtin.set_fact 
        (nginx_passenger_ruby (jinja "{{ nginx_register_passenger_ruby.stdout | trim }}")))
      (when "nginx_passenger_ruby is undefined or not nginx_passenger_ruby"))))
