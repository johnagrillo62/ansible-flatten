(playbook "ansible-for-devops/elk/provisioning/web/vars/main.yml"
  (nginx_user "www-data")
  (nginx_remove_default_vhost "true")
  (filebeat_output_logstash_enabled "true")
  (filebeat_output_logstash_hosts (list
      "logs.test:5044"))
  (filebeat_ssl_key_file "elk-example.p8")
  (filebeat_ssl_certificate_file "elk-example.crt")
  (filebeat_ssl_insecure "true")
  (filebeat_inputs (list
      
      (type "log")
      (paths (list
          "/var/log/auth.log"))
      
      (type "log")
      (paths (list
          "/var/log/nginx/access.log")))))
