(playbook "sensu-ansible/vars/OpenBSD.yml"
  (sensu_config_path "/etc/sensu")
  (sensu_gem_version "0.29.0")
  (sensu_client_service_name "sensuclient")
  (sensu_rabbitmq_config_path "/etc/rabbitmq")
  (sensu_rabbitmq_service_name "rabbitmq")
  (__bash_path "/usr/local/bin/bash")
  (__root_group "wheel"))
