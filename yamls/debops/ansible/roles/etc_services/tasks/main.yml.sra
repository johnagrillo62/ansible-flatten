(playbook "debops/ansible/roles/etc_services/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ (etc_services__base_packages + etc_services__packages) | flatten }}"))
        (state "present"))
      (register "etc_services__register_packages")
      (until "etc_services__register_packages is succeeded"))
    (task "Make sure /etc/services.d directory exists"
      (ansible.builtin.file 
        (path "/etc/services.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Create /etc/services.d/00_ansible"
      (ansible.builtin.template 
        (src "etc/services.d/00_ansible.j2")
        (dest "/etc/services.d/00_ansible")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Add/remove diversion of /etc/services"
      (debops.debops.dpkg_divert 
        (path "/etc/services")
        (divert (jinja "{{ etc_services__diversion }}"))
        (state (jinja "{{ \"present\" if etc_services__enabled | bool else \"absent\" }}"))
        (delete "True"))
      (when "not ansible_check_mode | bool"))
    (task "Generate list of local services if requested"
      (ansible.builtin.template 
        (src "etc/services.d/local_service.j2")
        (dest "/etc/services.d/" (jinja "{{ item.filename | default(\"20_local_service_\" + item.name) }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ etc_services__combined_list | flatten }}"))
      (when "(etc_services__enabled | bool and item.state | d('present') != 'absent' and ((item.name | d() and item.port | d()) or item.custom | d()))"))
    (task "Remove list of local services if requested"
      (ansible.builtin.file 
        (path "/etc/services.d/" (jinja "{{ item.filename | default(\"20_local_service_\" + item.name) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", etc_services__combined_list) }}"))
      (when "((not etc_services__enabled | bool or item.delete | d() or item.state | d('present') == 'absent') and ((item.name | d() and item.port | d()) or item.custom | d()))"))
    (task "Assemble services.d"
      (ansible.builtin.assemble 
        (src "/etc/services.d")
        (dest "/etc/services")
        (backup "False")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "etc_services__enabled | bool"))))
