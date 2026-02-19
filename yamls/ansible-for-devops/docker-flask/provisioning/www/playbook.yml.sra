(playbook "ansible-for-devops/docker-flask/provisioning/www/playbook.yml"
    (play
    (hosts "localhost")
    (become "true")
    (tasks
      (task "Get host IP address."
        (shell "/sbin/ip route | awk '/default/ { print $3 }'")
        (register "host_ip")
        (changed_when "false"))
      (task "Set host_ip_address variable."
        (set_fact 
          (host_ip_address (jinja "{{ host_ip.stdout }}"))))
      (task "Copy Flask app into place."
        (template 
          (src "/etc/ansible/index.py.j2")
          (dest "/opt/www/index.py")
          (mode "0755")))
      (task "Copy Flask templates into place."
        (copy 
          (src "/etc/ansible/templates")
          (dest "/opt/www")
          (mode "0755"))))))
