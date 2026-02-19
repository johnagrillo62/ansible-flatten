(playbook "kubespray/roles/kubernetes/preinstall/tasks/0060-resolvconf.yml"
  (tasks
    (task "Create temporary resolveconf cloud init file"
      (command "cp -f /etc/resolv.conf \"" (jinja "{{ resolvconffile }}") "\"")
      (when "ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"))
    (task "Add domain/search/nameservers/options to resolv.conf"
      (blockinfile 
        (path (jinja "{{ resolvconffile }}"))
        (block "domain " (jinja "{{ dns_domain }}") "
search " (jinja "{{ (default_searchdomains + searchdomains) | join(' ') }}") "
" (jinja "{% for item in nameserverentries %}") "
nameserver " (jinja "{{ item }}") "
" (jinja "{% endfor %}") "
options ndots:" (jinja "{{ ndots }}") " timeout:" (jinja "{{ dns_timeout | default('2') }}") " attempts:" (jinja "{{ dns_attempts | default('2') }}"))
        (state "present")
        (insertbefore "BOF")
        (create "true")
        (backup (jinja "{{ not resolvconf_stat.stat.islnk }}"))
        (marker "# Ansible entries {mark}")
        (mode "0644"))
      (notify "Preinstall | propagate resolvconf to k8s components"))
    (task "Remove search/domain/nameserver options before block"
      (replace 
        (path (jinja "{{ item[0] }}"))
        (regexp "^" (jinja "{{ item[1] }}") "[^#]*(?=# Ansible entries BEGIN)")
        (backup (jinja "{{ not resolvconf_stat.stat.islnk }}")))
      (with_nested (list
          (jinja "{{ [resolvconffile, base | default(''), head | default('')] | difference(['']) }}")
          (list
            "search\\s"
            "nameserver\\s"
            "domain\\s"
            "options\\s")))
      (notify "Preinstall | propagate resolvconf to k8s components"))
    (task "Remove search/domain/nameserver options after block"
      (replace 
        (path (jinja "{{ item[0] }}"))
        (regexp "(# Ansible entries END\\n(?:(?!^" (jinja "{{ item[1] }}") ").*\\n)*)(?:^" (jinja "{{ item[1] }}") ".*\\n?)+")
        (replace "\\1")
        (backup (jinja "{{ not resolvconf_stat.stat.islnk }}")))
      (with_nested (list
          (jinja "{{ [resolvconffile, base | default(''), head | default('')] | difference(['']) }}")
          (list
            "search\\s"
            "nameserver\\s"
            "domain\\s"
            "options\\s")))
      (notify "Preinstall | propagate resolvconf to k8s components"))
    (task "Get temporary resolveconf cloud init file content"
      (command "cat " (jinja "{{ resolvconffile }}"))
      (register "cloud_config")
      (when "ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"))
    (task "Persist resolvconf cloud init file"
      (template 
        (dest (jinja "{{ resolveconf_cloud_init_conf }}"))
        (src "resolvconf.j2")
        (owner "root")
        (mode "0644"))
      (notify "Preinstall | update resolvconf for Flatcar Container Linux by Kinvolk")
      (when "ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"))))
