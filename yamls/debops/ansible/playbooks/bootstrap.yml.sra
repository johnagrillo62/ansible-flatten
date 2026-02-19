(playbook "debops/ansible/playbooks/bootstrap.yml"
  (tasks
    (task "Bootstrap Python support on a host"
      (collections (list
          "debops.debops"
          "debops.roles01"
          "debops.roles02"
          "debops.roles03"))
      (hosts (list
          "debops_all_hosts"
          "debops_service_bootstrap"))
      (strategy "linear")
      (gather_facts "False")
      (tasks (list
          
          (name "Initialize Ansible support via raw tasks")
          (ansible.builtin.import_role 
            (name "python")
            (tasks_from "main_raw"))
          (tags (list
              "role::python_raw"
              "skip::python_raw"
              "role::python"))))
      (become "True"))
    (task "Bootstrap APT configuration on a host"
      (collections (list
          "debops.debops"
          "debops.roles01"
          "debops.roles02"
          "debops.roles03"))
      (hosts (list
          "debops_all_hosts"
          "debops_service_bootstrap"))
      (roles (list
          
          (role "apt_proxy")
          (tags (list
              "role::apt_proxy"
              "skip::apt_proxy"))
          
          (role "apt")
          (tags (list
              "role::apt"
              "skip::apt"))))
      (become "True")
      (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}")))
    (task "Apply core configuration"
      (import_playbook "service/core.yml"))
    (task "Bootstrap host for Ansible management"
      (collections (list
          "debops.debops"
          "debops.roles01"
          "debops.roles02"
          "debops.roles03"))
      (hosts (list
          "debops_all_hosts"
          "debops_service_bootstrap"))
      (roles (list
          
          (role "resolved")
          (tags (list
              "role::resolved"
              "skip::resolved"))
          
          (role "python")
          (tags (list
              "role::python"
              "skip::python"
              "role::netbase"))
          (python__dependent_packages3 (list
              (jinja "{{ netbase__python__dependent_packages3 }}")))
          (python__dependent_packages2 (list
              (jinja "{{ netbase__python__dependent_packages2 }}")))
          
          (role "netbase")
          (tags (list
              "role::netbase"
              "skip::netbase"))
          
          (role "fhs")
          (tags (list
              "role::fhs"
              "skip::fhs"))
          
          (role "sudo")
          (tags (list
              "role::sudo"
              "skip::sudo"
              "role::system_groups"))
          
          (role "libuser")
          (tags (list
              "role::libuser"
              "skip::libuser"))
          
          (role "system_groups")
          (tags (list
              "role::system_groups"
              "skip::system_groups"))
          
          (role "system_users")
          (tags (list
              "role::system_users"
              "skip::system_users"))))
      (become "True")
      (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}")))))
