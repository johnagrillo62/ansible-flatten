(playbook "debops/ansible/roles/prosody/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (prosody__base_packages
                              + prosody__packages)) }}"))
        (state "present"))
      (register "prosody__register_packages")
      (until "prosody__register_packages is succeeded"))
    (task "Generate Prosody configuration"
      (ansible.builtin.template 
        (src "etc/prosody/prosody.cfg.lua.j2")
        (dest "/etc/prosody/prosody.cfg.lua")
        (mode "0640"))
      (notify (list
          "Restart prosody")))
    (task "Enable Services"
      (ansible.builtin.service 
        (name (jinja "{{ item }}"))
        (enabled "yes")
        (state "started"))
      (with_items (list
          "prosody")))
    (task "Make sure that PKI hook directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ prosody__pki_hook_path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(prosody__pki | bool and prosody__deploy_state in ['present'])"))
    (task "Manage PKI prosody hook"
      (ansible.builtin.template 
        (src "etc/pki/hooks/prosody.j2")
        (dest (jinja "{{ prosody__pki_hook_path + \"/\" + prosody__pki_hook_name }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(prosody__pki | bool and prosody__deploy_state in ['present'])"))
    (task "Ensure the PKI prosody hook is absent"
      (ansible.builtin.file 
        (path (jinja "{{ prosody__pki_hook_path + \"/\" + prosody__pki_hook_name }}"))
        (state "absent"))
      (when "(prosody__deploy_state in ['absent'])"))))
