(playbook "debops/ansible/roles/homeassistant/handlers/main.yml"
  (tasks
    (task "Restart Home Assistant"
      (ansible.builtin.systemd 
        (name "home-assistant")
        (state "restarted"))
      (when "(ansible_distribution_release not in [\"trusty\"])"))))
