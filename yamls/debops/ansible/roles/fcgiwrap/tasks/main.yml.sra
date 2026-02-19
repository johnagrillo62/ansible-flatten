(playbook "debops/ansible/roles/fcgiwrap/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", fcgiwrap__packages) }}"))
        (state "present"))
      (register "fcgiwrap__register_install")
      (until "fcgiwrap__register_install is succeeded"))
    (task "Check the fcgiwrap version"
      (ansible.builtin.shell "dpkg-query -W -f='${Version}
' 'fcgiwrap'")
      (environment 
        (LC_MESSAGES "C"))
      (register "fcgiwrap__register_version")
      (changed_when "False")
      (failed_when "False")
      (check_mode "False"))
    (task "Make sure required system groups exist"
      (ansible.builtin.group 
        (name (jinja "{{ item.group | d(item.user) }}"))
        (system (jinja "{{ item.system | d(True) }}"))
        (state "present"))
      (with_items (jinja "{{ fcgiwrap__instances }}"))
      (when "fcgiwrap__instances and item.user | d(False)"))
    (task "Make sure required system accounts exist"
      (ansible.builtin.user 
        (name (jinja "{{ item.user }}"))
        (group (jinja "{{ item.group | d(item.user) }}"))
        (shell (jinja "{{ item.shell | d(omit) }}"))
        (home (jinja "{{ item.home | d(omit) }}"))
        (createhome (jinja "{{ item.createhome | d(False) }}"))
        (system (jinja "{{ item.system | d(True) }}"))
        (state "present"))
      (with_items (jinja "{{ fcgiwrap__instances }}"))
      (when "fcgiwrap__instances and item.user | d(False)"))
    (task "Disable default fcgiwrap init script"
      (ansible.builtin.service 
        (name "fcgiwrap")
        (state "stopped")
        (enabled "False"))
      (when "fcgiwrap__disable_default | bool and fcgiwrap__register_install is changed"))
    (task "Configure fcgiwrap instances in sysvinit"
      (ansible.builtin.include_tasks "configure_sysvinit.yml")
      (when "ansible_service_mgr != 'systemd'"))
    (task "Configure fcgiwrap instances in systemd"
      (ansible.builtin.include_tasks "configure_systemd.yml")
      (when "ansible_service_mgr == 'systemd'"))))
