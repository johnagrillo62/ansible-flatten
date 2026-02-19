(playbook "debops/ansible/roles/elasticsearch/tasks/reset_password.yml"
  (tasks
    (task "Initialize password for user account '" (jinja "{{ item }}") "'"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
bin/elasticsearch-reset-password --username " (jinja "{{ item }}") " --batch --silent
")
      (args 
        (executable "bash")
        (chdir "/usr/share/elasticsearch"))
      (register "elasticsearch__register_builtin_password")
      (changed_when "elasticsearch__register_builtin_password.stdout != ''")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Create required directories on Ansible Controller"
      (ansible.builtin.file 
        (path (jinja "{{ secret + \"/\" + elasticsearch__secret_path + \"/\" + item }}"))
        (state "directory")
        (mode "0755"))
      (become "False")
      (delegate_to "localhost")
      (when "elasticsearch__register_builtin_password.stdout_lines | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Save generated password of account '" (jinja "{{ item }}") "'"
      (ansible.builtin.copy 
        (content (jinja "{{ elasticsearch__register_builtin_password.stdout }}"))
        (dest (jinja "{{ secret + \"/\" + elasticsearch__secret_path + \"/\" + item + \"/password\" }}"))
        (mode "0644"))
      (become "False")
      (delegate_to "localhost")
      (when "elasticsearch__register_builtin_password.stdout | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
