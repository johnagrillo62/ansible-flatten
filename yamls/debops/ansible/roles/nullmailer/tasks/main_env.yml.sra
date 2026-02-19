(playbook "debops/ansible/roles/nullmailer/tasks/main_env.yml"
  (tasks
    (task "Check if MTA is installed"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && dpkg --get-selections | grep -w -E '(" (jinja "{{ nullmailer__skip_mta_packages | join(\"|\") }}") ")' | awk '{print $1}' || true")
      (environment 
        (LC_MESSAGES "C"))
      (args 
        (executable "/bin/bash"))
      (register "nullmailer__register_mta")
      (changed_when "False")
      (failed_when "False")
      (check_mode "False"))
    (task "Set nullmailer deployment state"
      (ansible.builtin.set_fact 
        (nullmailer__deploy_state (jinja "{{ \"present\"
                                  if (nullmailer__enabled | bool and
                                      (not nullmailer__skip_mta | bool or not nullmailer__register_mta.stdout | d()))
                                  else \"absent\" }}"))))))
