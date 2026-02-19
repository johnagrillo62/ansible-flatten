(playbook "debops/ansible/roles/x2go_server/tasks/main.yml"
  (tasks
    (task "Ensure specified packages are in there desired state"
      (ansible.builtin.apt 
        (name (jinja "{{ q(\"flattened\", x2go_server__base_packages) }}"))
        (state (jinja "{{ \"latest\" if (x2go_server__deploy_state == \"present\") else \"absent\" }}"))
        (install_recommends "False")
        (purge "True"))
      (register "x2go_server__register_packages")
      (until "x2go_server__register_packages is succeeded")
      (when "(not ansible_check_mode)"))))
