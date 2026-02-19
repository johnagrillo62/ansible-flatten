(playbook "debops/ansible/roles/elasticsearch/tasks/authentication_v8.yml"
  (tasks
    (task "Check status of built-in users via Elasticsearch API"
      (ansible.builtin.uri 
        (url (jinja "{{ elasticsearch__api_base_url + \"/_security/user/elastic\" }}"))
        (user (jinja "{{ elasticsearch__api_username }}"))
        (password (jinja "{{ elasticsearch__api_password }}"))
        (force_basic_auth "True")
        (method "GET")
        (status_code (list
            "200"
            "401")))
      (register "elasticsearch__register_api_builtin_users")
      (until "elasticsearch__register_api_builtin_users.status in [200, 401]")
      (retries "10")
      (delay "5")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Set passwords for built-in Elasticsearch user accounts"
      (ansible.builtin.include_tasks "reset_password.yml")
      (loop (list
          "elastic"
          "kibana_system"
          "logstash_system"
          "beats_system"
          "apm_system"
          "remote_monitoring_user"))
      (when "((not (ansible_local.elasticsearch.configured | d()) | bool) or elasticsearch__register_api_builtin_users.status == 401)"))))
