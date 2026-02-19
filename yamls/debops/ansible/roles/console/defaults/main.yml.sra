(playbook "debops/ansible/roles/console/defaults/main.yml"
  (console_serial "False")
  (console_serial_port "ttyS0")
  (console_serial_baud "115200")
  (console_serial_term "xterm")
  (console_serial_inittab "S0:2345:respawn:/sbin/getty -L " (jinja "{{ console_serial_port }}") " " (jinja "{{ console_serial_baud }}") " " (jinja "{{ console_serial_term }}"))
  (console_base_packages (list
      "locales"))
  (console_conditional_packages (list
      (list
        (jinja "{{ \"nfs-common\"
          if (console_mounts_nfs | d() or
              console_group_mounts_nfs | d() or
              console_host_mounts_nfs | d())
          else [] }}"))))
  (console_fsckfix "yes")
  (console_fsckfix_releases (list
      "trusty"
      "xenial")))
