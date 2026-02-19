(playbook "debops/ansible/playbooks/upgrade.yml"
    (play
    (name "Upgrade a machine using APT")
    (hosts (list
        "debops_all_hosts"))
    (become "True")
    (gather_facts "False")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (tasks
      (task "Upgrade safe packages with refreshed cache"
        (ansible.builtin.apt 
          (update_cache "True")
          (upgrade "safe"))))))
