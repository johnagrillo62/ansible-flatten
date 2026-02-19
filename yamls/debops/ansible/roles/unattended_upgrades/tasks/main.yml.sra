(playbook "debops/ansible/roles/unattended_upgrades/tasks/main.yml"
  (tasks
    (task "Install required packages"
      (ansible.builtin.apt 
        (name (jinja "{{ (unattended_upgrades__base_packages
             + unattended_upgrades__packages)
             | flatten }}"))
        (state "present")
        (install_recommends "False"))
      (register "unattended_upgrades__register_packages")
      (until "unattended_upgrades__register_packages is succeeded")
      (when "unattended_upgrades__enabled | bool"))
    (task "Configure debconf answer"
      (ansible.builtin.debconf 
        (name "unattended-upgrades")
        (question "unattended-upgrades/enable_auto_updates")
        (vtype "boolean")
        (value (jinja "{{ \"true\" if unattended_upgrades__enabled | bool else \"false\" }}"))))
    (task "Configure periodic APT updates"
      (ansible.builtin.template 
        (src "etc/apt/apt.conf.d/20periodic.j2")
        (dest "/etc/apt/apt.conf.d/20periodic")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "((unattended_upgrades__periodic | bool) or (ansible_local | d() and ansible_local.unattended_upgrades | d() and ansible_local.unattended_upgrades.periodic | bool))"))
    (task "Configure periodic APT upgrades"
      (ansible.builtin.template 
        (src "etc/apt/apt.conf.d/20auto-upgrades.j2")
        (dest "/etc/apt/apt.conf.d/20auto-upgrades")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "((unattended_upgrades__enabled | bool) or (ansible_local | d() and ansible_local.unattended_upgrades | d() and ansible_local.unattended_upgrades.enabled | bool))"))
    (task "Add/remove diversion of unattended-upgrades configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/apt/apt.conf.d/50unattended-upgrades")
        (state (jinja "{{ \"present\" if unattended_upgrades__enabled | bool else \"absent\" }}"))
        (delete "True")))
    (task "Configure unattended-upgrades"
      (ansible.builtin.template 
        (src "etc/apt/apt.conf.d/50unattended-upgrades.j2")
        (dest "/etc/apt/apt.conf.d/50unattended-upgrades")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "unattended_upgrades__enabled | bool"))
    (task "Make sure that Ansible local fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Ansible local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/unattended_upgrades.fact.j2")
        (dest "/etc/ansible/facts.d/unattended_upgrades.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags (list
          "meta::facts")))))
