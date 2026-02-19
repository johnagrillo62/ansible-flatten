(playbook "debops/ansible/roles/pam_access/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Add/remove diversion of PAM access control files"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ pam_access__var_access_conf }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (delete "True"))
      (vars 
        (pam_access__var_access_conf (jinja "{{ \"/etc/security/\"
                                     + item.filename | d(\"access-\" + (item.name | regex_replace(\"\\.conf$\", \"\")) + \".conf\") }}")))
      (loop (jinja "{{ pam_access__combined_rules | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"access_conf\": pam_access__var_access_conf, \"state\": item.state | d(\"present\")} }}")))
      (when "(pam_access__enabled | bool and item.name | d() and item.divert | d(False) | bool and item.state | d('present') in ['present', 'absent'])"))
    (task "Generate PAM access control files"
      (ansible.builtin.template 
        (src "etc/security/access.conf.j2")
        (dest "/etc/security/" (jinja "{{ item.filename | d(\"access-\" + (item.name | regex_replace(\"\\.conf$\", \"\")) + \".conf\") }}"))
        (mode "0644"))
      (vars 
        (pam_access__var_access_conf (jinja "{{ \"/etc/security/\"
                                     + item.filename | d(\"access-\" + (item.name | regex_replace(\"\\.conf$\", \"\")) + \".conf\") }}")))
      (loop (jinja "{{ pam_access__combined_rules | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"access_conf\": pam_access__var_access_conf, \"state\": item.state | d(\"present\")} }}")))
      (when "pam_access__enabled | bool and item.name | d() and item.options | d() and item.state | d('present') not in ['absent', 'init', 'ignore']"))
    (task "Remove PAM access control files"
      (ansible.builtin.file 
        (path "/etc/security/" (jinja "{{ item.filename | d(\"access-\" + (item.name | regex_replace(\"\\.conf$\", \"\")) + \".conf\") }}"))
        (state "absent"))
      (vars 
        (pam_access__var_access_conf (jinja "{{ \"/etc/security/\"
                                     + item.filename | d(\"access-\" + (item.name | regex_replace(\"\\.conf$\", \"\")) + \".conf\") }}")))
      (loop (jinja "{{ pam_access__combined_rules | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"access_conf\": pam_access__var_access_conf, \"state\": item.state | d(\"present\")} }}")))
      (when "pam_access__enabled | bool and item.name | d() and not item.divert | d(False) | bool and item.state | d('present') == 'absent'"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save pam_access local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/pam_access.fact.j2")
        (dest "/etc/ansible/facts.d/pam_access.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
