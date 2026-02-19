(playbook "debops/ansible/playbooks/layer/agent.yml"
  (tasks
    (task "Configure Filebeat service"
      (import_playbook "../service/filebeat.yml"))
    (task "Configure Metricbeat service"
      (import_playbook "../service/metricbeat.yml"))
    (task "Configure GitLab Runner service"
      (import_playbook "../service/gitlab_runner.yml"))
    (task "Configure Telegraf service"
      (import_playbook "../service/telegraf.yml"))
    (task "Configure Zabbix Agent"
      (import_playbook "../service/zabbix_agent.yml"))))
