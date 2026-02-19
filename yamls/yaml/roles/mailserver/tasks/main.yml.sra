(playbook "yaml/roles/mailserver/tasks/main.yml"
  (tasks
    (task
      (import_tasks "postfix.yml")
      (tags "postfix"))
    (task
      (import_tasks "dovecot.yml")
      (tags "dovecot"))
    (task
      (import_tasks "rspamd.yml")
      (tags "rspamd"))
    (task
      (import_tasks "solr.yml")
      (tags "solr"))
    (task
      (import_tasks "checkrbl.yml")
      (tags "checkrbl"))
    (task
      (import_tasks "z-push.yml")
      (tags "zpush"))
    (task
      (import_tasks "autoconfig.yml")
      (tags "autoconfig"))))
