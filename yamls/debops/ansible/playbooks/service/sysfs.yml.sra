(playbook "debops/ansible/playbooks/service/sysfs.yml"
    (play
    (name "Configure sysfs options")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_sysfs"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare sysfs environment"
        (ansible.builtin.import_role 
          (name "sysfs")
          (tasks_from "main_env"))
        (tags (list
            "role::sysfs"
            "role::secret"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::sysfs"))
        (secret__directories (list
            (jinja "{{ sysfs__secret__directories | d([]) }}")))
      
        (role "sysfs")
        (tags (list
            "role::sysfs"
            "skip::sysfs")))))
