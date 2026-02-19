(playbook "openshift-ansible/playbooks/scaleup.yml"
    (play
    (name "Pre-scaleup hostfile checks")
    (hosts "localhost")
    (connection "local")
    (gather_facts "no")
    (tasks
      (task
        (import_role 
          (name "openshift_node")
          (tasks_from "scaleup_checks.yml")))))
    (play
    (name "Pre-scaleup checks")
    (hosts "new_workers")
    (tasks
      (task
        (import_role 
          (name "openshift_node")
          (tasks_from "version_checks.yml")))))
    (play
    (name "install nodes")
    (hosts "new_workers")
    (roles
      "openshift_node")))
