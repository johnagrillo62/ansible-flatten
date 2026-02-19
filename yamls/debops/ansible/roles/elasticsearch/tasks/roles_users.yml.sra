(playbook "debops/ansible/roles/elasticsearch/tasks/roles_users.yml"
  (tasks
    (task "Manage native roles in Elasticsearch"
      (ansible.builtin.uri 
        (url (jinja "{{ elasticsearch__api_base_url + \"/_security/role/\" + item.name }}"))
        (method (jinja "{{ \"DELETE\" if (item.state | d(\"present\") in [\"absent\"]) else \"POST\" }}"))
        (body_format (jinja "{{ omit if (item.state | d(\"present\") in [\"absent\"]) else \"json\" }}"))
        (body (jinja "{{ omit if (item.state | d(\"present\") in [\"absent\"]) else (item.data | to_json) }}"))
        (status_code (jinja "{{ [\"200\", \"404\"] if (item.state | d(\"present\") in [\"absent\"]) else \"200\" }}"))
        (user (jinja "{{ elasticsearch__api_username }}"))
        (password (jinja "{{ elasticsearch__api_password }}"))
        (force_basic_auth "True"))
      (loop (jinja "{{ elasticsearch__combined_native_roles | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "elasticsearch__api_base_url and item.state | d('present') not in ['init', 'ignore']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Manage native users in Elasticsearch"
      (ansible.builtin.uri 
        (url (jinja "{{ elasticsearch__api_base_url + \"/_security/user/\" + item.name }}"))
        (method (jinja "{{ \"DELETE\" if (item.state | d(\"present\") in [\"absent\"]) else \"POST\" }}"))
        (body_format (jinja "{{ omit if (item.state | d(\"present\") in [\"absent\"]) else \"json\" }}"))
        (body (jinja "{{ omit if (item.state | d(\"present\") in [\"absent\"]) else (item.data | to_json) }}"))
        (status_code (jinja "{{ [\"200\", \"404\"] if (item.state | d(\"present\") in [\"absent\"]) else \"200\" }}"))
        (user (jinja "{{ elasticsearch__api_username }}"))
        (password (jinja "{{ elasticsearch__api_password }}"))
        (force_basic_auth "True"))
      (loop (jinja "{{ elasticsearch__combined_native_users | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "elasticsearch__api_base_url and item.state | d('present') not in ['init', 'ignore']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
