(playbook "debops/ansible/roles/console/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install requested packages"
      (ansible.builtin.apt 
        (name (jinja "{{ (console_base_packages + console_conditional_packages) | flatten }}"))
        (state "present")
        (install_recommends "False"))
      (register "console__register_packages")
      (until "console__register_packages is succeeded")
      (when "item is defined and item")
      (tags (list
          "meta::provision")))
    (task "Check if /etc/inittab exists"
      (ansible.builtin.stat 
        (path "/etc/inittab"))
      (register "console_register_inittab"))
    (task "Disable serial console in /etc/inittab"
      (ansible.builtin.lineinfile 
        (dest "/etc/inittab")
        (regexp "^" (jinja "{{ console_serial_inittab }}"))
        (state "absent"))
      (when "((console_serial is undefined or (console_serial is defined and not console_serial)) and ((console_register_inittab is defined and console_register_inittab) and console_register_inittab.stat.exists))")
      (notify (list
          "Reload sysvinit")))
    (task "Enable serial console in /etc/inittab"
      (ansible.builtin.lineinfile 
        (dest "/etc/inittab")
        (regexp "^" (jinja "{{ console_serial_inittab }}"))
        (state "present")
        (line (jinja "{{ console_serial_inittab }}"))
        (mode "0644"))
      (when "((console_serial is defined and console_serial) and ((console_register_inittab is defined and console_register_inittab) and console_register_inittab.stat.exists))")
      (notify (list
          "Reload sysvinit")))
    (task "Configure fsck behaviour on boot"
      (ansible.builtin.lineinfile 
        (dest "/etc/default/rcS")
        (regexp "FSCKFIX=")
        (state "present")
        (line "FSCKFIX=" (jinja "{{ console_fsckfix }}"))
        (mode "0644"))
      (when "ansible_distribution_release in console_fsckfix_releases"))))
