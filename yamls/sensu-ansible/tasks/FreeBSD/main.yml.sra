(playbook "sensu-ansible/tasks/FreeBSD/main.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "setup"))
    (task "Ensure the Sensu group is present"
      (group 
        (name (jinja "{{ sensu_group_name }}"))
        (state "present"))
      (tags "setup"))
    (task "Ensure the Sensu user is present"
      (user 
        (name (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (shell "/bin/false")
        (home (jinja "{{ sensu_config_path }}"))
        (createhome "true")
        (state "present"))
      (tags "setup"))
    (task "Ensure pkgng custom repo config directory exists"
      (file 
        (path "/usr/local/etc/pkg/repos/")
        (state "directory"))
      (tags "setup"))
    (task "Ensure Sensu repo is configured"
      (template 
        (src "sensu-freebsd-repo.conf.j2")
        (dest "/usr/local/etc/pkg/repos/sensu.conf"))
      (tags "setup")
      (notify (list
          "Update pkgng database")))
    (task "Ensure prerequisite packages are installed"
      (pkgng 
        (name (jinja "{{ item }}"))
        (state "present"))
      (tags "setup")
      (loop (list
          "bash"
          "ca_root_nss")))
    (task "Ensure Sensu is installed"
      (pkgng 
        (name (jinja "{{ sensu_package }}"))
        (state (jinja "{{ sensu_pkg_state }}")))
      (tags "setup"))))
