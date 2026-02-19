(playbook "sensu-ansible/tasks/Ubuntu/rabbit.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "rabbitmq"))
    (task "Ensure the RabbitMQ APT repo GPG key is present"
      (apt_key 
        (url (jinja "{{ sensu_rabbitmq_signing_key }}"))
        (state "present"))
      (tags "rabbitmq"))
    (task "Ensure the RabbitMQ APT repo is present"
      (apt_repository 
        (repo (jinja "{{ sensu_rabbitmq_repo }}"))
        (filename "rabbitmq")
        (state "present")
        (update_cache "true"))
      (tags "rabbitmq"))
    (task "Ensure Erlang APT preferences is configured"
      (template 
        (src "erlang-apt-preferences.j2")
        (dest "/etc/apt/preferences.d/erlang")
        (owner "root")
        (group "root")
        (mode "0755"))
      (tags "rabbitmq"))
    (task "Ensure the Erlang APT repo GPG key is present"
      (apt_key 
        (url (jinja "{{ sensu_rabbitmq_erlang_signing_key }}"))
        (state "present"))
      (tags "rabbitmq"))
    (task "Ensure the Erlang APT repo is present"
      (apt_repository 
        (repo (jinja "{{ sensu_rabbitmq_erlang_repo }}"))
        (filename "erlang")
        (state "present")
        (update_cache "true"))
      (tags "rabbitmq"))
    (task "Ensure RabbitMQ is installed"
      (apt 
        (name "rabbitmq-server")
        (state (jinja "{{ sensu_rabbitmq_pkg_state }}"))
        (cache_valid_time "600")
        (update_cache "true"))
      (tags "rabbitmq"))))
