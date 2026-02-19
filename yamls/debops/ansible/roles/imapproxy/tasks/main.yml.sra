(playbook "debops/ansible/roles/imapproxy/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install imapproxy packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (imapproxy__base_packages
                              + imapproxy__packages)) }}"))
        (state "present"))
      (register "imapproxy__register_packages")
      (until "imapproxy__register_packages is succeeded")
      (tags (list
          "role::imapproxy:pkg")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save imapproxy local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/imapproxy.fact.j2")
        (dest "/etc/ansible/facts.d/imapproxy.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Divert original imapproxy configuration file"
      (debops.debops.dpkg_divert 
        (path "/etc/imapproxy.conf"))
      (notify (list
          "Restart imapproxy"))
      (tags (list
          "role::imapproxy:config")))
    (task "Generate imapproxy configuration"
      (ansible.builtin.template 
        (src "etc/imapproxy.conf.j2")
        (dest "/etc/imapproxy.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart imapproxy"))
      (tags (list
          "role::imapproxy:config")))
    (task "Make sure that PKI hook directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ imapproxy__pki_hook_path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "imapproxy__pki | bool"))
    (task "Manage PKI imapproxy hook"
      (ansible.builtin.template 
        (src "etc/pki/hooks/imapproxy.j2")
        (dest (jinja "{{ imapproxy__pki_hook_path + \"/\" + imapproxy__pki_hook_name }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "imapproxy__pki | bool"))
    (task "Ensure the PKI imapproxy hook is absent"
      (ansible.builtin.file 
        (path (jinja "{{ imapproxy__pki_hook_path + \"/\" + imapproxy__pki_hook_name }}"))
        (state "absent"))
      (when "not (imapproxy__pki | bool)"))))
