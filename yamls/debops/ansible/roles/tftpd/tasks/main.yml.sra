(playbook "debops/ansible/roles/tftpd/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (tftpd__base_packages + tftpd__packages)) }}"))
        (state "present"))
      (register "tftpd__register_install")
      (until "tftpd__register_install is succeeded"))
    (task "Configure tftpd service"
      (ansible.builtin.template 
        (src "etc/default/tftpd-hpa.j2")
        (dest "/etc/default/tftpd-hpa")
        (mode "0644"))
      (notify (list
          "Restart tftpd-hpa")))
    (task "Create the upload directory if enabled"
      (ansible.builtin.file 
        (path (jinja "{{ tftpd__directory + \"/\" + tftpd__upload_directory }}"))
        (owner (jinja "{{ tftpd__username }}"))
        (group (jinja "{{ tftpd__upload_group }}"))
        (mode (jinja "{{ tftpd__upload_mode }}"))
        (state "directory"))
      (when "tftpd__upload_enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save tftpd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/tftpd.fact.j2")
        (dest "/etc/ansible/facts.d/tftpd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
