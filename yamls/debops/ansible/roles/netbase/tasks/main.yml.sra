(playbook "debops/ansible/roles/netbase/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (netbase__base_packages
                              + netbase__packages)) }}"))
        (state "present"))
      (register "netbase__register_packages")
      (until "netbase__register_packages is succeeded")
      (when "netbase__enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save netbase local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/netbase.fact.j2")
        (dest "/etc/ansible/facts.d/netbase.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Manage the hostname"
      (ansible.builtin.hostname 
        (name (jinja "{{ netbase__hostname }}")))
      (notify (list
          "Refresh host facts"))
      (when "netbase__enabled | bool and netbase__hostname_config_enabled | bool"))
    (task "Generate /etc/hosts database"
      (ansible.builtin.template 
        (src "etc/hosts.j2")
        (dest "/etc/hosts")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (when "netbase__enabled | bool and netbase__hosts_config_type == 'template'"))
    (task "Manage entries in /etc/hosts"
      (ansible.builtin.lineinfile 
        (dest "/etc/hosts")
        (regexp "^" (jinja "{{ item.name | replace(\".\", \"\\.\") }}") "\\s+")
        (line (jinja "{{ item.name }}") "	" (jinja "{{ ('\\t' if (item.name | string | length < 8) else '') }}") (jinja "{{ item.value
                 if (item.value is string)
                 else ((item.value | d()) | selectattr('name', 'defined') | map(attribute='name') | list | join(' ')) }}"))
        (state (jinja "{{ \"present\" if item.value | d() else \"absent\" }}"))
        (mode "0644"))
      (loop (jinja "{{ netbase__combined_hosts | debops.debops.parse_kv_config }}"))
      (loop_control 
        (label (jinja "{{ {item.name: (item.value | d([])) | selectattr(\"name\", \"defined\") | map(attribute=\"name\") | list} }}")))
      (notify (list
          "Refresh host facts"))
      (when "netbase__enabled | bool and netbase__hosts_config_type == 'lineinfile' and item.name | d()"))
    (task "Manage entries in /etc/networks"
      (ansible.builtin.lineinfile 
        (dest "/etc/networks")
        (regexp "^" (jinja "{{ item.key | replace(\".\", \"\\.\") }}") "\\s+")
        (line (jinja "{{ item.key }}") "	" (jinja "{{ item.value if (item.value is string) else (item.value | d() | join(' ')) }}"))
        (state (jinja "{{ \"present\" if item.value | d() else \"absent\" }}"))
        (mode "0644"))
      (with_dict (jinja "{{ netbase__networks | combine(netbase__group_networks, netbase__host_networks) }}"))
      (notify (list
          "Refresh host facts"))
      (when "netbase__enabled | bool"))
    (task "Update Ansible facts if databases were modified"
      (ansible.builtin.meta "flush_handlers"))))
