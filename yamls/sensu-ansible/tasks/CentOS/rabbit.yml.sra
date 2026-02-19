(playbook "sensu-ansible/tasks/CentOS/rabbit.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "rabbitmq"))
    (task "Configure RabbitMQ GPG keys in the RPM keyring"
      (rpm_key 
        (key (jinja "{{ sensu_rabbitmq_signing_key }}"))
        (state "present"))
      (tags "rabbitmq")
      (register "sensu_rabbitmq_import_key"))
    (task "Add RabbitMQ's repo"
      (yum_repository 
        (name "rabbitmq")
        (description "rabbitmq")
        (baseurl (jinja "{{ sensu_rabbitmq_baseurl }}"))
        (gpgcheck "yes")
        (gpgkey (jinja "{{ sensu_rabbitmq_signing_key }}"))
        (repo_gpgcheck "no"))
      (tags "rabbitmq"))
    (task "Add RabbitMQ's Erlang repo"
      (yum_repository 
        (name "rabbitmq-erlang")
        (description "rabbitmq-erlang")
        (baseurl (jinja "{{ sensu_rabbitmq_erlang_baseurl }}"))
        (gpgcheck "yes")
        (gpgkey (jinja "{{ sensu_rabbitmq_erlang_signing_key }}"))
        (repo_gpgcheck "no"))
      (tags "rabbitmq"))
    (task "Make yum cache to import GPG keys"
      (command "yum -q makecache -y --disablerepo='*' --enablerepo='" (jinja "{{ item }}") "'")
      (tags "rabbitmq")
      (args 
        (warn "false"))
      (when "sensu_rabbitmq_import_key.changed")
      (loop (list
          "rabbitmq"
          "rabbitmq-erlang")))
    (task "Ensure socat is installed"
      (yum 
        (name "socat")
        (state "present"))
      (tags "rabbitmq"))
    (task "Ensure Erlang & RabbitMQ are installed"
      (yum 
        (name (list
            "erlang"
            "rabbitmq-server"))
        (state "present")
        (enablerepo "rabbitmq,rabbitmq-erlang")
        (disablerepo "epel"))
      (tags "rabbitmq"))))
