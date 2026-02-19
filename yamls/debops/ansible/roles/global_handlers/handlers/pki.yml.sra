(playbook "debops/ansible/roles/global_handlers/handlers/pki.yml"
  (tasks
    (task "Update ca-certificates.crt"
      (ansible.builtin.command "update-ca-certificates")
      (register "global_handlers__pki_register_update_cacerts")
      (changed_when "global_handlers__pki_register_update_cacerts.changed | bool")
      (notify (list
          "Install ca-certificates.crt into Postfix chroot")))
    (task "Regenerate ca-certificates.crt"
      (ansible.builtin.command "update-ca-certificates --fresh")
      (register "global_handlers__pki_register_regenerate_cacerts")
      (changed_when "global_handlers__pki_register_regenerate_cacerts.changed | bool")
      (notify (list
          "Install ca-certificates.crt into Postfix chroot")))
    (task "Reconfigure ca-certificates"
      (ansible.builtin.command "dpkg-reconfigure --frontend=noninteractive ca-certificates")
      (environment 
        (DEBIAN_FRONTEND "noninteractive")
        (DEBCONF_NONINTERACTIVE_SEEN "true"))
      (register "global_handlers__pki_register_reconfigure_cacerts")
      (changed_when "global_handlers__pki_register_reconfigure_cacerts.changed | bool")
      (notify (list
          "Install ca-certificates.crt into Postfix chroot")))
    (task "Install ca-certificates.crt into Postfix chroot"
      (ansible.builtin.shell "test -d /var/spool/postfix && cp -f /etc/ssl/certs/ca-certificates.crt /var/spool/postfix/etc/ssl/certs/ca-certificates.crt || true")
      (register "global_handlers__pki_register_postfix_chroot")
      (changed_when "global_handlers__pki_register_postfix_chroot.changed | bool"))))
