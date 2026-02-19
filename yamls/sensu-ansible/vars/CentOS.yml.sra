(playbook "sensu-ansible/vars/CentOS.yml"
  (enable_epel_repo "true")
  (sensu_rabbitmq_repo_version "v3.7.x")
  (sensu_rabbitmq_erlang_repo_version "20")
  (sensu_rabbitmq_signing_key "https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc")
  (sensu_rabbitmq_baseurl "https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/" (jinja "{{ sensu_rabbitmq_repo_version }}") "/el/" (jinja "{{ ansible_distribution_major_version }}"))
  (sensu_rabbitmq_erlang_signing_key (jinja "{{ sensu_rabbitmq_signing_key }}"))
  (sensu_rabbitmq_erlang_baseurl "https://dl.bintray.com/rabbitmq-erlang/rpm/erlang/" (jinja "{{ sensu_rabbitmq_erlang_repo_version }}") "/el/" (jinja "{{ ansible_distribution_major_version }}")))
