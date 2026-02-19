(playbook "debops/ansible/playbooks/bootstrap-sss.yml"
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
    (task "Bootstrap host for Ansible management with LDAP"
      (collections (list
          "debops.debops"
          "debops.roles01"
          "debops.roles02"
          "debops.roles03"))
      (hosts (list
          "debops_all_hosts"
          "debops_service_bootstrap"))
      (pre_tasks (list
          
          (name "Prepare pki environment")
          (ansible.builtin.import_role 
            (name "pki")
            (tasks_from "main_env"))
          (tags (list
              "role::pki"
              "role::pki:secret"
              "role::secret"))
          
          (name "Prepare sshd environment")
          (ansible.builtin.import_role 
            (name "sshd")
            (tasks_from "main_env"))
          (tags (list
              "role::sshd"
              "role::ldap"))))
      (roles (list
          
          (role "resolved")
          (tags (list
              "role::resolved"
              "skip::resolved"))
          
          (role "python")
          (tags (list
              "role::python"
              "skip::python"
              "role::netbase"
              "role::ldap"))
          (python__dependent_packages3 (list
              (jinja "{{ netbase__python__dependent_packages3 }}")
              (jinja "{{ ldap__python__dependent_packages3 }}")))
          (python__dependent_packages2 (list
              (jinja "{{ netbase__python__dependent_packages2 }}")
              (jinja "{{ ldap__python__dependent_packages2 }}")))
          
          (role "netbase")
          (tags (list
              "role::netbase"
              "skip::netbase"))
          
          (role "secret")
          (tags (list
              "role::secret"
              "role::pki"
              "role::pki:secret"))
          (secret_directories (list
              (jinja "{{ pki_env_secret_directories }}")))
          
          (role "fhs")
          (tags (list
              "role::fhs"
              "skip::fhs"))
          
          (role "apt_preferences")
          (tags (list
              "role::apt_preferences"
              "skip::apt_preferences"))
          (apt_preferences__dependent_list (list
              (jinja "{{ etckeeper__apt_preferences__dependent_list }}")
              (jinja "{{ yadm__apt_preferences__dependent_list }}")))
          
          (role "etckeeper")
          (tags (list
              "role::etckeeper"
              "skip::etckeeper"))
          
          (role "cron")
          (tags (list
              "role::cron"
              "skip::cron"))
          
          (role "atd")
          (tags (list
              "role::atd"
              "skip::atd"))
          
          (role "dhparam")
          (tags (list
              "role::dhparam"
              "skip::dhparam"))
          
          (role "pki")
          (tags (list
              "role::pki"
              "skip::pki"))
          
          (role "machine")
          (tags (list
              "role::machine"
              "skip::machine"))
          
          (role "ldap")
          (tags (list
              "role::ldap"
              "skip::ldap"))
          
          (role "ldap")
          (tags (list
              "role::ldap"
              "skip::ldap"))
          (ldap__dependent_tasks (list
              (jinja "{{ sudo__ldap__dependent_tasks }}")
              (jinja "{{ sshd__ldap__dependent_tasks }}")
              (jinja "{{ sssd__ldap__dependent_tasks }}")))
          
          (role "sssd")
          (tags (list
              "role::sssd"
              "skip::sssd"))
          (when "ansible_local.ldap.posix_enabled | d() | bool")
          
          (role "keyring")
          (tags (list
              "role::keyring"
              "skip::keyring"
              "role::yadm"))
          (keyring__dependent_gpg_keys (list
              (jinja "{{ yadm__keyring__dependent_gpg_keys }}")))
          
          (role "yadm")
          (tags (list
              "role::yadm"
              "skip::yadm"))
          
          (role "sudo")
          (tags (list
              "role::sudo"
              "skip::sudo"
              "role::system_groups"))
          (sudo__dependent_sudoers (list
              (jinja "{{ sshd__sudo__dependent_sudoers }}")))
          
          (role "nsswitch")
          (tags (list
              "role::nsswitch"
              "skip::nsswitch"))
          (nsswitch__dependent_services (list
              (jinja "{{ sssd__nsswitch__dependent_services }}")))
          
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
              "skip::system_users"))
          
          (role "pam_access")
          (tags (list
              "role::pam_access"
              "skip::pam_access"))
          (pam_access__dependent_rules (list
              (jinja "{{ sshd__pam_access__dependent_rules }}")))
          
          (role "sshd")
          (tags (list
              "role::sshd"
              "skip::sshd"))))
      (become "True")
      (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
      (vars 
        (ldap__enabled "True")))))
