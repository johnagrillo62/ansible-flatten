(playbook "debops/ansible/roles/postgresql_server/tasks/secure_installation.yml"
  (tasks
    (task "Update default admin password"
      (community.postgresql.postgresql_user 
        (name (jinja "{{ item.user | d(postgresql_server__user) }}"))
        (password (jinja "{{ item.admin_password | d(postgresql_server__admin_password) }}"))
        (encrypted "True")
        (port (jinja "{{ item.port }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (become "True")
      (become_user (jinja "{{ item.user | d(postgresql_server__user) }}"))
      (when (list
          "item.name | d()"
          "item.standby is not defined"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Grant connect on postgres to PUBLIC"
      (community.postgresql.postgresql_privs 
        (database "postgres")
        (port (jinja "{{ item.port }}"))
        (role "PUBLIC")
        (type "database")
        (privs "CONNECT")
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (become "True")
      (become_user (jinja "{{ item.user | d(postgresql_server__user) }}"))
      (when (list
          "item.name | d()"
          "item.standby is not defined"))
      (changed_when "False"))
    (task "Revoke temporary on postgres from PUBLIC"
      (community.postgresql.postgresql_privs 
        (database "postgres")
        (port (jinja "{{ item.port }}"))
        (role "PUBLIC")
        (type "database")
        (privs "TEMPORARY")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}"))
      (become "True")
      (become_user (jinja "{{ item.user | d(postgresql_server__user) }}"))
      (when (list
          "item.name | d()"
          "item.standby is not defined"))
      (changed_when "False"))))
