(playbook "debops/ansible/roles/postgresql_server/defaults/main.yml"
  (postgresql_server__upstream "False")
  (postgresql_server__upstream_key_id "B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8")
  (postgresql_server__upstream_apt_repo "deb http://apt.postgresql.org/pub/repos/apt " (jinja "{{ ansible_distribution_release }}") "-pgdg main")
  (postgresql_server__base_packages (list
      "postgresql"
      "postgresql-client"
      "postgresql-contrib"
      "pgtop"))
  (postgresql_server__python_packages (list))
  (postgresql_server__packages (list))
  (postgresql_server__preferred_version "")
  (postgresql_server__user "postgres")
  (postgresql_server__group "postgres")
  (postgresql_server__delegate_to (jinja "{{ inventory_hostname }}"))
  (postgresql_server__pgbadger_logs "False")
  (postgresql_server__listen_addresses (list
      "localhost"))
  (postgresql_server__allow (list))
  (postgresql_server__max_connections "100")
  (postgresql_server__admins (jinja "{{ [\"root\", \"*postgres*\"] +
                               ansible_local.core.admin_users | d([]) }}"))
  (postgresql_server__admin_password (jinja "{{ lookup('password', secret + '/credentials/' +
                                       inventory_hostname + '/postgresql/default/' +
                                       postgresql_server__user + '/password length=' +
                                       postgresql_server__password_length +
                                       ' chars=' + postgresql_server__password_characters) }}"))
  (postgresql_server__password_length "64")
  (postgresql_server__password_characters "ascii_letters,digits,.-_~&()*=")
  (postgresql_server__trusted (jinja "{{ ansible_local.core.admin_users | d([]) }}"))
  (postgresql_server__log_destination (jinja "{{ \"stderr\"
                                        if (postgresql_server__pgbadger_logs | bool)
                                        else \"syslog\" }}"))
  (postgresql_server__locale "en_US.UTF-8")
  (postgresql_server__locale_messages "C")
  (postgresql_server__timezone (jinja "{{ ansible_local.tzdata.timezone | d(\"Etc/UTC\") }}"))
  (postgresql_server__start_conf "auto")
  (postgresql_server__pki (jinja "{{ ansible_local.pki.enabled | d() | bool }}"))
  (postgresql_server__pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (postgresql_server__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (postgresql_server__pki_ca "CA.crt")
  (postgresql_server__pki_crt "default.crt")
  (postgresql_server__pki_key "default.key")
  (postgresql_server__pki_crl "default.crl")
  (postgresql_server__ssl_ciphers "ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH")
  (postgresql_server__shmmax_limiter "0.8")
  (postgresql_server__shm_memory_limiter "0.4")
  (postgresql_server__wal_level "minimal")
  (postgresql_server__archive_command "")
  (postgresql_server__hba_system (list
      
      (comment "Database superuser account, do not disable")
      (type "local")
      (database "all")
      (user "*postgres*")
      (method "peer")
      (options "map=system")
      
      (comment "Block remote connections to admin account")
      (type "host")
      (database "all")
      (user "*postgres*")
      (address "all")
      (method "reject")))
  (postgresql_server__hba_replication (list
      
      (comment "Remote replication connections")
      (type "hostssl")
      (database "replication")
      (user "replication")
      (address "samenet")
      (method "md5")))
  (postgresql_server__hba_public (list
      
      (comment "Allow public connections to postgres database")
      (type "local")
      (database "postgres")
      (user "all")
      (method "md5")
      
      (comment "Allow public connections to postgres database")
      (type "hostssl")
      (database "postgres")
      (user "all")
      (address "samenet")
      (method "md5")))
  (postgresql_server__hba_trusted (list
      
      (comment "Access through local UNIX socket")
      (type "local")
      (database "samerole")
      (user "@trusted")
      (method "peer")))
  (postgresql_server__hba_local (list
      
      (comment "Access through local UNIX socket with password")
      (type "local")
      (database "samerole")
      (user "all")
      (method "md5")
      
      (comment "Access from localhost over IPv6")
      (type "host")
      (database "samerole")
      (user "all")
      (address "::1/128")
      (method "md5")
      
      (comment "Access from localhost over IPv4")
      (type "host")
      (database "samerole")
      (user "all")
      (address "127.0.0.1/32")
      (method "md5")
      
      (comment "Access from localhost")
      (type "host")
      (database "samerole")
      (user "all")
      (address "localhost")
      (method "md5")))
  (postgresql_server__hba_remote (list
      
      (comment "Remote connections from local networks")
      (type "hostssl")
      (database "samerole")
      (user "all")
      (address "samenet")
      (method "md5")))
  (postgresql_server__ident_system (list
      
      (map "system")
      (user (jinja "{{ postgresql_server__admins }}"))
      (role "*postgres*")))
  (postgresql_server__ident_trusted (list))
  (postgresql_server__ident_local (list))
  (postgresql_server__data_directory "/var/lib/postgresql")
  (postgresql_server__log_directory "/var/log/postgresql")
  (postgresql_server__clusters (list
      (jinja "{{ postgresql_server__cluster_main }}")))
  (postgresql_server__cluster_main 
    (name "main")
    (port "5432"))
  (postgresql_server__autopostgresqlbackup (jinja "{{ False
                                             if (ansible_distribution_release in [\"bullseye\"])
                                             else True }}"))
  (postgresql_server__auto_backup "True")
  (postgresql_server__auto_backup_dir "/var/lib/autopostgresqlbackup")
  (postgresql_server__auto_backup_pg_opts "")
  (postgresql_server__auto_backup_pg_dump_opts "")
  (postgresql_server__auto_backup_extension "sql")
  (postgresql_server__auto_backup_mail "quiet")
  (postgresql_server__auto_backup_mail_size "4000")
  (postgresql_server__auto_backup_mail_to "backup@" (jinja "{{ ansible_domain }}"))
  (postgresql_server__auto_backup_create_database "True")
  (postgresql_server__auto_backup_isolate_databases "True")
  (postgresql_server__auto_backup_weekly "6")
  (postgresql_server__auto_backup_monthly "01")
  (postgresql_server__auto_backup_encryption "False")
  (postgresql_server__auto_backup_encryption_key "")
  (postgresql_server__auto_backup_encryption_cipher "aes256")
  (postgresql_server__auto_backup_encryption_suffix ".enc")
  (postgresql_server__auto_backup_compression "gzip")
  (postgresql_server__auto_backup_pre_script "")
  (postgresql_server__auto_backup_post_script "")
  (postgresql_server__auto_backup_permissions "0600")
  (postgresql_server__etc_services__dependent_list 
    (name "postgresql")
    (custom (jinja "{% for item in postgresql_server__clusters %}") "
" (jinja "{% if item.port is defined and item.port != \"5432\" %}") "
postgresql-" (jinja "{{ (item.port | int - 5430) }}") "    " (jinja "{{ item.port }}") "/tcp
" (jinja "{% endif %}") "
" (jinja "{% endfor %}") "
"))
  (postgresql_server__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ postgresql_server__upstream_key_id }}"))
      (repo (jinja "{{ postgresql_server__upstream_apt_repo }}"))
      (state (jinja "{{ \"present\" if postgresql_server__upstream | bool else \"absent\" }}"))))
  (postgresql_server__locales__dependent_list (list
      
      (name (jinja "{{ postgresql_server__locale }}"))
      (state "present")))
  (postgresql_server__ferm__dependent_rules 
    (type "custom")
    (by_role "debops.postgresql_server")
    (name "postgresql_custom_rules")
    (weight_class "default")
    (rules (jinja "{% set postgresql_server__tpl_ports = [] %}") "
" (jinja "{% for cluster in postgresql_server__clusters %}") "
" (jinja "{% set _ = postgresql_server__tpl_ports.append(cluster.port) %}") "
" (jinja "{% endfor %}") "
" (jinja "{% if postgresql_server__tpl_ports | d() and postgresql_server__allow | d() %}") "
domain $domains table filter chain INPUT {
    protocol tcp dport (" (jinja "{{ postgresql_server__tpl_ports | unique | join(\" \") }}") ") {
        @def $ITEMS = ( @ipfilter( (" (jinja "{{ postgresql_server__allow | unique | join(\" \") }}") ") ) );
        @if @ne($ITEMS,\"\") {
                saddr $ITEMS ACCEPT;
        }
    }
}

" (jinja "{% endif %}") "
" (jinja "{% for cluster in postgresql_server__clusters %}") "
" (jinja "{% if cluster.name | d() and cluster.port | d() and cluster.allow | d() %}") "
domain $domains table filter chain INPUT {
    protocol tcp dport (" (jinja "{{ cluster.port }}") ") {
        @def $ITEMS = ( @ipfilter( (" (jinja "{{ cluster.allow | unique | join(\" \") }}") ") ) );
        @if @ne($ITEMS,\"\") {
                saddr $ITEMS ACCEPT;
        }
    }
}
" (jinja "{% endif %}") "
" (jinja "{% endfor %}") "
"))
  (postgresql_server__python__dependent_packages3 (list
      "python3-psycopg2"))
  (postgresql_server__python__dependent_packages2 (list
      "python-psycopg2")))
