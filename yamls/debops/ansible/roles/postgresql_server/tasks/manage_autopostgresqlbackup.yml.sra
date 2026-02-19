(playbook "debops/ansible/roles/postgresql_server/tasks/manage_autopostgresqlbackup.yml"
  (tasks
    (task "Divert the original autopostgresqlbackup script"
      (debops.debops.dpkg_divert 
        (path "/usr/sbin/autopostgresqlbackup")
        (divert "/usr/share/doc/autopostgresqlbackup/script.dpkg-divert")))
    (task "Divert the original autopostgresqlbackup cron job"
      (debops.debops.dpkg_divert 
        (path "/etc/cron.daily/autopostgresqlbackup")
        (divert "/usr/share/doc/autopostgresqlbackup/cron.dpkg-divert")))
    (task "Configure autopostgresqlbackup defaults"
      (ansible.builtin.template 
        (src "etc/default/autopostgresqlbackup.j2")
        (dest "/etc/default/autopostgresqlbackup-" (jinja "{{ item.version | d(postgresql_server__version) }}") "-" (jinja "{{ item.name }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}")))
    (task "Configure autopostgresqlbackup"
      (ansible.builtin.template 
        (src "usr/sbin/autopostgresqlbackup.j2")
        (dest "/usr/sbin/autopostgresqlbackup-" (jinja "{{ item.version | d(postgresql_server__version) }}") "-" (jinja "{{ item.name }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}")))
    (task "Disable autopostgresqlbackup from running daily"
      (ansible.builtin.file 
        (path "/etc/cron.daily/autopostgresqlbackup-" (jinja "{{ (item.version | d(postgresql_server__version))
                                                   | replace(\".\", \"_\") }}") "-" (jinja "{{ item.name }}"))
        (state "absent"))
      (when "((item.auto_backup | d() and not item.auto_backup | bool) or not postgresql_server__auto_backup | bool)")
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}")))
    (task "Enable autopostgresqlbackup to run daily"
      (ansible.builtin.template 
        (src "etc/cron.daily/autopostgresqlbackup.j2")
        (dest "/etc/cron.daily/autopostgresqlbackup-" (jinja "{{ (item.version | d(postgresql_server__version))
                                                   | replace(\".\", \"_\") }}") "-" (jinja "{{ item.name }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "((item.auto_backup is undefined or item.auto_backup | bool) and postgresql_server__auto_backup | bool)")
      (loop (jinja "{{ q(\"flattened\", postgresql_server__clusters) }}")))))
