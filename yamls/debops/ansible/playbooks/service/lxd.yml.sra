(playbook "debops/ansible/playbooks/service/lxd.yml"
  (tasks
    (task "Manage LXD service"
      (collections (list
          "debops.debops"
          "debops.roles01"
          "debops.roles02"
          "debops.roles03"))
      (hosts (list
          "debops_service_lxd"))
      (roles (list
          
          (role "root_account")
          (tags (list
              "role::root_account"
              "skip::root_account"))
          
          (role "keyring")
          (tags (list
              "role::keyring"
              "skip::keyring"
              "role::golang"))
          (keyring__dependent_gpg_user (jinja "{{ golang__keyring__dependent_gpg_user }}"))
          (keyring__dependent_gpg_keys (list
              (jinja "{{ golang__keyring__dependent_gpg_keys }}")))
          (golang__dependent_packages (list
              (jinja "{{ lxd__golang__dependent_packages }}")))
          
          (role "apt_preferences")
          (tags (list
              "role::apt_preferences"
              "skip::apt_preferences"))
          (apt_preferences__dependent_list (list
              (jinja "{{ golang__apt_preferences__dependent_list }}")
              (jinja "{{ lxc__apt_preferences__dependent_list }}")))
          
          (role "golang")
          (tags (list
              "role::golang"
              "skip::golang"))
          (golang__dependent_packages (list
              (jinja "{{ lxd__golang__dependent_packages }}")))
          
          (role "cron")
          (tags (list
              "role::cron"
              "skip::cron"))
          
          (role "logrotate")
          (tags (list
              "role::logrotate"
              "skip::logrotate"))
          (logrotate__dependent_config (list
              (jinja "{{ lxd__logrotate__dependent_config }}")))
          
          (role "ferm")
          (tags (list
              "role::ferm"
              "skip::ferm"))
          (ferm__dependent_rules (list
              (jinja "{{ lxc__ferm__dependent_rules }}")))
          
          (role "python")
          (tags (list
              "role::python"
              "skip::python"
              "role::lxc"))
          (python__dependent_packages3 (list
              (jinja "{{ lxc__python__dependent_packages3 }}")))
          (python__dependent_packages2 (list
              (jinja "{{ lxc__python__dependent_packages2 }}")))
          
          (role "sysctl")
          (tags (list
              "role::sysctl"
              "skip::sysctl"))
          (sysctl__dependent_parameters (list
              (jinja "{{ lxc__sysctl__dependent_parameters }}")
              (jinja "{{ lxd__sysctl__dependent_parameters }}")))
          
          (role "lxc")
          (tags (list
              "role::lxc"
              "skip::lxc"))
          
          (role "lxd")
          (tags (list
              "role::lxd"
              "skip::lxd"))))
      (become "True")
      (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}")))
    (task "Configure dnsmasq service"
      (import_playbook "dnsmasq.yml"))
    (task "Configure unbound service"
      (import_playbook "unbound.yml"))))
