(playbook "debops/ansible/roles/icinga_db/defaults/main.yml"
  (icinga_db__icinga_installed (jinja "{{ ansible_local.icinga.installed | d(False) | bool }}"))
  (icinga_db__type (jinja "{{ ansible_local.icinga_db.type
                     | d(\"postgresql\" if ansible_local.postgresql is defined else \"\", true)
                     | d(\"mariadb\" if ansible_local.mariadb is defined else \"\", true) }}"))
  (icinga_db__database_map 
    (postgresql 
      (ido "pgsql")
      (db_name "icinga2")
      (db_user "icinga2")
      (db_host (jinja "{{ ansible_local.postgresql.server | d(\"localhost\") }}"))
      (db_port (jinja "{{ ansible_local.postgresql.port | d(5432) }}"))
      (db_schema "/usr/share/icinga2-ido-pgsql/schema/pgsql.sql")
      (pw_path (jinja "{{ secret + \"/postgresql/\"
                   + ansible_local.postgresql.delegate_to | d(inventory_hostname)
                   + \"/\" + ansible_local.postgresql.port | d(\"5432\")
                   + \"/credentials/icinga2/password\" }}")))
    (mariadb 
      (ido "mysql")
      (db_name "icinga2")
      (db_user "icinga2")
      (db_host (jinja "{{ ansible_local.mariadb.server | d(\"localhost\") }}"))
      (db_port (jinja "{{ ansible_local.mariadb.port | d() }}"))
      (db_schema "/usr/share/icinga2-ido-mysql/schema/mysql.sql")
      (pw_path (jinja "{{ secret + \"/mariadb/\"
                   + ansible_local.mariadb.delegate_to | d(inventory_hostname)
                   + \"/credentials/icinga2/password\" }}"))))
  (icinga_db__ido (jinja "{{ icinga_db__database_map[icinga_db__type].ido }}"))
  (icinga_db__host (jinja "{{ icinga_db__database_map[icinga_db__type].db_host }}"))
  (icinga_db__port (jinja "{{ icinga_db__database_map[icinga_db__type].db_port }}"))
  (icinga_db__ssl (jinja "{{ False if icinga_db__host == \"localhost\"
                    else ansible_local.pki.enabled | d(False) | bool }}"))
  (icinga_db__user (jinja "{{ icinga_db__database_map[icinga_db__type].db_user }}"))
  (icinga_db__database (jinja "{{ icinga_db__database_map[icinga_db__type].db_name }}"))
  (icinga_db__password_path (jinja "{{ icinga_db__database_map[icinga_db__type].pw_path }}"))
  (icinga_db__password (jinja "{{ lookup('password', icinga_db__password_path
                                   + ' length=48 chars=ascii_letters,digits,.-_') }}"))
  (icinga_db__init (jinja "{{ not (ansible_local.icinga_db.configured | d(False) | bool) }}"))
  (icinga_db__schema (jinja "{{ icinga_db__database_map[icinga_db__type].db_schema }}"))
  (icinga_db__default_configuration (list
      
      (name "library")
      (raw "library \"db_ido_" (jinja "{{ icinga_db__ido }}") "\"")
      
      (name "connection")
      (option "object Ido" (jinja "{{ icinga_db__ido | capitalize }}") "Connection \"ido-" (jinja "{{ icinga_db__ido }}") "\"")
      (options (list
          
          (name "user")
          (value (jinja "{{ icinga_db__user }}"))
          
          (name "password")
          (value (jinja "{{ icinga_db__password }}"))
          
          (name "host")
          (value (jinja "{{ icinga_db__host }}"))
          
          (name "database")
          (value (jinja "{{ icinga_db__database }}"))
          
          (name "port")
          (value (jinja "{{ icinga_db__port | d(\"\") }}"))
          (state (jinja "{{ \"present\" if icinga_db__port | d() else \"ignore\" }}"))
          
          (name "ssl_mode")
          (value (jinja "{{ \"verify-full\" if icinga_db__ssl | d(False) | bool else \"disable\" }}"))
          (state (jinja "{{ \"present\" if icinga_db__type | d() == \"postgresql\" else \"ignore\" }}"))
          
          (name "enable_ssl")
          (value (jinja "{{ True if icinga_db__ssl | d(False) | bool else False }}"))
          (state (jinja "{{ \"present\" if icinga_db__type | d() == \"mariadb\" else \"ignore\" }}"))
          
          (name "ssl_ca")
          (value (jinja "{{ icinga_db__ssl_ca_certificate }}"))))))
  (icinga_db__configuration (list))
  (icinga_db__combined_configuration (jinja "{{ icinga_db__default_configuration
                                       + icinga_db__configuration }}"))
  (icinga_db__pki_path (jinja "{{ ansible_local.pki.base_path | d(\"/etc/pki/realms\") }}"))
  (icinga_db__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (icinga_db__pki_ca "CA.crt")
  (icinga_db__ssl_ca_certificate (jinja "{{ icinga_db__pki_path + \"/\"
                                   + icinga_db__pki_realm + \"/\"
                                   + icinga_db__pki_ca }}"))
  (icinga_db__base_packages (list
      "dbconfig-no-thanks"
      (jinja "{{ \"icinga2-ido-\" + icinga_db__ido }}")))
  (icinga_db__packages (list))
  (icinga_db__postgresql__dependent_roles (list
      
      (name (jinja "{{ icinga_db__user }}"))
      (password (jinja "{{ icinga_db__password }}"))
      (db (jinja "{{ icinga_db__database }}"))
      (priv (list
          "ALL"))))
  (icinga_db__postgresql__dependent_databases (list
      
      (name (jinja "{{ icinga_db__database }}"))
      (owner (jinja "{{ icinga_db__user }}"))))
  (icinga_db__mariadb__dependent_users (list
      
      (name (jinja "{{ icinga_db__user }}"))
      (password (jinja "{{ icinga_db__password }}"))
      (database (jinja "{{ icinga_db__database }}"))))
  (icinga_db__mariadb__dependent_databases (list
      
      (name (jinja "{{ icinga_db__database }}")))))
