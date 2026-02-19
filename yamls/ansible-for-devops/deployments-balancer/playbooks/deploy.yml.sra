(playbook "ansible-for-devops/deployments-balancer/playbooks/deploy.yml"
    (play
    (hosts "app")
    (become "yes")
    (serial "1")
    (pre_tasks
      (task "Disable the backend server in HAProxy."
        (haproxy 
          (state "disabled")
          (host (jinja "{{ inventory_hostname }}"))
          (socket "/var/lib/haproxy/stats")
          (backend "habackend"))
        (delegate_to (jinja "{{ item }}"))
        (with_items (jinja "{{ groups.balancer }}"))))
    (tasks
      (task "Wait a short time to simulate a deployment."
        (pause 
          (seconds "10"))))
    (post_tasks
      (task "Wait for backend to come back up."
        (wait_for 
          (host (jinja "{{ inventory_hostname }}"))
          (port "80")
          (state "started")
          (timeout "60")))
      (task "Enable the backend server in HAProxy."
        (haproxy 
          (state "enabled")
          (host (jinja "{{ inventory_hostname }}"))
          (socket "/var/lib/haproxy/stats")
          (backend "habackend"))
        (delegate_to (jinja "{{ item }}"))
        (with_items (jinja "{{ groups.balancer }}"))))))
