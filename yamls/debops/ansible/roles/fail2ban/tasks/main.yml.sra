(playbook "debops/ansible/roles/fail2ban/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.apt 
        (name (list
            "fail2ban"
            "whois"))
        (state "present")
        (install_recommends "False"))
      (register "fail2ban__register_packages")
      (until "fail2ban__register_packages is succeeded"))
    (task "Divert original fail2ban configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/fail2ban/jail.conf")))
    (task "Copy upstream jail configuration"
      (ansible.builtin.copy 
        (src "/etc/fail2ban/jail.conf.dpkg-divert")
        (dest "/etc/fail2ban/jail.conf")
        (remote_src "True")
        (force "False")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart fail2ban")))
    (task "Disable default upstream jail"
      (ansible.builtin.lineinfile 
        (dest "/etc/fail2ban/jail.conf")
        (regexp "^(enabled  = )true")
        (line "\\1false")
        (backrefs "yes")
        (mode "0644"))
      (notify (list
          "Reload fail2ban jails")))
    (task "Install custom fail2ban rule files"
      (ansible.builtin.copy 
        (src "etc/fail2ban/")
        (dest "/etc/fail2ban/")
        (owner "root")
        (group "root")
        (mode "u=rwX,g=rX,o=rX"))
      (notify (list
          "Reload fail2ban jails")))
    (task "Install custom fail2ban iptables action files"
      (ansible.builtin.template 
        (src "etc/fail2ban/action.d/" (jinja "{{ item }}") ".local.j2")
        (dest "/etc/fail2ban/action.d/" (jinja "{{ item }}") ".local")
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "iptables-xt_recent-echo-reject"
          "iptables-xt_recent-echo")))
    (task "Configure custom fail2ban actions"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/fail2ban/action.d/action.local.j2\") }}"))
        (dest "/etc/fail2ban/action.d/" (jinja "{{ item.filename | d(item.name) }}") ".local")
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ fail2ban_actions }}"))
      (notify (list
          "Restart fail2ban"))
      (when "((item.name is defined and item.name) and (item.ban is defined and item.ban) and (item.state | d('present') not in ['absent']))"))
    (task "Remove custom fail2ban actions if requested"
      (ansible.builtin.file 
        (path "/etc/fail2ban/action.d/" (jinja "{{ item.filename | d(item.name) }}") ".local")
        (state "absent"))
      (with_items (jinja "{{ fail2ban_actions }}"))
      (notify (list
          "Restart fail2ban"))
      (when "((item.name is defined and item.name) and (item.state | d('present') in ['absent']))"))
    (task "Configure custom fail2ban filters"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/fail2ban/filter.d/filter.local.j2\") }}"))
        (dest "/etc/fail2ban/filter.d/" (jinja "{{ item.filename | d(item.name) }}") ".local")
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ fail2ban_filters }}"))
      (notify (list
          "Restart fail2ban"))
      (when "((item.name is defined and item.name) and (item.failregex is defined and item.failregex) and (item.state | d('present') not in ['absent']))"))
    (task "Remove custom fail2ban filters if requested"
      (ansible.builtin.file 
        (path "/etc/fail2ban/filter.d/" (jinja "{{ item.filename | d(item.name) }}") ".local")
        (state "absent"))
      (with_items (jinja "{{ fail2ban_filters }}"))
      (notify (list
          "Restart fail2ban"))
      (when "((item.name is defined and item.name) and (item.state | d('present') in ['absent']))"))
    (task "Configure fail2ban"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/fail2ban/fail2ban.local.j2\") }}"))
        (dest "/etc/fail2ban/fail2ban.local")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart fail2ban")))
    (task "Create jail.local.d directory"
      (ansible.builtin.file 
        (path "/etc/fail2ban/jail.local.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Configure jail default variables"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/fail2ban/jail.local.d/default.local.j2\") }}"))
        (dest "/etc/fail2ban/jail.local.d/00_default.local")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Remove fail2ban jails if requested"
      (ansible.builtin.file 
        (path "/etc/fail2ban/jail.local.d/" (jinja "{{ item.filename | default(item.name) }}") ".local")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", fail2ban_jails
                           + fail2ban_group_jails
                           + fail2ban_host_jails
                           + fail2ban_dependent_jails) }}"))
      (when "((item.name is defined and item.name) and (item.delete is defined and item.delete))"))
    (task "Configure fail2ban jails"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/fail2ban/jail.local.d/jail.local.j2\") }}"))
        (dest "/etc/fail2ban/jail.local.d/" (jinja "{{ item.filename | default(item.name) }}") ".local")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", fail2ban_jails
                           + fail2ban_group_jails
                           + fail2ban_host_jails
                           + fail2ban_dependent_jails) }}"))
      (when "((item.name is defined and item.name) and (item.delete is undefined or not item.delete))"))
    (task "Assemble /etc/fail2ban/jail.local"
      (ansible.builtin.assemble 
        (src "/etc/fail2ban/jail.local.d")
        (dest "/etc/fail2ban/jail.local")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload fail2ban jails")))))
