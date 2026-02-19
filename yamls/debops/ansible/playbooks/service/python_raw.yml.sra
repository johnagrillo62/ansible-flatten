(playbook "debops/ansible/playbooks/service/python_raw.yml"
    (play
    (name "Bootstrap Python environment")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_python"))
    (strategy "linear")
    (become "True")
    (gather_facts "False")
    (tasks
      (task "Initialize Ansible support via raw tasks"
        (ansible.builtin.import_role 
          (name "python")
          (tasks_from "main_raw"))
        (tags (list
            "role::python_raw"
            "skip::python_raw"))))))
