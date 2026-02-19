(playbook "yaml/roles/mailserver/tasks/rspamd.yml"
  (tasks
    (task "Ensure repository key for Rspamd is in place"
      (apt_key "url=https://rspamd.com/apt-stable/gpg.key state=present")
      (when "ansible_architecture != \"armv7l\"")
      (tags (list
          "dependencies")))
    (task "Ensure yunohost repository key for Rspamd is in place for ARM"
      (apt_key "url=http://repo.yunohost.org/debian/yunohost.asc state=present")
      (when "ansible_architecture == \"armv7l\"")
      (tags (list
          "dependencies")))
    (task "Add Rspamd repository"
      (apt_repository "repo=\"deb https://rspamd.com/apt-stable/ " (jinja "{{ ansible_distribution_release }}") " main\"")
      (when "ansible_architecture != \"armv7l\"")
      (tags (list
          "dependencies")))
    (task "Add yunohost Rspamd repository for ARM"
      (apt_repository "repo=\"deb http://repo.yunohost.org/debian " (jinja "{{ ansible_distribution_release }}") " stable\"")
      (when "ansible_architecture == \"armv7l\"")
      (tags (list
          "dependencies")))
    (task "Install Rspamd and Redis"
      (apt "pkg=" (jinja "{{ item }}") " state=present update_cache=yes")
      (with_items (list
          "rspamd"
          "redis-server"))
      (tags (list
          "dependencies")))
    (task "Copy DMARC configuration into place"
      (template "src=etc_rspamd_local.d_dmarc.conf.j2 dest=/etc/rspamd/local.d/dmarc.conf owner=root group=root mode=\"0644\"")
      (notify "restart rspamd"))
    (task "Configure Rspamd to use Redis"
      (copy "src=etc_rspamd_local.d_redis.conf dest=/etc/rspamd/local.d/redis.conf owner=root group=root mode=\"0644\"")
      (notify "restart rspamd"))
    (task "Copy DKIM configuration into place"
      (copy "src=etc_rspamd_override.d_dkim_signing.conf dest=/etc/rspamd/override.d/dkim_signing.conf owner=root group=root mode=\"0644\"")
      (notify "restart rspamd"))
    (task "Create dkim key directory"
      (file "path=/var/lib/rspamd/dkim state=directory owner=_rspamd group=_rspamd"))
    (task "Generate DKIM keys"
      (shell "rspamadm dkim_keygen -s default -d " (jinja "{{ item.name }}") " -k " (jinja "{{ item.name }}") ".default.key > " (jinja "{{ item.name }}") ".default.txt")
      (args 
        (creates "/var/lib/rspamd/dkim/" (jinja "{{ item.name }}") ".default.key")
        (chdir "/var/lib/rspamd/dkim/"))
      (with_items (jinja "{{ mail_virtual_domains }}")))
    (task "Start redis"
      (service "name=redis-server state=started"))))
