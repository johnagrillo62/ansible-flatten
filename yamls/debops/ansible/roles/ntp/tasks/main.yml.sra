(playbook "debops/ansible/roles/ntp/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Ensure that configuration is supported"
      (ansible.builtin.assert 
        (that "not ntp__daemon or ntp__daemon in [ 'chrony', 'ntpd', 'ntpdate', 'openntpd', 'systemd-timesyncd' ]")))
    (task "Ensure that alternative daemons/programs are not installed"
      (ansible.builtin.apt 
        (name (jinja "{{ ntp__purge_packages | flatten }}"))
        (state "absent")
        (purge "True"))
      (register "ntp__register_apt_purge")
      (until "ntp__register_apt_purge is succeeded")
      (when "ntp__daemon_enabled | bool"))
    (task "Install NTP service"
      (ansible.builtin.include_tasks "install.yml")
      (when "ntp__daemon_enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save ntp local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/ntp.fact.j2")
        (dest "/etc/ansible/facts.d/ntp.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags (list
          "meta::facts")))))
