(playbook "debops/ansible/roles/core/defaults/main.yml"
  (core__facts )
  (core__group_facts )
  (core__host_facts )
  (core__remove_facts (list))
  (core__reset_facts "False")
  (core__tags (list))
  (core__group_tags (list))
  (core__host_tags (list))
  (core__static_tags (list))
  (core__remove_tags (list))
  (core__reset_tags "False")
  (core__ansible_controllers (list))
  (core__active_controller (jinja "{{ ((ansible_env.SSH_CLIENT.split(\" \") | first)
                              if (ansible_env | d() and ansible_env.SSH_CLIENT | d())
                              else \"\") }}"))
  (core__admin_groups (list
      "admins"))
  (core__admin_users (jinja "{{ ((ansible_local.core.admin_users
                         if (ansible_local.core.admin_users | d())
                         else [])
                        + [ansible_user
                           if (ansible_user is defined and
                               ansible_user not in
                               (core__admin_blacklist_default_users
                                + core__admin_blacklist_users))
                           else lookup(\"env\", \"USER\")])
                        | unique }}"))
  (core__admin_blacklist_default_users (list
      "admin"
      "ansible"
      "debian"
      "pi"
      "root"
      "ubuntu"
      "user"))
  (core__admin_blacklist_users (list))
  (core__admin_public_email (list
      (jinja "{{ (\"root@\" + ansible_domain)
                                if ansible_domain | d()
                                else \"root\" }}")))
  (core__admin_private_email (list))
  (core__cache_valid_time (jinja "{{ (60 * 60 * 24) }}"))
  (core__distribution (jinja "{{ ansible_lsb.id
                        if (ansible_lsb.id | d())
                        else ansible_distribution }}"))
  (core__distribution_release (jinja "{{ ansible_lsb.codename
                                if (ansible_lsb.codename | d())
                                else ansible_distribution_release }}"))
  (core__homedir_umask "0027")
  (core__unsafe_writes "False")
  (core__base_packages (list
      "bash"
      "libcap2-bin"
      "lsb-release"
      "dbus"
      "dirmngr"))
  (core__packages (list))
  (core__group_packages (list))
  (core__host_packages (list)))
