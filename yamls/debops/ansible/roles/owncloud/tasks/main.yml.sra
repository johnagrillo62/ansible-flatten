(playbook "debops/ansible/roles/owncloud/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Manage system package installation"
      (ansible.builtin.include_tasks "system_package_management.yml")
      (tags (list
          "role::owncloud:pkg")))
    (task "Manage tarball installation"
      (ansible.builtin.include_tasks "tarball.yml")
      (when "(owncloud__variant in [\"nextcloud\"])")
      (tags (list
          "role::owncloud:tarball")))
    (task "Setup ownCloud configuration"
      (ansible.builtin.include_tasks "setup_owncloud.yml")
      (tags (list
          "role::owncloud:config")))
    (task "Configure LDAP integration"
      (ansible.builtin.include_tasks "ldap.yml")
      (when "(owncloud__ldap_enabled | bool)")
      (tags (list
          "role::owncloud:ldap")))
    (task "Manage custom ownCloud theme"
      (ansible.builtin.include_tasks "theme.yml")
      (tags (list
          "role::owncloud:theme")))
    (task "Copy file to user profiles"
      (ansible.builtin.include_tasks "copy.yml")
      (tags (list
          "role::owncloud:copy")))))
