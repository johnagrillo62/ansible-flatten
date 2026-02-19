(playbook "debops/ansible/roles/global_handlers/handlers/mosquitto.yml"
  (tasks
    (task "Restart mosquitto"
      (ansible.builtin.service 
        (name "mosquitto")
        (state "restarted")))
    (task "Reload mosquitto"
      (ansible.builtin.service 
        (name "mosquitto")
        (state "reloaded")))))
