(playbook "debops/ansible/roles/ipxe/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (ipxe__base_packages + ipxe__packages)) }}"))
        (state "present"))
      (register "ipxe__register_packages")
      (until "ipxe__register_packages is succeeded"))
    (task "Ensure that iPXE script directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ ipxe__tftp_root + \"/\" + (((item.name | regex_replace(\"\\.ipxe$\", \"\")) + \".ipxe\") | dirname) }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ ipxe__combined_scripts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name,
                \"path\": (ipxe__tftp_root + \"/\" + ((item.name | regex_replace(\"\\.ipxe$\", \"\") + \".ipxe\") | dirname)),
                \"state\": item.state | d(\"present\")} }}")))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Generate iPXE scripts"
      (ansible.builtin.template 
        (src "srv/tftp/template.ipxe.j2")
        (dest (jinja "{{ ipxe__tftp_root + \"/\" + (item.name | regex_replace(\"\\.ipxe$\", \"\")) + \".ipxe\" }}"))
        (mode "0644"))
      (loop (jinja "{{ ipxe__combined_scripts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name,
                \"state\": item.state | d(\"present\")} }}")))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Remove iPXE scripts if requested"
      (ansible.builtin.file 
        (path (jinja "{{ ipxe__tftp_root + \"/\" + (item.name | regex_replace(\"\\.ipxe$\", \"\")) + \".ipxe\" }}"))
        (state "absent"))
      (loop (jinja "{{ ipxe__combined_scripts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name,
                \"state\": item.state | d(\"present\")} }}")))
      (when "item.name | d() and item.state | d('present') == 'absent'"))
    (task "Install bootloader files in the TFTP root directory"
      (ansible.builtin.copy 
        (src (jinja "{{ item }}"))
        (dest (jinja "{{ ipxe__tftp_root + \"/\" + (item | basename) }}"))
        (remote_src "True")
        (mode "0644"))
      (loop (jinja "{{ ipxe__bootloaders }}")))
    (task "Configure Debian netboot installers"
      (ansible.builtin.include_tasks "debian_netboot.yml")
      (when "ipxe__debian_netboot_enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save iPXE local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/ipxe.fact.j2")
        (dest "/etc/ansible/facts.d/ipxe.fact")
        (mode "0755"))
      (tags (list
          "meta::facts")))))
