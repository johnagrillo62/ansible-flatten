(playbook "openshift-ansible/playbooks/upgrade.yml"
    (play
    (name "Pre-upgrade hostfile checks")
    (hosts "localhost")
    (connection "local")
    (gather_facts "no")
    (tasks
      (task "Ensure [workers] group is populated"
        (fail 
          (msg "Detected no workers in inventory. Please add hosts to the workers host group to upgrade nodes
"))
        (when "groups.workers | default([]) | length == 0"))))
    (play
    (name "Pre-upgrade checks")
    (hosts "workers")
    (tasks
      (task
        (import_role 
          (name "openshift_node")
          (tasks_from "version_checks.yml")))))
    (play
    (name "upgrade nodes")
    (hosts "workers")
    (serial "1")
    (tasks
      (task
        (import_role 
          (name "openshift_node")
          (tasks_from "upgrade.yml"))))))
