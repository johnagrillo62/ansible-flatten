(playbook "debops/ansible/roles/locales/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install locale packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (locales__base_packages
                              + locales__packages)) }}"))
        (state "present"))
      (register "locales__register_packages")
      (until "locales__register_packages is succeeded"))
    (task "Ensure that specified locales exist"
      (community.general.locale_gen 
        (name (jinja "{{ item.name | d(item) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (loop (jinja "{{ q(\"flattened\", locales__default_list
                           + locales__list
                           + locales__group_list
                           + locales__host_list
                           + locales__dependent_list) }}")))
    (task "Set default system locale"
      (ansible.builtin.debconf 
        (name "locales")
        (question "locales/default_environment_locale")
        (vtype "string")
        (value (jinja "{{ locales__system_lang }}")))
      (register "locales__register_system_lang")
      (when "ansible_pkg_mgr == 'apt' and locales__system_lang | d()"))
    (task "Update /etc/default/locale"
      (ansible.builtin.command "update-locale LANG=" (jinja "{{ locales__system_lang }}"))
      (register "locales__register_update_locale")
      (changed_when "locales__register_update_locale.changed | bool")
      (when "ansible_pkg_mgr == 'apt' and locales__register_system_lang is changed"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save locale local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/locales.fact.j2")
        (dest "/etc/ansible/facts.d/locales.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
