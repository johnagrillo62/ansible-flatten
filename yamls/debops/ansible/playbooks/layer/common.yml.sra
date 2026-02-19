(playbook "debops/ansible/playbooks/layer/common.yml"
  (tasks
    (task "Security assertions"
      (collections (list
          "debops.debops"
          "debops.roles01"
          "debops.roles02"
          "debops.roles03"))
      (hosts (list
          "all"))
      (gather_facts "False")
      (tasks (list
          
          (name "Check for Ansible version without known vulnerabilities")
          (ansible.builtin.assert 
            (that (list
                "ansible_version.full is version_compare(\"2.1.5.0\", \">=\")"
                "((ansible_version.minor == 2) and (ansible_version.full is version_compare(\"2.2.2.0\", \">=\"))) or (ansible_version.minor != 2)"))
            (msg "VULNERABLE or unsupported Ansible version DETECTED, please update to
Ansible >= v2.1.5 or a newer Ansible release >= v2.2.2! To skip, add
\"--skip-tags play::security-assertions\" parameter. Check the
debops-playbook changelog for details. Exiting.
"))
          (run_once "True")
          (delegate_to "localhost")))
      (tags (list
          "play::security-assertions"))
      (become "False"))
    (task "Prepare APT configuration on a host"
      (collections (list
          "debops.debops"
          "debops.roles01"
          "debops.roles02"
          "debops.roles03"))
      (hosts (list
          "debops_all_hosts"
          "!debops_no_common"))
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
      (import_playbook "../service/core.yml"))
    (task "Common configuration for all hosts"
      (collections (list
          "debops.debops"
          "debops.roles01"
          "debops.roles02"
          "debops.roles03"))
      (hosts (list
          "debops_all_hosts"
          "!debops_no_common"))
      (gather_facts "True")
      (pre_tasks (list
          
          (name "Prepare nullmailer environment")
          (ansible.builtin.import_role 
            (name "nullmailer")
            (tasks_from "main_env"))
          (tags (list
              "role::nullmailer"
              "role::ferm"
              "role::tcpwrappers"))
          
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
          
          (role "debops_fact")
          (tags (list
              "role::debops_fact"
              "skip::debops_fact"))
          
          (role "environment")
          (tags (list
              "role::environment"
              "skip::environment"))
          
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
              (jinja "{{ apt_install__apt_preferences__dependent_list }}")
              (jinja "{{ yadm__apt_preferences__dependent_list }}")))
          
          (role "tzdata")
          (tags (list
              "role::tzdata"
              "skip::tzdata"))
          
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
          
          (role "lldpd")
          (tags (list
              "role::lldpd"
              "skip::lldpd"))
          
          (role "ldap")
          (tags (list
              "role::ldap"
              "skip::ldap"))
          
          (role "ldap")
          (tags (list
              "role::ldap"
              "skip::ldap"))
          (ldap__dependent_tasks (list
              (jinja "{{ nullmailer__ldap__dependent_tasks }}")
              (jinja "{{ sudo__ldap__dependent_tasks }}")
              (jinja "{{ sshd__ldap__dependent_tasks }}")))
          
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
              "skip::sudo"))
          (sudo__dependent_sudoers (list
              (jinja "{{ sshd__sudo__dependent_sudoers }}")))
          
          (role "nsswitch")
          (tags (list
              "role::nsswitch"
              "skip::nsswitch"))
          
          (role "root_account")
          (tags (list
              "role::root_account"
              "skip::root_account"))
          
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
          
          (role "apt_listchanges")
          (tags (list
              "role::apt_listchanges"
              "skip::apt_listchanges"))
          
          (role "apt_install")
          (tags (list
              "role::apt_install"
              "skip::apt_install"))
          
          (role "etc_services")
          (tags (list
              "role::etc_services"
              "skip::etc_services"))
          (etc_services__dependent_list (list
              (jinja "{{ resolved__etc_services__dependent_list }}")))
          
          (role "logrotate")
          (tags (list
              "role::logrotate"
              "skip::logrotate"))
          (logrotate__dependent_config (list
              (jinja "{{ rsyslog__logrotate__dependent_config }}")))
          
          (role "auth")
          (tags (list
              "role::auth"
              "skip::auth"))
          
          (role "users")
          (tags (list
              "role::users"
              "skip::users"))
          
          (role "mount")
          (tags (list
              "role::mount"
              "skip::mount"))
          
          (role "resources")
          (tags (list
              "role::resources"
              "skip::resources"))
          
          (role "ferm")
          (tags (list
              "role::ferm"
              "skip::ferm"))
          (ferm__dependent_rules (list
              (jinja "{{ nullmailer__ferm__dependent_rules }}")
              (jinja "{{ rsyslog__ferm__dependent_rules }}")
              (jinja "{{ sshd__ferm__dependent_rules }}")))
          
          (role "tcpwrappers")
          (tags (list
              "role::tcpwrappers"
              "skip::tcpwrappers"))
          (tcpwrappers_dependent_allow (list
              (jinja "{{ nullmailer__tcpwrappers__dependent_allow }}")
              (jinja "{{ sshd__tcpwrappers__dependent_allow }}")))
          
          (role "locales")
          (tags (list
              "role::locales"
              "skip::locales"))
          
          (role "proc_hidepid")
          (tags (list
              "role::proc_hidepid"
              "skip::proc_hidepid"))
          
          (role "console")
          (tags (list
              "role::console"
              "skip::console"))
          
          (role "sysctl")
          (tags (list
              "role::sysctl"
              "skip::sysctl"))
          
          (role "nullmailer")
          (tags (list
              "role::nullmailer"
              "skip::nullmailer"))
          
          (role "systemd")
          (tags (list
              "role::systemd"
              "skip::systemd"))
          
          (role "timesyncd")
          (tags (list
              "role::timesyncd"
              "skip::timesyncd"))
          
          (role "journald")
          (tags (list
              "role::journald"
              "skip::journald"))
          
          (role "rsyslog")
          (tags (list
              "role::rsyslog"
              "skip::rsyslog"))
          
          (role "unattended_upgrades")
          (tags (list
              "role::unattended_upgrades"
              "skip::unattended_upgrades"))
          
          (role "authorized_keys")
          (tags (list
              "role::authorized_keys"
              "skip::authorized_keys"))
          
          (role "sshd")
          (tags (list
              "role::sshd"
              "skip::sshd"))
          
          (role "apt_mark")
          (tags (list
              "role::apt_mark"
              "skip::apt_mark"))))
      (become "True")
      (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}")))))
