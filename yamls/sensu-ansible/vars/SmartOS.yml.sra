(playbook "sensu-ansible/vars/SmartOS.yml"
  (sensu_rabbitmq_service_name "rabbitmq")
  (sensu_rabbitmq_config_path "/opt/local/etc/rabbitmq")
  (sensu_config_path "/opt/local/etc/sensu"))
