(playbook "debops/ansible/roles/core/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Ensure that APT cache is valid"
      (ansible.builtin.apt 
        (update_cache "True")
        (cache_valid_time (jinja "{{ \"86400\" if ansible_local | d() else omit }}")))
      (register "core__register_apt_update")
      (until "core__register_apt_update is succeeded")
      (when "ansible_pkg_mgr == 'apt'")
      (tags (list
          "meta::provision")))
    (task "Install required core packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (core__base_packages
                              + core__packages
                              + core__group_packages
                              + core__host_packages)) }}"))
        (state "present"))
      (notify (list
          "Refresh host facts"))
      (register "core__register_packages")
      (until "core__register_packages is succeeded")
      (tags (list
          "meta::provision")))
    (task "Re-gather facts on package installation"
      (ansible.builtin.meta "flush_handlers"))
    (task "Check IP address of current Ansible Controller"
      (ansible.builtin.set_fact 
        (core__fact_ansible_controller (jinja "{{ core__active_controller }}")))
      (when "core__fact_ansible_controller is undefined and ansible_connection != \"local\"")
      (tags (list
          "role::core"
          "role::ferm"
          "role::ferm:config"
          "role::tcpwrappers"))
      (become "False"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755"))
      (tags (list
          "meta::facts")))
    (task "Save local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/" (jinja "{{ item }}") ".fact.j2")
        (dest "/etc/ansible/facts.d/" (jinja "{{ item }}") ".fact")
        (mode "0755"))
      (with_items (list
          "core"
          "tags"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Gather local facts if they changed"
      (ansible.builtin.meta "flush_handlers"))))
