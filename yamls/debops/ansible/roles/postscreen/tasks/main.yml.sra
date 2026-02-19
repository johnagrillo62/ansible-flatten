(playbook "debops/ansible/roles/postscreen/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Generate Postscreen configuration files"
      (ansible.builtin.template 
        (src "etc/postfix/" (jinja "{{ item }}") ".j2")
        (dest "/etc/postfix/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "postscreen_access.cidr"
          "postscreen_dnsbl_reply_map.pcre"))
      (notify (list
          "Check postfix and reload")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Postscreen local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/postscreen.fact.j2")
        (dest "/etc/ansible/facts.d/postscreen.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
