(playbook "debops/ansible/playbooks/tools/debug.yml"
    (play
    (name "Debug host variables")
    (hosts "all")
    (tasks
      (task "Display all variables/facts known for a host"
        (ansible.builtin.debug 
          (var "hostvars[inventory_hostname]"))))))
