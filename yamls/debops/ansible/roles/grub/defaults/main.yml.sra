(playbook "debops/ansible/roles/grub/defaults/main.yml"
  (grub__original_configuration (list
      
      (name "default")
      (value "0")
      (quote "False")
      
      (name "hidden_timeout")
      (value "0")
      (state (jinja "{{ \"present\" if (ansible_distribution == \"Ubuntu\") else \"ignore\" }}"))
      
      (name "hidden_timeout_quiet")
      (value "True")
      (state (jinja "{{ \"present\" if (ansible_distribution == \"Ubuntu\") else \"ignore\" }}"))
      
      (name "timeout")
      (value "5")
      (quote "False")
      
      (name "distributor")
      (value "`lsb_release -i -s 2> /dev/null || echo Debian`")
      (quote "False")
      
      (name "cmdline_linux_default")
      (value (list))
      (original "True")
      
      (name "cmdline_linux")
      (value (list))
      (original "True")
      
      (name "badram")
      (comment "Uncomment to enable BadRAM filtering, modify to suit your needs
This works with Linux (no patch required) and with any kernel that obtains
the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
")
      (value "0x01234567,0xfefefefe,0x89abcdef,0xefefefef")
      (state "comment")
      
      (name "terminal")
      (comment "Uncomment to disable graphical terminal (grub-pc only)")
      (value "console")
      (state "comment")
      (quote "False")
      
      (name "gfxmode")
      (comment "The resolution used on graphical terminal
note that you can use only modes which your graphic card supports via VBE
you can see them in real GRUB with the command `vbeinfo'
")
      (value "640x480")
      (state "comment")
      (quote "False")
      
      (name "disable_linux_uuid")
      (comment "Uncomment if you don't want GRUB to pass \"root=UUID=xxx\" parameter to Linux")
      (value "True")
      (state "comment")
      (quote "False")
      
      (name "disable_recovery")
      (comment "Uncomment to disable generation of recovery mode menu entries")
      (value "True")
      (state "comment")
      
      (name "init_tune")
      (comment "Uncomment to get a beep at grub start")
      (value "480 440 1")
      (state "comment")))
  (grub__fact_configuration (list
      
      (name "default")
      (value (jinja "{{ ansible_local.grub.default | d(\"0\") }}"))
      
      (name "cmdline_linux_default")
      (value (jinja "{{ ansible_local.grub.cmdline_default | d([]) }}"))
      
      (name "cmdline_linux")
      (value (jinja "{{ ansible_local.grub.cmdline | d([]) }}"))))
  (grub__default_configuration (list
      
      (name "timeout")
      (value (jinja "{{ grub__timeout_hardware
               if (ansible_virtualization_role is undefined or
                   ansible_virtualization_role not in [\"guest\"])
               else grub__timeout_virtual }}"))
      
      (name "cmdline_linux_default")
      (value (list
          "cgroup_enable=memory"
          "swapaccount=1"))
      
      (name "cmdline_linux_default")
      (value (list
          "elevator=noop"))
      (state (jinja "{{ \"present\" if (ansible_virtualization_role | d() == \"guest\") else \"ignore\" }}"))
      
      (name "terminal")
      (comment "Uncomment to disable graphical terminal (grub-pc only)")
      (value "console serial")
      (quote "True")
      (state (jinja "{{ \"present\" if grub__serial_console | bool else \"ignore\" }}"))
      
      (name "serial_command")
      (value "serial --unit=" (jinja "{{ grub__serial_console_unit }}") " --speed=" (jinja "{{ grub__serial_console_speed }}") " --word=8 --parity=no --stop=1")
      (state (jinja "{{ \"present\" if grub__serial_console | bool else \"ignore\" }}"))
      
      (name "cmdline_linux_default")
      (value (list
          (jinja "{{ \"console=ttyS{},{}n8\".format(grub__serial_console_unit, grub__serial_console_speed) }}")
          "console=tty0"))
      (state (jinja "{{ \"present\" if grub__serial_console | bool else \"ignore\" }}"))
      
      (name "linux_menuentry_class_additional")
      (comment "Needs to be exported until it is patched upstream.
FIXME: Remove `export` when patched upstream has reached Debian stable.
Currently unlikely because the patch was not accepted upstream.
")
      (value (jinja "{{ grub__menuentry_access }}"))
      (state (jinja "{{ \"present\"
               if (grub__combined_users | length > 0 and
                   grub__menuentry_access is string)
               else \"absent\" }}"))
      (export "True")))
  (grub__configuration (list))
  (grub__group_configuration (list))
  (grub__host_configuration (list))
  (grub__dependent_configuration (list))
  (grub__combined_configuration (jinja "{{ grub__original_configuration
                                  + grub__fact_configuration
                                  + grub__default_configuration
                                  + lookup(\"flattened\",
                                           grub__dependent_configuration,
                                           wantlist=True)
                                  + grub__configuration
                                  + grub__group_configuration
                                  + grub__host_configuration }}"))
  (grub__serial_console "True")
  (grub__serial_console_unit "0")
  (grub__serial_console_speed "115200")
  (grub__timeout_hardware "5")
  (grub__timeout_virtual "1")
  (grub__users (list))
  (grub__group_users (list))
  (grub__host_users (list))
  (grub__combined_users (jinja "{{ grub__users + grub__group_users + grub__host_users }}"))
  (grub__menuentry_access "--unrestricted")
  (grub__iter_time "default")
  (grub__salt_length "default")
  (grub__hash_length "default"))
