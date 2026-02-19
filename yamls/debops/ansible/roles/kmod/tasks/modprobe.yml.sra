(playbook "debops/ansible/roles/kmod/tasks/modprobe.yml"
  (tasks
    (task "Remove module configuration"
      (ansible.builtin.file 
        (dest "/etc/modprobe.d/" (jinja "{{ module.filename | d(module.name | replace(\"_\", \"-\") + \".conf\") }}"))
        (state "absent"))
      (notify (list
          "Refresh host facts"))
      (register "kmod__register_module_config_delete")
      (when "module.name | d() and module.state | d('present') == 'absent'"))
    (task "Generate module configuration"
      (ansible.builtin.template 
        (src "etc/modprobe.d/module.conf.j2")
        (dest "/etc/modprobe.d/" (jinja "{{ module.filename | d(module.name | replace(\"_\", \"-\") + \".conf\") }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (register "kmod__register_module_config_create")
      (when "module.name | d() and module.state | d('present') != 'absent'"))
    (task "Unload kernel module if configuration changed"
      (community.general.modprobe 
        (name (jinja "{{ module.name }}"))
        (state "absent"))
      (when "((kmod__register_module_config_delete is changed or kmod__register_module_config_create is changed) and module.blacklist is not defined and ansible_local.kmod.modules | d() and module.name in ansible_local.kmod.modules and module.state | d('present') not in ['config'])"))
    (task "Load kernel module if configuration changed"
      (community.general.modprobe 
        (name (jinja "{{ module.name }}"))
        (state "present"))
      (when "((kmod__register_module_config_delete is changed or kmod__register_module_config_create is changed) and module.blacklist is not defined and module.state | d('present') not in ['config', 'absent', 'blacklist'])"))))
