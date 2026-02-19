(playbook "debops/ansible/roles/apparmor/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (apparmor__base_packages
                              + apparmor__packages)) }}"))
        (state "present"))
      (register "apparmor__register_packages")
      (until "apparmor__register_packages is succeeded")
      (tags (list
          "role::apparmor:pkg")))
    (task "Make sure that the Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save AppArmor local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/apparmor.fact.j2")
        (dest "/etc/ansible/facts.d/apparmor.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Add AppArmor kernel parameters to GRUB configuration"
      (ansible.builtin.template 
        (src "etc/default/grub.d/debops.apparmor.cfg.j2")
        (dest "/etc/default/grub.d/debops.apparmor.cfg")
        (mode "0644"))
      (when "apparmor__enabled | d(False) | bool and apparmor__manage_grub | d(False) | bool
")
      (notify (list
          "Update GRUB"))
      (tags (list
          "role::apparmor:grub")))
    (task "Remove AppArmor kernel parameters from GRUB configuration"
      (ansible.builtin.file 
        (path "/etc/default/grub.d/debops.apparmor.cfg")
        (state "absent"))
      (when "not apparmor__enabled | d(False) | bool or not apparmor__manage_grub | d(False) | bool
")
      (notify (list
          "Update GRUB"))
      (tags (list
          "role::apparmor:grub")))
    (task "Remove legacy GRUB configuration options"
      (ansible.builtin.lineinfile 
        (dest "/etc/default/grub")
        (regexp "^GRUB_CMDLINE_LINUX=\"(.*?)\\$GRUB_CMDLINE_LINUX_ANSIBLE_APPARMOR(.*)\"")
        (line "GRUB_CMDLINE_LINUX=\"\\1 \\2\"")
        (backrefs "yes")
        (mode "0644"))
      (notify (list
          "Update GRUB"))
      (tags (list
          "role::apparmor:grub")))
    (task "Configure tunables"
      (ansible.builtin.include_tasks "handle_tunables.yml")
      (loop (jinja "{{ apparmor__combined_tunables | debops.debops.parse_kv_items() }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (tags (list
          "role::apparmor:tunables")))
    (task "Configure local changes to system profiles"
      (ansible.builtin.include_tasks "handle_locals.yml")
      (loop (jinja "{{ apparmor__combined_locals | debops.debops.parse_kv_items() }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (tags (list
          "role::apparmor:locals")))
    (task "Configure profiles"
      (ansible.builtin.include_tasks "handle_profiles.yml")
      (loop (jinja "{{ apparmor__combined_profiles | debops.debops.parse_kv_items() }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (tags (list
          "role::apparmor:profiles")))
    (task "Start and enable the AppArmor service"
      (ansible.builtin.service 
        (name "apparmor")
        (state "started")
        (enabled "True"))
      (when (list
          "apparmor__enabled | d(False) | bool"
          "ansible_local.apparmor.installed | d(False) | bool"))
      (tags (list
          "role::apparmor:service")))
    (task "Reload AppArmor profiles if necessary"
      (ansible.builtin.meta "flush_handlers")
      (tags (list
          "role::apparmor:profiles")))
    (task "Stop and disable the AppArmor service"
      (ansible.builtin.service 
        (name "apparmor")
        (state "stopped")
        (enabled "False"))
      (when (list
          "not apparmor__enabled | d(False) | bool"
          "ansible_local.apparmor.installed | d(False) | bool"))
      (tags (list
          "role::apparmor:service")))
    (task "Unload all AppArmor profiles"
      (ansible.builtin.command "aa-teardown")
      (when (list
          "not apparmor__enabled | d(False) | bool"
          "ansible_local.apparmor.installed | d(False) | bool"))
      (register "apparmor__register_teardown")
      (changed_when "apparmor__register_teardown.changed | bool")
      (tags (list
          "role::apparmor:profiles")))))
