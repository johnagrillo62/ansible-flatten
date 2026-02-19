(playbook "debops/ansible/roles/sshd/tasks/main_env.yml"
  (tasks
    (task "Gather SSH host public keys"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && cat /etc/ssh/ssh_host_*_key.pub || true")
      (args 
        (executable "/bin/bash"))
      (register "sshd__env_register_host_public_keys")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "meta::facts")))))
