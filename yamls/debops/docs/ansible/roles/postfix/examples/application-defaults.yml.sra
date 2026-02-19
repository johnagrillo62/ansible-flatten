(playbook "debops/docs/ansible/roles/postfix/examples/application-defaults.yml"
  (application__postfix__dependent_packages (list
      "postfix-pgsql"))
  (application__postfix__dependent_maincf (list
      
      (name "application_destination_recipient_limit")
      (value "1")))
  (application__postfix__dependent_mastercf (list
      
      (name "application")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      (command "pipe")
      (args "flags=FR user=application argv=/usr/local/lib/application/bin/in-pipe
${nexthop} ${user}"))))
