(playbook "sensu-ansible/handlers/main.yml"
  (tasks
    (task "restart rabbitmq service"
      (service 
        (name (jinja "{{ sensu_rabbitmq_service_name }}"))
        (state "restarted")))
    (task "restart redis service"
      (service 
        (name (jinja "{{ sensu_redis_service_name }}"))
        (pattern "/usr/bin/redis-server")
        (state "restarted")))
    (task "restart uchiwa service"
      (service 
        (name (jinja "{{ uchiwa_service_name }}"))
        (state "restarted")))
    (task "restart sensu-server service"
      (service 
        (name (jinja "{{ sensu_server_service_name }}"))
        (state "restarted"))
      (when "sensu_master and not se_enterprise"))
    (task "restart sensu-api service"
      (service 
        (name (jinja "{{ sensu_api_service_name }}"))
        (state "restarted"))
      (when "sensu_master and not se_enterprise"))
    (task "restart sensu-client service"
      (service 
        (name (jinja "{{ sensu_client_service_name }}"))
        (state "restarted")))
    (task "restart sensu-enterprise service"
      (service 
        (name (jinja "{{ sensu_enterprise_service_name }}"))
        (state "restarted"))
      (when "se_enterprise and sensu_master"))
    (task "restart sensu-enterprise-dashboard service"
      (service 
        (name (jinja "{{ sensu_enterprise_dashboard_service_name }}"))
        (state "restarted"))
      (when "se_enterprise and sensu_master"))
    (task "import sensu-server service"
      (command "/usr/sbin/svccfg import /opt/local/lib/svc/manifest/sensu-server.xml"))
    (task "import sensu-api service"
      (command "/usr/sbin/svccfg import /opt/local/lib/svc/manifest/sensu-api.xml"))
    (task "import sensu-client service"
      (command "/usr/sbin/svccfg import /opt/local/lib/svc/manifest/sensu-client.xml"))
    (task "import uchiwa service"
      (command "/usr/sbin/svccfg import /opt/local/lib/svc/manifest/uchiwa.xml"))
    (task "Build and deploy Uchiwa"
      (command "npm install --production")
      (args 
        (chdir (jinja "{{ sensu_uchiwa_path }}") "/go/src/github.com/sensu/uchiwa"))
      (become "true")
      (become_user (jinja "{{ sensu_user_name }}")))
    (task "Update pkgng database"
      (command "/usr/sbin/pkg update"))))
