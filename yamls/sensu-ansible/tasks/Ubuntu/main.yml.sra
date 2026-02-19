(playbook "sensu-ansible/tasks/Ubuntu/main.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "setup"))
    (task "Ensure that https transport is ready"
      (apt 
        (name "apt-transport-https")
        (state "present")
        (cache_valid_time "3600")
        (update_cache "true"))
      (tags "setup"))
    (task "Ensure the Sensu APT repo GPG key is present"
      (apt_key 
        (url (jinja "{{ sensu_apt_key_url }}"))
        (state "present"))
      (tags "setup"))
    (task "Ensure the Sensu Core APT repo is present"
      (apt_repository 
        (repo (jinja "{{ sensu_apt_repo_url }}"))
        (state "present")
        (update_cache "true"))
      (tags "setup"))
    (task "Ensure Sensu is installed"
      (apt 
        (name (jinja "{{ sensu_package }}"))
        (state (jinja "{{ sensu_pkg_state }}")))
      (tags "setup"))))
