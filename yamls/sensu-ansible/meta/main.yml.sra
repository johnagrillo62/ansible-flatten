(playbook "sensu-ansible/meta/main.yml"
  (galaxy_info 
    (author "Calum MacRae")
    (description "Deploy a full Sensu monitoring stack; including redis, RabbitMQ & the Uchiwa dashboard")
    (license "MIT")
    (min_ansible_version "2.5")
    (platforms (list
        
        (name "EL")
        (versions (list
            "6"
            "7"))
        
        (name "Ubuntu")
        (versions (list
            "trusty"
            "vivid"
            "bionic"))
        
        (name "Debian")
        (versions (list
            "jessie"
            "stretch"))
        
        (name "Fedora")
        (versions (list
            "28"
            "29"
            "30"))))
    (galaxy_tags (list
        "cloud"
        "monitoring"
        "system"
        "web"
        "sensu"
        "rabbitmq"
        "redis"
        "metrics"
        "amqp"
        "alerting"
        "stack"
        "dashboard")))
  (dependencies (list)))
