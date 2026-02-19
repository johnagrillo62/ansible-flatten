(playbook "debops/ansible/roles/ifupdown/tasks/divert_interfaces.yml"
  (tasks
    (task "Divert original /etc/network/interfaces"
      (debops.debops.dpkg_divert 
        (path "/etc/network/interfaces"))
      (register "ifupdown__register_divert"))
    (task "Provide original interface configuration temporarily"
      (ansible.builtin.copy 
        (src "/etc/network/interfaces.dpkg-divert")
        (dest (jinja "{{ ifupdown__reconfigure_init_file }}"))
        (remote_src "True")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "ifupdown__register_divert is changed and not ansible_check_mode | bool"))
    (task "Remove redundant configuration"
      (ansible.builtin.lineinfile 
        (dest (jinja "{{ ifupdown__reconfigure_init_file }}"))
        (regexp (jinja "{{ item }}"))
        (state "absent"))
      (with_items (list
          "^source /etc/network/interfaces.d/*"
          "^auto lo"
          "^iface lo inet loopback"))
      (when "ifupdown__register_divert is changed"))
    (task "Create /etc/network/interfaces"
      (ansible.builtin.template 
        (src "etc/network/interfaces.j2")
        (dest "/etc/network/interfaces")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "ifupdown__register_main_config"))
    (task "Ensure that runtime directory exists"
      (ansible.builtin.file 
        (path "/run/network")
        (state "directory")
        (mode "0755"))
      (when "(ifupdown__register_divert is changed or ifupdown__register_main_config is changed)"))
    (task "Request entire network reconfiguration"
      (ansible.builtin.copy 
        (content "init")
        (dest "/run/network/debops-ifupdown-reconfigure.networking")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Apply ifupdown configuration"))
      (when "(ifupdown__register_divert is changed or ifupdown__register_main_config is changed)"))))
