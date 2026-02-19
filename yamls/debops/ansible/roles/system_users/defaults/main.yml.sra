(playbook "debops/ansible/roles/system_users/defaults/main.yml"
  (system_users__enabled "True")
  (system_users__acl_enabled (jinja "{{ True if (\"acl\" in system_users__base_packages) else False }}"))
  (system_users__default_shell "")
  (system_users__shell_package_map 
    (/bin/bash "bash")
    (/bin/csh "csh")
    (/usr/bin/fish "fish")
    (/bin/ksh "ksh")
    (/bin/zsh "zsh"))
  (system_users__base_packages (list
      "acl"))
  (system_users__shell_packages (jinja "{{ lookup(\"template\", \"lookup/system_users__shell_packages.j2\") | from_yaml }}"))
  (system_users__packages (list))
  (system_users__prefix (jinja "{{ ansible_local.system_users.prefix | d(\"_\"
                            if (\"debops_service_ldap\" in group_names or
                                (ansible_local.ldap.posix_enabled | d() | bool))
                            else \"\") }}"))
  (system_users__home_root (jinja "{{ \"/var/local\"
                             if (\"debops_service_ldap\" in group_names or
                                 (ansible_local.ldap.posix_enabled | d() | bool))
                             else \"/home\" }}"))
  (system_users__default_home_mode "0751")
  (system_users__admin_groups (jinja "{{ ansible_local.system_groups.access.root | d([\"admins\"]) }}"))
  (system_users__dotfiles_enabled (jinja "{{ True
                                    if ansible_local.yadm.dotfiles | d()
                                    else False }}"))
  (system_users__dotfiles_repo (jinja "{{ ansible_local.yadm.dotfiles | d(\"\") }}"))
  (system_users__self (jinja "{{ False
                        if (system_users__self_name == \"root\" or
                            ansible_connection | d(\"ssh\") == \"local\")
                        else True }}"))
  (system_users__self_name (jinja "{{ lookup(\"env\", \"USER\") }}"))
  (system_users__self_comment "Ansible Control User")
  (system_users__self_shell "/bin/bash")
  (system_users__groups (list))
  (system_users__group_groups (list))
  (system_users__host_groups (list))
  (system_users__dependent_groups (list))
  (system_users__default_accounts (list
      
      (name (jinja "{{ system_users__self_name }}"))
      (group (jinja "{{ system_users__self_name }}"))
      (prefix (jinja "{{ \"\" if ansible_user | d() else system_users__prefix }}"))
      (comment (jinja "{{ system_users__fact_self_comment
                 | d(system_users__self_comment)
                 | regex_replace(\",,,$\", \"\") }}"))
      (shell (jinja "{{ (system_users__fact_self_shell | d(system_users__self_shell))
               if ((system_users__fact_self_shell | d(system_users__self_shell))
                   in system_users__shell_package_map.keys())
               else omit }}"))
      (admin "True")
      (sshkeys (jinja "{{ lookup(\"pipe\", \"ssh-add -L | grep ^\\\\\\(sk-\\\\\\)\\\\\\?ssh || cat ~/.ssh/*.pub || cat ~/.ssh/authorized_keys || true\") }}"))
      (state (jinja "{{ \"present\"
               if system_users__self | bool
               else \"ignore\" }}"))))
  (system_users__accounts (list))
  (system_users__group_accounts (list))
  (system_users__host_accounts (list))
  (system_users__dependent_accounts (list))
  (system_users__combined_accounts (jinja "{{ system_users__groups
                                     + system_users__group_groups
                                     + system_users__host_groups
                                     + (system_users__dependent_groups | flatten)
                                     + system_users__default_accounts
                                     + system_users__accounts
                                     + system_users__group_accounts
                                     + system_users__host_accounts
                                     + (system_users__dependent_accounts | flatten) }}")))
