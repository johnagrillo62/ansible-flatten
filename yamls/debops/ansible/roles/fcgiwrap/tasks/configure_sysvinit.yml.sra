(playbook "debops/ansible/roles/fcgiwrap/tasks/configure_sysvinit.yml"
  (tasks
    (task "Create init script configuration"
      (ansible.builtin.template 
        (src "etc/default/fcgiwrap-instance.j2")
        (dest "/etc/default/fcgiwrap-" (jinja "{{ item.name }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ fcgiwrap__instances }}"))
      (register "fcgiwrap__register_init_config"))
    (task "Copy fcgiwrap init script to new instance"
      (ansible.builtin.command "cp /etc/init.d/fcgiwrap /etc/init.d/fcgiwrap-" (jinja "{{ item.name }}"))
      (args 
        (creates "/etc/init.d/fcgiwrap-" (jinja "{{ item.name }}")))
      (register "fcgiwrap__register_init_script")
      (with_items (jinja "{{ fcgiwrap__instances }}")))
    (task "Modify fcgiwrap instance init script (insserv)"
      (ansible.builtin.lineinfile 
        (dest "/etc/init.d/fcgiwrap-" (jinja "{{ item.name }}"))
        (regexp "^# Provides:\\s+fcgiwrap.*$")
        (line "# Provides:          fcgiwrap-" (jinja "{{ item.name }}"))
        (state "present")
        (mode "0755"))
      (with_items (jinja "{{ fcgiwrap__instances }}")))
    (task "Modify fcgiwrap instance init script (name)"
      (ansible.builtin.lineinfile 
        (dest "/etc/init.d/fcgiwrap-" (jinja "{{ item.name }}"))
        (regexp "^NAME=\"fcgiwrap.*\"$")
        (line "NAME=\"fcgiwrap-" (jinja "{{ item.name }}") "\"")
        (state "present")
        (mode "0755"))
      (with_items (jinja "{{ fcgiwrap__instances }}")))
    (task "Enable fcgiwrap instance init script"
      (ansible.builtin.service 
        (name "fcgiwrap-" (jinja "{{ item.name }}"))
        (state "started")
        (enabled "True"))
      (with_items (jinja "{{ fcgiwrap__instances }}")))))
