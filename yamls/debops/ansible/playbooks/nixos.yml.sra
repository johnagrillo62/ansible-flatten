(playbook "debops/ansible/playbooks/nixos.yml"
    (play
    (name "Manage NixOS hosts using DebOps")
    (collections (list
        "debops.debops"))
    (hosts (list
        "debops_nixos_hosts"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (tasks
      (task "Configure NixOS system"
        (ansible.builtin.import_role 
          (name "debops.debops.nixos"))
        (tags (list
            "role::nixos"
            "skip::nixos"))))))
