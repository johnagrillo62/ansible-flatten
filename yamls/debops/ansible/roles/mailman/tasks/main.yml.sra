(playbook "debops/ansible/roles/mailman/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install required APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", mailman__base_packages
                             + mailman__packages) }}"))
        (state "present"))
      (register "mailman__register_packages")
      (until "mailman__register_packages is succeeded"))
    (task "Create systemd configuration directories"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/system/\" + item }}"))
        (state "directory")
        (mode "0755"))
      (loop (list
          "mailman3.service.d"
          "mailman3-web.service.d"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Configure systemd services"
      (ansible.builtin.template 
        (src (jinja "{{ \"etc/systemd/system/\" + item + \"/dependencies.conf.j2\" }}"))
        (dest (jinja "{{ \"/etc/systemd/system/\" + item + \"/dependencies.conf\" }}"))
        (mode "0644"))
      (loop (list
          "mailman3.service.d"
          "mailman3-web.service.d"))
      (notify (list
          "Reload service manager"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Mailman local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/mailman.fact.j2")
        (dest "/etc/ansible/facts.d/mailman.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Generate Mailman Core configuration"
      (ansible.builtin.template 
        (src "etc/mailman3/" (jinja "{{ item }}") ".j2")
        (dest "/etc/mailman3/" (jinja "{{ item }}"))
        (group (jinja "{{ mailman__group }}"))
        (mode "0640"))
      (loop (list
          "mailman.cfg"
          "mailman-hyperkitty.cfg"))
      (notify (list
          "Restart mailman3")))
    (task "Generate Mailman Web configuration"
      (ansible.builtin.template 
        (src "etc/mailman3/mailman-web.py.j2")
        (dest "/etc/mailman3/mailman-web.py")
        (group "www-data")
        (mode "0640"))
      (notify (list
          "Restart mailman3-web")))
    (task "Create required template directories"
      (ansible.builtin.file 
        (path (jinja "{{ \"/var/lib/mailman3/templates/\" + (item.name | dirname) }}"))
        (state "directory")
        (owner (jinja "{{ mailman__user }}"))
        (group (jinja "{{ mailman__group }}"))
        (mode "0755"))
      (loop (jinja "{{ mailman__combined_templates | debops.debops.parse_kv_items }}"))
      (when "item.state | d('present') != 'absent'"))
    (task "Remove custom Mailman templates if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/var/lib/mailman3/templates/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ mailman__combined_templates | debops.debops.parse_kv_items }}"))
      (when "item.state | d('present') == 'absent'"))
    (task "Generate custom Mailman templates"
      (ansible.builtin.copy 
        (content (jinja "{{ item.content | d(\"\") }}"))
        (dest (jinja "{{ \"/var/lib/mailman3/templates/\" + item.name }}"))
        (owner (jinja "{{ mailman__user }}"))
        (group (jinja "{{ mailman__group }}"))
        (mode "0644"))
      (loop (jinja "{{ mailman__combined_templates | debops.debops.parse_kv_items }}"))
      (when "item.state | d('present') != 'absent'"))
    (task "Ensure Postfix lookup tables exist"
      (ansible.builtin.command "mailman aliases")
      (args 
        (creates "/var/lib/mailman3/data/postfix_domains"))
      (register "mailman__register_aliases")
      (become "True")
      (become_user (jinja "{{ mailman__user }}")))
    (task "Create Django superuser account"
      (community.general.django_manage 
        (command "createsuperuser --noinput --username=" (jinja "{{ mailman__superuser_name }}") " --email=" (jinja "{{ mailman__superuser_email }}"))
        (app_path "/usr/share/mailman3-web"))
      (when "mailman__register_aliases is changed and not mailman__ldap_enabled | bool"))))
