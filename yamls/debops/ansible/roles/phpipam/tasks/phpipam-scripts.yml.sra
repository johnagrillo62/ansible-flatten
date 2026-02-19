(playbook "debops/ansible/roles/phpipam/tasks/phpipam-scripts.yml"
  (tasks
    (task "Install required packages for phpipam-scripts"
      (ansible.builtin.package 
        (name "python-mysqldb")
        (state "present"))
      (register "phpipam__register_packages")
      (until "phpipam__register_packages is succeeded"))
    (task "Clone phpipam-scripts"
      (ansible.builtin.git 
        (repo (jinja "{{ phpipam__scripts_git_repo }}"))
        (dest (jinja "{{ phpipam__scripts_git_dest }}"))
        (version (jinja "{{ phpipam__scripts_git_version }}"))
        (update "True"))
      (register "phpipam__register_scripts_src"))
    (task "Install phpipam-scripts"
      (ansible.builtin.command "make install")
      (args 
        (chdir (jinja "{{ phpipam__scripts_git_dest }}")))
      (register "phpipam__register_make_install")
      (changed_when "phpipam__register_make_install.changed | bool")
      (when "phpipam__register_scripts_src is defined and phpipam__register_scripts_src is changed"))
    (task "Configure phpipam-scripts"
      (ansible.builtin.template 
        (src "etc/dhcp/phpipam.conf.j2")
        (dest "/etc/dhcp/phpipam.conf")
        (owner "root")
        (group "root")
        (mode "0600")))
    (task "Configure phpipam-scripts-wrapper"
      (ansible.builtin.template 
        (src "usr/local/sbin/phpipam-hosts-wrapper.j2")
        (dest "/usr/local/sbin/phpipam-hosts-wrapper")
        (owner "root")
        (group "root")
        (mode "0755"))
      (register "phpipam__register_hosts_wrapper"))
    (task "Create wrapper script entry in cron"
      (ansible.builtin.cron 
        (name "Regenerate DHCP hosts files")
        (cron_file "phpipam-scripts")
        (minute (jinja "{{ phpipam__scripts_cron_period }}"))
        (job "/usr/local/sbin/phpipam-hosts-wrapper")
        (user "root")
        (state "present")))))
