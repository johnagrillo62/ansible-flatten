(playbook "debops/ansible/roles/elasticsearch/tasks/authentication.yml"
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
    (task "Initialize built-in users in Elasticsearch"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && bin/elasticsearch-setup-passwords auto --batch | awk '$1 ~ /^PASSWORD/ {print $2, $4}'")
      (args 
        (executable "bash")
        (chdir "/usr/share/elasticsearch"))
      (register "elasticsearch__register_builtin_users")
      (changed_when "False")
      (when "((not (ansible_local.elasticsearch.configured | d()) | bool) or elasticsearch__register_api_builtin_users.status == 401)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Create required directories on Ansible Controller"
      (ansible.builtin.file 
        (path (jinja "{{ secret + \"/\" + elasticsearch__secret_path + \"/\" + item.split()[0] }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ elasticsearch__register_builtin_users.stdout_lines }}"))
      (become "False")
      (delegate_to "localhost")
      (when "elasticsearch__register_builtin_users.stdout_lines | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Save generated user passwords on Ansible Controller"
      (ansible.builtin.copy 
        (content (jinja "{{ item.split()[1] }}"))
        (dest (jinja "{{ secret + \"/\" + elasticsearch__secret_path + \"/\" + item.split()[0] + \"/password\" }}"))
        (mode "0644"))
      (loop (jinja "{{ elasticsearch__register_builtin_users.stdout_lines }}"))
      (become "False")
      (delegate_to "localhost")
      (when "elasticsearch__register_builtin_users.stdout_lines | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
