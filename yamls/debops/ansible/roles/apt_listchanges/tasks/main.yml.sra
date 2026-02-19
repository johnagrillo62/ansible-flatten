(playbook "debops/ansible/roles/apt_listchanges/tasks/main.yml"
  (tasks
    (task "Manage APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (apt_listchanges__base_packages
                              + apt_listchanges__packages)) }}"))
        (state (jinja "{{ apt_listchanges__deploy_state }}"))
        (purge "True"))
      (register "apt_listchanges__register_packages")
      (until "apt_listchanges__register_packages is succeeded"))
    (task "Configure apt-listchanges"
      (ansible.builtin.template 
        (src "etc/apt/listchanges.conf.j2")
        (dest "/etc/apt/listchanges.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "apt_listchanges__deploy_state == 'present'"))
    (task "Make sure that Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save apt-listchanges facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/apt_listchanges.fact.j2")
        (dest "/etc/ansible/facts.d/apt_listchanges.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (tags (list
          "meta::facts")))))
