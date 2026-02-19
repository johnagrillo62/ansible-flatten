(playbook "debops/ansible/roles/stunnel/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Pre hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"stunnel/pre_main.yml\") }}")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", ([\"stunnel4\", \"openssl\", \"ssl-cert\"])) }}"))
        (state "present"))
      (register "stunnel__register_packages")
      (until "stunnel__register_packages is succeeded"))
    (task "Configure default variables"
      (ansible.builtin.template 
        (src "etc/default/stunnel4.j2")
        (dest "/etc/default/stunnel4")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart stunnel")))
    (task "Add stunnel user to ssl-cert system group"
      (ansible.builtin.user 
        (name "stunnel4")
        (state "present")
        (createhome "False")
        (groups "ssl-cert")
        (append "True")))
    (task "Remove SSL tunnels if requested"
      (ansible.builtin.file 
        (path "/etc/stunnel/" (jinja "{{ item.filename | default(item.name) }}") ".conf")
        (state "absent"))
      (with_items (jinja "{{ stunnel_services }}"))
      (when "((item.name is defined and item.name) and (item.delete is defined and item.delete | bool))")
      (notify (list
          "Restart stunnel")))
    (task "Configure SSL tunnels"
      (ansible.builtin.template 
        (src "etc/stunnel/service.conf.j2")
        (dest "/etc/stunnel/" (jinja "{{ item.filename | default(item.name) }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ stunnel_services }}"))
      (when "((item.name is defined and item.name) and (item.delete is undefined or not item.delete | bool))")
      (notify (list
          "Restart stunnel")))
    (task "Post hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"stunnel/post_main.yml\") }}")))))
