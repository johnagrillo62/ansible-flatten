(playbook "debops/ansible/roles/auth/handlers/main.yml"
  (tasks
    (task "Update PAM common configuration"
      (ansible.builtin.shell "pam-auth-update --package libpam-modules 2>/dev/null")
      (register "auth__register_pam_update")
      (changed_when "auth__register_pam_update.changed | bool")
      (when "ansible_distribution_release not in [\"bionic\", \"buster\"]"))))
