(playbook "debops/ansible/roles/dropbear_initramfs/tasks/main.yml"
  (tasks
    (task "Ensure specified packages are in there desired state"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (dropbear_initramfs__base_packages
                              + dropbear_initramfs__packages)) }}"))
        (state (jinja "{{ \"present\" if (dropbear_initramfs__deploy_state == \"present\") else \"absent\" }}")))
      (register "dropbear_initramfs__register_packages")
      (until "dropbear_initramfs__register_packages is succeeded")
      (tags (list
          "role::dropbear_initramfs:pkgs")))
    (task "Configure network in initramfs using kernel command line"
      (ansible.builtin.template 
        (src "etc/initramfs-tools/conf.d/role.conf.j2")
        (dest "/etc/initramfs-tools/conf.d/50_debops.dropbear_initramfs.conf")
        (mode "0644"))
      (when "(dropbear_initramfs__deploy_state == \"present\")")
      (notify (list
          "Update initramfs")))
    (task "Configure dropbear options"
      (ansible.builtin.template 
        (src "etc/dropbear/initramfs/dropbear.conf.j2")
        (dest (jinja "{{ dropbear_initramfs__config_file }}"))
        (mode "0644"))
      (when "(dropbear_initramfs__deploy_state == \"present\")")
      (notify (list
          "Update initramfs")))
    (task "Configure to bring up additional interfaces/addresses in initramfs"
      (ansible.builtin.template 
        (src "etc/initramfs-tools/scripts/local-top/debops_dropbear_initramfs.j2")
        (dest "/etc/initramfs-tools/scripts/local-top/debops_dropbear_initramfs")
        (mode "0755"))
      (when "(dropbear_initramfs__deploy_state == \"present\")")
      (notify (list
          "Update initramfs")))
    (task "Configure to bring down additional interfaces/addresses in initramfs"
      (ansible.builtin.template 
        (src "etc/initramfs-tools/scripts/local-bottom/debops_dropbear_initramfs.j2")
        (dest "/etc/initramfs-tools/scripts/local-bottom/debops_dropbear_initramfs")
        (mode "0755"))
      (when "(dropbear_initramfs__deploy_state == \"present\")")
      (notify (list
          "Update initramfs")))
    (task "Configure authorized ssh keys"
      (ansible.posix.authorized_key 
        (key (jinja "{{ (item.key
              if item.key is string
              else (item.key | unique | join('\\n') | string))
             if item.key | d() else '' }}"))
        (user (jinja "{{ item.user | d(\"root\") }}"))
        (path (jinja "{{ \"/etc/initramfs-tools/root/.ssh/authorized_keys\"
              if (\"dropbear\" in dropbear_initramfs__base_packages)
              else dropbear_initramfs__config_path + \"/authorized_keys\" }}"))
        (key_options (jinja "{{ (item.key_options if item.key_options is string else item.key_options | join(\",\"))
                       if item.key_options is defined
                       else ((dropbear_initramfs__authorized_keys_key_options
                              if dropbear_initramfs__authorized_keys_key_options is string
                              else dropbear_initramfs__authorized_keys_key_options | join(\",\"))
                             if dropbear_initramfs__authorized_keys_key_options != omit else \"\")
                     }}"))
        (state (jinja "{{ (item.state | d(\"present\")) if (dropbear_initramfs__deploy_state == \"present\") else \"absent\" }}"))
        (exclusive (jinja "{{ item.exclusive | d(omit) }}"))
        (comment (jinja "{{ item.comment | d(omit) }}"))
        (manage_dir "False"))
      (notify (list
          "Update initramfs"))
      (loop (jinja "{{ q(\"flattened\", dropbear_initramfs__combined_authorized_keys) }}"))
      (loop_control 
        (label (jinja "{{ {\"key\": item.key} }}"))))
    (task "Remove files in deploy state absent"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (when "(dropbear_initramfs__deploy_state == 'absent')")
      (notify (list
          "Update initramfs"))
      (with_items (list
          "/etc/initramfs-tools/conf.d/50_debops.dropbear_initramfs.conf"
          "/etc/initramfs-tools/scripts/local-top/debops_dropbear_initramfs"
          "/etc/initramfs-tools/scripts/local-bottom/debops_dropbear_initramfs")))))
