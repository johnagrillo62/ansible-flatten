(playbook "debops/ansible/roles/users/defaults/main.yml"
  (users__enabled "True")
  (users__acl_enabled (jinja "{{ True if (\"acl\" in users__base_packages) else False }}"))
  (users__default_shell "")
  (users__shell_package_map 
    (/bin/bash "bash")
    (/bin/csh "csh")
    (/usr/bin/fish "fish")
    (/bin/ksh "ksh")
    (/bin/zsh "zsh"))
  (users__base_packages (list
      "acl"))
  (users__shell_packages (jinja "{{ lookup(\"template\", \"lookup/users__shell_packages.j2\") | from_yaml }}"))
  (users__packages (list))
  (users__default_home_mode "0751")
  (users__chroot_groups (list
      "sftponly"))
  (users__chroot_shell "/usr/sbin/nologin")
  (users__dotfiles_enabled "False")
  (users__dotfiles_repo (jinja "{{ ansible_local.yadm.dotfiles | d(\"\") }}"))
  (users__groups (list))
  (users__group_groups (list))
  (users__host_groups (list))
  (users__dependent_groups (list))
  (users__default_accounts (list))
  (users__accounts (list))
  (users__group_accounts (list))
  (users__host_accounts (list))
  (users__dependent_accounts (list))
  (users__combined_accounts (jinja "{{ users__groups
                              + users__group_groups
                              + users__host_groups
                              + users__dependent_groups
                              + users__default_accounts
                              + users__accounts
                              + users__group_accounts
                              + users__host_accounts
                              + users__dependent_accounts }}")))
