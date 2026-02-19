(playbook "debops/ansible/playbooks/layer/app.yml"
  (tasks
    (task "Configure SKS Keyserver service"
      (import_playbook "../service/sks.yml"))
    (task "Configure iPXE service"
      (import_playbook "../service/ipxe.yml"))
    (task "Configure backup2l service"
      (import_playbook "../service/backup2l.yml"))
    (task "Configure rsnapshot service"
      (import_playbook "../service/rsnapshot.yml"))
    (task "Configure Mailman service"
      (import_playbook "../service/mailman.yml"))
    (task "Configure Miniflux service"
      (import_playbook "../service/miniflux.yml"))
    (task "Configure LibreNMS application"
      (import_playbook "../service/librenms.yml"))
    (task "Configure DokuWiki application"
      (import_playbook "../service/dokuwiki.yml"))
    (task "Configure NetBox application"
      (import_playbook "../service/netbox.yml"))
    (task "Configure Etherpad application"
      (import_playbook "../service/etherpad.yml"))
    (task "Configure Debian Preseed service"
      (import_playbook "../service/preseed.yml"))
    (task "Configure pgBadger service"
      (import_playbook "../service/pgbadger.yml"))
    (task "Configure ownCloud/Nextcloud application"
      (import_playbook "../service/owncloud.yml"))
    (task "Configure phpMyAdmin application"
      (import_playbook "../service/phpmyadmin.yml"))
    (task "Configure phpIPAM application"
      (import_playbook "../service/phpipam.yml"))
    (task "Configure RStudio Server service"
      (import_playbook "../service/rstudio_server.yml"))
    (task "Configure GitLab Omnibus application"
      (import_playbook "../service/gitlab.yml"))
    (task "Configure Ansible tool"
      (import_playbook "../service/ansible.yml"))
    (task "Configure Ansible Controller environment"
      (import_playbook "../service/controller.yml"))
    (task "Configure Roundcube application"
      (import_playbook "../service/roundcube.yml"))
    (task "Configure IMAP Proxy service"
      (import_playbook "../service/imapproxy.yml"))
    (task "Configure Debconf-based application packages"
      (import_playbook "../service/debconf.yml"))))
