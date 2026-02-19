(playbook "debops/ansible/playbooks/service/sshd.yml"
    (play
    (name "Manage OpenSSH Server")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_sshd"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare sshd environment"
        (ansible.builtin.import_role 
          (name "sshd")
          (tasks_from "main_env"))
        (tags (list
            "role::sshd"
            "role::ldap"))))
    (roles
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ sshd__ferm__dependent_rules }}")))
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers"))
        (tcpwrappers_dependent_allow (list
            (jinja "{{ sshd__tcpwrappers__dependent_allow }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::ldap"))
        (python__dependent_packages3 (list
            (jinja "{{ ldap__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ ldap__python__dependent_packages2 }}")))
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap"))
        (ldap__dependent_tasks (list
            (jinja "{{ sshd__ldap__dependent_tasks }}")))
      
        (role "pam_access")
        (tags (list
            "role::pam_access"
            "skip::pam_access"))
        (pam_access__dependent_rules (list
            (jinja "{{ sshd__pam_access__dependent_rules }}")))
      
        (role "sudo")
        (tags (list
            "role::sudo"
            "skip::sudo"))
        (sudo__dependent_sudoers (list
            (jinja "{{ sshd__sudo__dependent_sudoers }}")))
      
        (role "sshd")
        (tags (list
            "role::sshd"
            "skip::sshd")))))
