(playbook "sensu-ansible/vars/FreeBSD.yml"
  (sensu_config_path "/usr/local/etc/sensu")
  (sensu_rabbitmq_config_path "/usr/local/etc/rabbitmq")
  (sensu_rabbitmq_service_name "rabbitmq")
  (__bash_path "/usr/local/bin/bash")
  (__root_group "wheel"))
