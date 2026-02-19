(playbook "ansible-examples/language_features/ansible_pull.yml"
    (play
    (hosts "pull_mode_hosts")
    (remote_user "root")
    (vars
      (schedule "*/15 * * * *")
      (cron_user "root")
      (logfile "/var/log/ansible-pull.log")
      (workdir "/var/lib/ansible/local")
      (repo_url "SUPPLY_YOUR_OWN_GIT_URL_HERE"))
    (tasks
      (task "Install ansible"
        (yum "pkg=ansible state=installed"))
      (task "Create local directory to work from"
        (file "path=" (jinja "{{workdir}}") " state=directory owner=root group=root mode=0751"))
      (task "Copy ansible inventory file to client"
        (copy "src=/etc/ansible/hosts dest=/etc/ansible/hosts owner=root group=root mode=0644"))
      (task "Create crontab entry to clone/pull git repository"
        (template "src=templates/etc_cron.d_ansible-pull.j2 dest=/etc/cron.d/ansible-pull owner=root group=root mode=0644"))
      (task "Create logrotate entry for ansible-pull.log"
        (template "src=templates/etc_logrotate.d_ansible-pull.j2 dest=/etc/logrotate.d/ansible-pull owner=root group=root mode=0644")))))
