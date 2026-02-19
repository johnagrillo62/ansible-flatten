(playbook "debops/ansible/playbooks/service/ifupdown.yml"
    (play
    (name "Manage network configuration using ifupdown")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_ifupdown"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare ifupdown environment"
        (ansible.builtin.import_role 
          (name "ifupdown")
          (tasks_from "main_env"))
        (tags (list
            "role::ifupdown"
            "role::kmod"
            "role::ferm"
            "role::sysctl"))))
    (roles
      
        (role "resolvconf")
        (tags (list
            "role::resolvconf"
            "skip::resolvconf"))
        (resolvconf__enabled "True")
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::kmod"))
        (python__dependent_packages3 (list
            (jinja "{{ kmod__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ kmod__python__dependent_packages2 }}")))
      
        (role "kmod")
        (tags (list
            "role::kmod"
            "skip::kmod"))
        (kmod__dependent_load (list
            (jinja "{{ ifupdown__env_kmod__dependent_load }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ ifupdown__env_ferm__dependent_rules }}")))
      
        (role "sysctl")
        (tags (list
            "role::sysctl"
            "skip::sysctl"))
        (sysctl__dependent_parameters (list
            (jinja "{{ ifupdown__env_sysctl__dependent_parameters }}")))
      
        (role "ifupdown")
        (tags (list
            "role::ifupdown"
            "skip::ifupdown")))))
