(playbook "debops/ansible/roles/icinga_web/defaults/main.yml"
  (icinga_web__base_packages (list
      "icingaweb2"
      "icingaweb2-module-doc"
      "icingaweb2-module-monitoring"
      "icingacli"))
  (icinga_web__packages (list))
  (icinga_web__user "www-data")
  (icinga_web__group "icingaweb2")
  (icinga_web__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                     + \"/icinga_web\" }}"))
  (icinga_web__fqdn "icinga." (jinja "{{ icinga_web__domain }}"))
  (icinga_web__domain (jinja "{{ ansible_domain }}"))
  (icinga_web__node_fqdn (jinja "{{ ansible_fqdn }}"))
  (icinga_web__default_modules (list
      
      (name "toplevelview")
      (git_repo "https://github.com/Icinga/icingaweb2-module-toplevelview")
      (git_version "v0.3.3")
      (state "present")
      
      (name "monitoring")
      (state "present")
      
      (name "businessprocess")
      (git_repo "https://github.com/Icinga/icingaweb2-module-businessprocess")
      (git_version "v2.3.1")
      (state "present")
      
      (name "graphite")
      (git_repo "https://github.com/Icinga/icingaweb2-module-graphite")
      (git_version "v1.1.0")
      (enabled "False")
      (state "present")
      
      (name "director")
      (git_repo "https://github.com/Icinga/icingaweb2-module-director")
      (git_version "v1.8.1")
      (state (jinja "{{ \"present\" if icinga_web__director_enabled | bool else \"ignore\" }}"))
      
      (name "generictts")
      (git_repo "https://github.com/Icinga/icingaweb2-module-generictts")
      (git_version "v2.0.0")
      (state "present")
      
      (name "grafana")
      (git_repo "https://github.com/Mikesch-mp/icingaweb2-module-grafana")
      (git_version "v1.4.2")
      (state "present")
      
      (name "map")
      (git_repo "https://github.com/nbuchwitz/icingaweb2-module-map")
      (git_version "v1.1.0")
      (state "present")
      
      (name "pnp")
      (git_repo "https://github.com/Icinga/icingaweb2-module-pnp")
      (git_version "v1.1.0")
      (enabled "False")
      (state "present")
      
      (name "elasticsearch")
      (git_repo "https://github.com/Icinga/icingaweb2-module-elasticsearch")
      (git_version "v0.9.0")
      (state "present")
      
      (name "cube")
      (git_repo "https://github.com/Icinga/icingaweb2-module-cube")
      (git_version "v1.1.1")
      (state "present")
      
      (name "netboximport")
      (git_repo "https://github.com/Uberspace/icingaweb2-module-netboximport")
      (git_version "master")
      (state "present")
      
      (name "doc")
      (state "present")
      
      (name "ipl")
      (git_repo "https://github.com/Icinga/icingaweb2-module-ipl")
      (git_version "v0.5.0")
      (state "present")
      
      (name "reactbundle")
      (git_repo "https://github.com/Icinga/icingaweb2-module-reactbundle")
      (git_version "v0.9.0")
      (state "present")
      
      (name "incubator")
      (git_repo "https://github.com/Icinga/icingaweb2-module-incubator")
      (git_version "v0.6.0")
      (state "present")
      
      (name "x509")
      (git_repo "https://github.com/icinga/icingaweb2-module-x509")
      (git_version "v1.0.0")
      (state (jinja "{{ \"present\" if icinga_web__x509_enabled | bool else \"ignore\" }}"))))
  (icinga_web__modules (list))
  (icinga_web__database_type (jinja "{{ ansible_local.icinga_web.database_type
                               | d(ansible_local.icinga_db.type | d(\"\"), true)
                               | d(\"postgresql\" if ansible_local.postgresql is defined else \"\", true)
                               | d(\"mariadb\" if ansible_local.mariadb is defined else \"\", true) }}"))
  (icinga_web__database_map 
    (postgresql 
      (ido "pgsql")
      (db_name "icingaweb2_production")
      (db_user "icingaweb2")
      (db_host (jinja "{{ ansible_local.postgresql.server | d(\"localhost\") }}"))
      (db_port (jinja "{{ ansible_local.postgresql.port | d(5432) }}"))
      (db_schema "/usr/share/icingaweb2/etc/schema/pgsql.schema.sql")
      (pw_path (jinja "{{ secret + \"/postgresql/\"
                 + ansible_local.postgresql.delegate_to | d(inventory_hostname)
                 + \"/\" + ansible_local.postgresql.port | d(\"5432\")
                 + \"/credentials/icingaweb2/password\" }}")))
    (mariadb 
      (ido "mysql")
      (db_name "icingaweb2")
      (db_user "icingaweb2")
      (db_host (jinja "{{ ansible_local.mariadb.server | d(\"localhost\") }}"))
      (db_port (jinja "{{ ansible_local.mariadb.port | d(3306) }}"))
      (db_schema "/usr/share/icingaweb2/etc/schema/mysql.schema.sql")
      (pw_path (jinja "{{ secret + \"/mariadb/\"
                 + ansible_local.mariadb.delegate_to | d(inventory_hostname)
                 + \"/credentials/icingaweb2/password\" }}"))))
  (icinga_web__database_name (jinja "{{ icinga_web__database_map[icinga_web__database_type].db_name }}"))
  (icinga_web__database_user (jinja "{{ icinga_web__database_map[icinga_web__database_type].db_user }}"))
  (icinga_web__database_password_path (jinja "{{ icinga_web__database_map[icinga_web__database_type].pw_path }}"))
  (icinga_web__database_password (jinja "{{ lookup('password', icinga_web__database_password_path
                                   + ' length=48 chars=ascii_letters,digits,.-_') }}"))
  (icinga_web__database_host (jinja "{{ icinga_web__database_map[icinga_web__database_type].db_host }}"))
  (icinga_web__database_port (jinja "{{ icinga_web__database_map[icinga_web__database_type].db_port }}"))
  (icinga_web__database_ssl (jinja "{{ False if icinga_web__database_host == \"localhost\"
                              else ansible_local.pki.enabled | d(False) | bool }}"))
  (icinga_web__database_schema (jinja "{{ icinga_web__database_map[icinga_web__database_type].db_schema }}"))
  (icinga_web__database_init (jinja "{{ not (ansible_local.icinga_web.installed | d(False) | bool) }}"))
  (icinga_web__master_database_enabled (jinja "{{ ansible_local.icinga_db.configured | d(False) | bool }}"))
  (icinga_web__master_database_type (jinja "{{ ansible_local.icinga_db.type | d(\"\") }}"))
  (icinga_web__master_database_ido (jinja "{{ ansible_local.icinga_db.ido | d(\"\") }}"))
  (icinga_web__master_database_name (jinja "{{ ansible_local.icinga_db.db_name | d(\"icinga2\") }}"))
  (icinga_web__master_database_user (jinja "{{ ansible_local.icinga_db.db_user | d(\"icinga2\") }}"))
  (icinga_web__master_database_password (jinja "{{ ansible_local.icinga_db.db_password | d(\"\") }}"))
  (icinga_web__master_database_host (jinja "{{ ansible_local.icinga_db.db_host | d(\"localhost\") }}"))
  (icinga_web__master_database_port (jinja "{{ ansible_local.icinga_db.db_port | d(\"\") }}"))
  (icinga_web__master_database_ssl (jinja "{{ ansible_local.icinga_db.db_ssl | d(False) }}"))
  (icinga_web__director_enabled "True")
  (icinga_web__director_user "icingadirector")
  (icinga_web__director_group (jinja "{{ icinga_web__group }}"))
  (icinga_web__director_home "/var/local/" (jinja "{{ icinga_web__director_user }}"))
  (icinga_web__director_home_mode "0755")
  (icinga_web__director_shell "/usr/sbin/nologin")
  (icinga_web__director_api_fqdn (jinja "{{ icinga_web__fqdn }}"))
  (icinga_web__director_api_url "https://" (jinja "{{ icinga_web__director_api_fqdn }}") "/director")
  (icinga_web__director_api_user "director-api")
  (icinga_web__director_api_password (jinja "{{ lookup(\"password\", secret + \"/icinga_web/api/\"
                                       + icinga_web__director_api_fqdn + \"/credentials/\"
                                       + icinga_web__director_api_user + \"/password\") }}"))
  (icinga_web__director_database_type (jinja "{{ icinga_web__database_type | d(\"invalid\") }}"))
  (icinga_web__director_database_map 
    (postgresql 
      (ido "pgsql")
      (db_name "icinga2_director_production")
      (db_user "icinga2_director")
      (db_host (jinja "{{ ansible_local.postgresql.server | d(\"localhost\") }}"))
      (db_port (jinja "{{ ansible_local.postgresql.port | d(5432) }}"))
      (pw_path (jinja "{{ secret + \"/postgresql/\"
                 + ansible_local.postgresql.delegate_to | d(inventory_hostname)
                 + \"/\" + ansible_local.postgresql.port | d(\"5432\")
                 + \"/credentials/icinga2_director/password\" }}")))
    (mariadb 
      (ido "mysql")
      (db_name "icinga2_director")
      (db_user "icinga2_director")
      (db_host (jinja "{{ ansible_local.mariadb.server | d(\"localhost\") }}"))
      (db_port (jinja "{{ ansible_local.mariadb.port | d() }}"))
      (pw_path (jinja "{{ secret + \"/mariadb/\"
                 + ansible_local.mariadb.delegate_to | d(inventory_hostname)
                 + \"/credentials/icinga2_director/password\" }}"))))
  (icinga_web__director_database_name (jinja "{{ icinga_web__director_database_map[icinga_web__director_database_type].db_name }}"))
  (icinga_web__director_database_user (jinja "{{ icinga_web__director_database_map[icinga_web__director_database_type].db_user }}"))
  (icinga_web__director_database_password_path (jinja "{{ icinga_web__director_database_map[icinga_web__director_database_type].pw_path }}"))
  (icinga_web__director_database_password (jinja "{{ lookup('password', icinga_web__director_database_password_path
                                            + ' length=48 chars=ascii_letters,digits,.-_') }}"))
  (icinga_web__director_database_host (jinja "{{ icinga_web__director_database_map[icinga_web__director_database_type].db_host }}"))
  (icinga_web__director_database_port (jinja "{{ icinga_web__director_database_map[icinga_web__director_database_type].db_port }}"))
  (icinga_web__director_database_ssl (jinja "{{ False if icinga_web__director_database_host == \"localhost\"
                                       else ansible_local.pki.enabled | d(False) | bool }}"))
  (icinga_web__director_database_init (jinja "{{ not (ansible_local.icinga_web.installed | d(False) | bool) }}"))
  (icinga_web__director_kickstart_enabled (jinja "{{ ansible_local.icinga.installed | d(False) | bool }}"))
  (icinga_web__director_default_templates (list
      
      (name "generic-host")
      (api_endpoint "/host")
      (data 
        (object_type "template")
        (object_name "generic-host")
        (check_command "hostalive")
        (check_interval "5m")
        (retry_interval "30s")
        (max_check_attempts "5"))
      (state "present")
      
      (name "icinga-agent-host")
      (api_endpoint "/host")
      (data 
        (object_type "template")
        (object_name "icinga-agent-host")
        (has_agent "true")
        (master_should_connect "true")
        (accept_config "true")
        (imports (list
            "generic-host")))
      (state "present")))
  (icinga_web__director_templates (list))
  (icinga_web__director_group_templates (list))
  (icinga_web__director_host_templates (list))
  (icinga_web__director_combined_templates (jinja "{{ icinga_web__director_default_templates
                                             + icinga_web__director_templates
                                             + icinga_web__director_group_templates
                                             + icinga_web__director_host_templates }}"))
  (icinga_web__x509_enabled (jinja "{{ icinga_web__director_database_type == \"mariadb\"
                              and ansible_local.mariadb is defined }}"))
  (icinga_web__x509_database_type (jinja "{{ icinga_web__database_type | d(\"invalid\") }}"))
  (icinga_web__x509_database_map 
    (postgresql 
      (ido "pgsql")
      (db_name "icingaweb2_x509")
      (db_user "icingaweb2_x509")
      (db_host (jinja "{{ ansible_local.postgresql.server | d(\"localhost\") }}"))
      (db_port (jinja "{{ ansible_local.postgresql.port | d(5432) }}"))
      (db_schema "/usr/share/icingaweb2/modules/x509/etc/schema/pgsql.schema.sql")
      (pw_path (jinja "{{ secret + \"/postgresql/\"
                 + ansible_local.postgresql.delegate_to | d(inventory_hostname)
                 + \"/\" + ansible_local.postgresql.port | d(\"5432\")
                 + \"/credentials/icingaweb2_x509/password\" }}")))
    (mariadb 
      (ido "mysql")
      (db_name "icingaweb2_x509")
      (db_user "icingaweb2_x509")
      (db_host (jinja "{{ ansible_local.mariadb.server | d(\"localhost\") }}"))
      (db_port (jinja "{{ ansible_local.mariadb.port | d(3306) }}"))
      (db_schema "/usr/share/icingaweb2/modules/x509/etc/schema/mysql.schema.sql")
      (pw_path (jinja "{{ secret + \"/mariadb/\"
                 + ansible_local.mariadb.delegate_to | d(inventory_hostname)
                 + \"/credentials/icingaweb2_x509/password\" }}"))))
  (icinga_web__x509_database_name (jinja "{{ icinga_web__x509_database_map[icinga_web__x509_database_type].db_name }}"))
  (icinga_web__x509_database_user (jinja "{{ icinga_web__x509_database_map[icinga_web__x509_database_type].db_user }}"))
  (icinga_web__x509_database_password_path (jinja "{{ icinga_web__x509_database_map[icinga_web__x509_database_type].pw_path }}"))
  (icinga_web__x509_database_password (jinja "{{ lookup(\"password\", icinga_web__x509_database_password_path
                                        + \" length=48 chars=ascii_letters,digits,.-_\") }}"))
  (icinga_web__x509_database_host (jinja "{{ icinga_web__x509_database_map[icinga_web__x509_database_type].db_host }}"))
  (icinga_web__x509_database_port (jinja "{{ icinga_web__x509_database_map[icinga_web__x509_database_type].db_port }}"))
  (icinga_web__x509_database_schema (jinja "{{ icinga_web__x509_database_map[icinga_web__x509_database_type].db_schema }}"))
  (icinga_web__x509_database_ssl (jinja "{{ False if icinga_web__x509_database_host == \"localhost\"
                                   else ansible_local.pki.enabled | d(False) | bool }}"))
  (icinga_web__x509_database_init (jinja "{{ not ansible_local.icinga_web.x509_installed | d(False) }}"))
  (icinga_web__icinga_api_fqdn (jinja "{{ icinga_web__node_fqdn }}"))
  (icinga_web__icinga_api_port "5665")
  (icinga_web__icinga_api_user "root")
  (icinga_web__icinga_api_password (jinja "{{ lookup(\"password\", secret + \"/icinga/api/\"
                                     + icinga_web__icinga_api_fqdn + \"/credentials/\"
                                     + icinga_web__icinga_api_user
                                     + \"/password\") }}"))
  (icinga_web__initial_account_groups (list
      
      (name "Administrators")
      
      (name "Users")))
  (icinga_web__initial_accounts (list
      
      (name "root")
      (password (jinja "{{ lookup(\"password\", secret + \"/icinga_web/auth/\"
                  + inventory_hostname + \"/credentials/root/password\") }}"))
      
      (name (jinja "{{ icinga_web__director_api_user }}"))
      (password (jinja "{{ icinga_web__director_api_password }}"))))
  (icinga_web__default_account_password (jinja "{{ lookup(\"password\", secret + \"/icinga_web/auth/\"
                                          + inventory_hostname + \"/default_password\") }}"))
  (icinga_web__ldap_enabled (jinja "{{ True
                              if ansible_local.ldap.enabled | d() | bool
                              else False }}"))
  (icinga_web__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (icinga_web__ldap_groups_rdn (jinja "{{ ansible_local.ldap.groups_rdn
                                  | d(\"ou=Groups\") }}"))
  (icinga_web__ldap_groups_dn (jinja "{{ [icinga_web__ldap_groups_rdn]
                                + icinga_web__ldap_base_dn }}"))
  (icinga_web__ldap_people_rdn (jinja "{{ ansible_local.ldap.people_rdn
                                  | d(\"ou=People\") }}"))
  (icinga_web__ldap_people_dn (jinja "{{ [icinga_web__ldap_people_rdn]
                                + icinga_web__ldap_base_dn }}"))
  (icinga_web__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (icinga_web__ldap_self_rdn "uid=icingaweb")
  (icinga_web__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (icinga_web__ldap_self_attributes 
    (uid (jinja "{{ icinga_web__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ icinga_web__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"Icinga Web\" service to access the LDAP directory"))
  (icinga_web__ldap_binddn (jinja "{{ ([icinga_web__ldap_self_rdn]
                              + icinga_web__ldap_device_dn) | join(\",\") }}"))
  (icinga_web__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                                     + icinga_web__ldap_binddn | to_uuid
                                     + \".password length=48 \"
                                     + \"chars=ascii_letters,digits,.-_\"))
                              if icinga_web__ldap_enabled | bool
                              else \"\" }}"))
  (icinga_web__ldap_hostname (jinja "{{ ansible_local.ldap.hosts | d([\"\"]) | first }}"))
  (icinga_web__ldap_encryption (jinja "{{ \"ldaps\"
                                 if ansible_local.ldap.protocol | d(\"\") == \"ldaps\"
                                 else (\"starttls\"
                                       if ansible_local.ldap.start_tls | d(True) | bool
                                       else \"plain\") }}"))
  (icinga_web__ldap_port (jinja "{{ ansible_local.ldap.port | d(389) }}"))
  (icinga_web__ldap_user_filter "(& (objectClass=" (jinja "{{ icinga_web__ldap_user_class }}") ") ( | (authorizedService=all) (authorizedService=icingaweb) ) )")
  (icinga_web__ldap_user_class "inetOrgPerson")
  (icinga_web__ldap_user_name_attribute "uid")
  (icinga_web__ldap_group_filter "objectClass=" (jinja "{{ icinga_web__ldap_group_class }}"))
  (icinga_web__ldap_group_class "groupOfNames")
  (icinga_web__ldap_group_member_attribute "member")
  (icinga_web__ldap_group_name_attribute "cn")
  (icinga_web__current_authentication (jinja "{{ (icinga_web__register_config.stdout
                                         | from_json)[\"authentication.ini\"] | d([]) }}"))
  (icinga_web__default_authentication (list
      
      (name "icingaweb2")
      (options (list
          
          (name "backend")
          (value "db")
          
          (name "resource")
          (value "icingaweb_db")))
      
      (name "ldap_users")
      (options (list
          
          (name "backend")
          (value "ldap")
          
          (name "resource")
          (value "ldap_db")
          
          (name "user_class")
          (value (jinja "{{ icinga_web__ldap_user_class }}"))
          
          (name "user_name_attribute")
          (value (jinja "{{ icinga_web__ldap_user_name_attribute }}"))
          
          (name "filter")
          (value (jinja "{{ icinga_web__ldap_user_filter }}"))))
      (state (jinja "{{ \"present\" if icinga_web__ldap_enabled | bool else \"ignore\" }}"))))
  (icinga_web__authentication (list))
  (icinga_web__combined_authentication (jinja "{{ icinga_web__current_authentication
                                         + icinga_web__default_authentication
                                         + icinga_web__authentication }}"))
  (icinga_web__current_config (jinja "{{ (icinga_web__register_config.stdout
                                 | from_json)[\"config.ini\"] | d([]) }}"))
  (icinga_web__default_config (list
      
      (name "global")
      (options (list
          
          (name "show_stacktraces")
          (value "0")
          
          (name "config_backend")
          (value "db")
          
          (name "config_resource")
          (value "icingaweb_db")
          
          (name "module_path")
          (value "/usr/share/icingaweb2/modules")))
      
      (name "logging")
      (options (list
          
          (name "log")
          (value "syslog")
          
          (name "level")
          (value "ERROR")
          
          (name "application")
          (value "icingaweb2")
          
          (name "facility")
          (value "user")))
      
      (name "themes")))
  (icinga_web__config (list))
  (icinga_web__combined_config (jinja "{{ icinga_web__current_config
                                 + icinga_web__default_config
                                 + icinga_web__config }}"))
  (icinga_web__current_groups (jinja "{{ (icinga_web__register_config.stdout
                                 | from_json)[\"groups.ini\"] | d([]) }}"))
  (icinga_web__default_groups (list
      
      (name "icingaweb2")
      (options (list
          
          (name "backend")
          (value "db")
          
          (name "resource")
          (value "icingaweb_db")))
      
      (name "ldap_groups")
      (options (list
          
          (name "backend")
          (value "ldap")
          
          (name "resource")
          (value "ldap_db")
          
          (name "user_backend")
          (value "ldap_users")
          
          (name "base_dn")
          (value (jinja "{{ icinga_web__ldap_groups_dn | join(\",\") }}"))
          
          (name "group_class")
          (value (jinja "{{ icinga_web__ldap_group_class }}"))
          
          (name "group_member_attribute")
          (value (jinja "{{ icinga_web__ldap_group_member_attribute }}"))
          
          (name "group_name_attribute")
          (value (jinja "{{ icinga_web__ldap_group_name_attribute }}"))
          
          (name "group_filter")
          (value (jinja "{{ icinga_web__ldap_group_filter }}"))))
      (state (jinja "{{ \"present\" if icinga_web__ldap_enabled | bool else \"ignore\" }}"))))
  (icinga_web__groups (list))
  (icinga_web__combined_groups (jinja "{{ icinga_web__current_groups
                                 + icinga_web__default_groups
                                 + icinga_web__groups }}"))
  (icinga_web__current_resources (jinja "{{ (icinga_web__register_config.stdout
                                    | from_json)[\"resources.ini\"] | d([]) }}"))
  (icinga_web__default_resources (list
      
      (name "icingaweb_db")
      (options (list
          
          (name "type")
          (value "db")
          
          (name "db")
          (value (jinja "{{ icinga_web__database_map[icinga_web__database_type].ido }}"))
          
          (name "host")
          (value (jinja "{{ icinga_web__database_host }}"))
          
          (name "port")
          (value (jinja "{{ icinga_web__database_port }}"))
          (state (jinja "{{ \"present\" if icinga_web__database_port | d() else \"absent\" }}"))
          
          (name "dbname")
          (value (jinja "{{ icinga_web__database_name }}"))
          
          (name "username")
          (value (jinja "{{ icinga_web__database_user }}"))
          
          (name "password")
          (value (jinja "{{ icinga_web__database_password }}"))
          
          (name "charset")
          (value "utf8")
          
          (name "persistent")
          (value "0")
          
          (name "use_ssl")
          (value (jinja "{{ \"1\" if icinga_web__database_ssl | d(False) | bool else \"0\" }}"))))
      
      (name "icinga2")
      (state (jinja "{{ \"present\" if icinga_web__master_database_enabled | bool else \"ignore\" }}"))
      (options (list
          
          (name "type")
          (value "db")
          
          (name "db")
          (value (jinja "{{ icinga_web__master_database_ido }}"))
          
          (name "host")
          (value (jinja "{{ icinga_web__master_database_host }}"))
          
          (name "port")
          (value (jinja "{{ icinga_web__master_database_port }}"))
          (state (jinja "{{ \"present\" if icinga_web__master_database_port | d() else \"absent\" }}"))
          
          (name "dbname")
          (value (jinja "{{ icinga_web__master_database_name }}"))
          
          (name "username")
          (value (jinja "{{ icinga_web__master_database_user }}"))
          
          (name "password")
          (value (jinja "{{ icinga_web__master_database_password }}"))
          
          (name "charset")
          (value "utf8")
          
          (name "persistent")
          (value "0")
          
          (name "use_ssl")
          (value (jinja "{{ \"1\" if icinga_web__master_database_ssl | d(False) | bool else \"0\" }}"))))
      
      (name "icinga2_director")
      (state (jinja "{{ \"present\" if icinga_web__director_enabled | bool else \"ignore\" }}"))
      (options (list
          
          (name "type")
          (value "db")
          
          (name "db")
          (value (jinja "{{ icinga_web__director_database_map[icinga_web__director_database_type].ido }}"))
          
          (name "host")
          (value (jinja "{{ icinga_web__director_database_host }}"))
          
          (name "port")
          (value (jinja "{{ icinga_web__director_database_port }}"))
          (state (jinja "{{ \"present\" if icinga_web__director_database_port | d() else \"absent\" }}"))
          
          (name "dbname")
          (value (jinja "{{ icinga_web__director_database_name }}"))
          
          (name "username")
          (value (jinja "{{ icinga_web__director_database_user }}"))
          
          (name "password")
          (value (jinja "{{ icinga_web__director_database_password }}"))
          
          (name "charset")
          (value "utf8")
          
          (name "persistent")
          (value "0")
          
          (name "use_ssl")
          (value (jinja "{{ \"1\" if icinga_web__director_database_ssl | d(False) | bool else \"0\" }}"))))
      
      (name "ldap_db")
      (state (jinja "{{ \"present\" if icinga_web__ldap_enabled | bool else \"ignore\" }}"))
      (options (list
          
          (name "type")
          (value "ldap")
          
          (name "hostname")
          (value (jinja "{{ icinga_web__ldap_hostname }}"))
          
          (name "port")
          (value (jinja "{{ icinga_web__ldap_port }}"))
          
          (name "root_dn")
          (value (jinja "{{ icinga_web__ldap_base_dn | join(\",\") }}"))
          
          (name "bind_dn")
          (value (jinja "{{ icinga_web__ldap_binddn }}"))
          
          (name "bind_pw")
          (value (jinja "{{ icinga_web__ldap_bindpw }}"))
          
          (name "encryption")
          (value (jinja "{{ icinga_web__ldap_encryption }}"))))
      
      (name "icingaweb2_x509")
      (state (jinja "{{ \"present\" if icinga_web__x509_enabled | bool else \"ignore\" }}"))
      (options (list
          
          (name "type")
          (value "db")
          
          (name "db")
          (value (jinja "{{ icinga_web__x509_database_map[icinga_web__x509_database_type].ido }}"))
          
          (name "host")
          (value (jinja "{{ icinga_web__x509_database_host }}"))
          
          (name "port")
          (value (jinja "{{ icinga_web__x509_database_port }}"))
          
          (name "dbname")
          (value (jinja "{{ icinga_web__x509_database_name }}"))
          
          (name "username")
          (value (jinja "{{ icinga_web__x509_database_user }}"))
          
          (name "password")
          (value (jinja "{{ icinga_web__x509_database_password }}"))
          
          (name "charset")
          (value "utf8")
          
          (name "use_ssl")
          (value (jinja "{{ \"1\" if icinga_web__x509_database_ssl | d(False) | bool else \"0\" }}"))))))
  (icinga_web__resources (list))
  (icinga_web__combined_resources (jinja "{{ icinga_web__current_resources
                                    + icinga_web__default_resources
                                    + icinga_web__resources }}"))
  (icinga_web__current_roles (jinja "{{ (icinga_web__register_config.stdout
                                | from_json)[\"roles.ini\"] | d([]) }}"))
  (icinga_web__default_roles (list
      
      (name "Administrators")
      (options (list
          
          (name "users")
          (value (jinja "{{ ansible_local.core.admin_users | d([]) | join(\",\") }}"))
          
          (name "permissions")
          (value "*")
          
          (name "groups")
          (value "Administrators")))))
  (icinga_web__roles (list))
  (icinga_web__combined_roles (jinja "{{ icinga_web__current_roles
                                + icinga_web__default_roles
                                + icinga_web__roles }}"))
  (icinga_web__current_backends (jinja "{{ (icinga_web__register_config.stdout
                                   | from_json)[\"modules/monitoring/backends.ini\"] | d([]) }}"))
  (icinga_web__default_backends (list
      
      (name "icinga2")
      (state (jinja "{{ \"present\"
               if (icinga_web__master_database_enabled | bool)
               else \"ignore\" }}"))
      (options (list
          
          (name "type")
          (value "ido")
          
          (name "resource")
          (value "icinga2")))))
  (icinga_web__backends (list))
  (icinga_web__combined_backends (jinja "{{ icinga_web__current_backends
                                   + icinga_web__default_backends
                                   + icinga_web__backends }}"))
  (icinga_web__current_commandtransports (jinja "{{ (icinga_web__register_config.stdout
                                            | from_json)[\"modules/monitoring/commandtransports.ini\"] | d([]) }}"))
  (icinga_web__default_commandtransports (list
      
      (name "icinga2")
      (options (list
          
          (name "transport")
          (value "api")
          
          (name "host")
          (value (jinja "{{ icinga_web__icinga_api_fqdn }}"))
          
          (name "port")
          (value (jinja "{{ icinga_web__icinga_api_port }}"))
          
          (name "username")
          (value (jinja "{{ icinga_web__icinga_api_user }}"))
          
          (name "password")
          (value (jinja "{{ icinga_web__icinga_api_password }}"))))
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.icinga | d() and
                   (ansible_local.icinga.installed | d()) | bool)
               else \"ignore\" }}"))))
  (icinga_web__commandtransports (list))
  (icinga_web__combined_commandtransports (jinja "{{ icinga_web__current_commandtransports
                                            + icinga_web__default_commandtransports
                                            + icinga_web__commandtransports }}"))
  (icinga_web__current_director_cfg (jinja "{{ (icinga_web__register_config.stdout
                                       | from_json)[\"modules/director/config.ini\"] | d([]) }}"))
  (icinga_web__default_director_cfg (list
      
      (name "db")
      (options (list
          
          (name "resource")
          (value "icinga2_director")))
      (state (jinja "{{ \"present\" if icinga_web__director_enabled | bool else \"ignore\" }}"))))
  (icinga_web__director_cfg (list))
  (icinga_web__combined_director_cfg (jinja "{{ icinga_web__current_director_cfg
                                       + icinga_web__default_director_cfg
                                       + icinga_web__director_cfg }}"))
  (icinga_web__current_director_kickstart_cfg (jinja "{{ (icinga_web__register_config.stdout
                                                 | from_json)[\"modules/director/kickstart.ini\"] | d([]) }}"))
  (icinga_web__default_director_kickstart_cfg (list
      
      (name "config")
      (options (list
          
          (name "endpoint")
          (value (jinja "{{ icinga_web__icinga_api_fqdn }}"))
          
          (name "host")
          (value (jinja "{{ icinga_web__icinga_api_fqdn }}"))
          
          (name "port")
          (value (jinja "{{ icinga_web__icinga_api_port }}"))
          
          (name "username")
          (value (jinja "{{ icinga_web__icinga_api_user }}"))
          
          (name "password")
          (value (jinja "{{ icinga_web__icinga_api_password }}"))))
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.icinga | d() and
                   (ansible_local.icinga.installed | d()) | bool)
               else \"ignore\" }}"))))
  (icinga_web__director_kickstart_cfg (list))
  (icinga_web__combined_director_kickstart_cfg (jinja "{{ icinga_web__current_director_kickstart_cfg
                                                 + icinga_web__default_director_kickstart_cfg
                                                 + icinga_web__director_kickstart_cfg }}"))
  (icinga_web__current_x509_cfg (jinja "{{ (icinga_web__register_config.stdout
                                       | from_json)[\"modules/x509/config.ini\"] | d([]) }}"))
  (icinga_web__default_x509_cfg (list
      
      (name "backend")
      (options (list
          
          (name "resource")
          (value "icingaweb2_x509")))
      (state (jinja "{{ \"present\" if icinga_web__x509_enabled | bool else \"ignore\" }}"))))
  (icinga_web__combined_x509_cfg (jinja "{{ icinga_web__current_x509_cfg
                                       + icinga_web__default_x509_cfg }}"))
  (icinga_web__apt_preferences__dependent_list (list
      
      (package (list
          "icingaweb2"
          "icingaweb2-*"
          "icingacli"
          "php-icinga"))
      (backports (list
          "stretch"))
      (by_role "debops.icinga_web")
      (reason "Incompatibility with PHP 7.3")))
  (icinga_web__ldap__dependent_tasks (list
      
      (name "Create Icinga Web account for " (jinja "{{ icinga_web__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ icinga_web__ldap_binddn }}"))
      (objectClass (jinja "{{ icinga_web__ldap_self_object_classes }}"))
      (attributes (jinja "{{ icinga_web__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\" if icinga_web__ldap_enabled else \"ignore\" }}"))))
  (icinga_web__postgresql__dependent_roles (list
      
      (name (jinja "{{ icinga_web__database_name }}"))
      (flags (list
          "NOLOGIN"))
      
      (name (jinja "{{ icinga_web__database_user }}"))
      (password (jinja "{{ icinga_web__database_password }}"))
      (db (jinja "{{ icinga_web__database_name }}"))
      (priv (list
          "ALL"))
      
      (name (jinja "{{ icinga_web__director_database_name }}"))
      (flags (list
          "NOLOGIN"))
      (state (jinja "{{ \"present\" if icinga_web__director_enabled | bool else \"ignore\" }}"))
      
      (name (jinja "{{ icinga_web__director_database_user }}"))
      (password (jinja "{{ icinga_web__director_database_password }}"))
      (db (jinja "{{ icinga_web__director_database_name }}"))
      (priv (list
          "ALL"))
      (state (jinja "{{ \"present\" if icinga_web__director_enabled | bool else \"ignore\" }}"))))
  (icinga_web__postgresql__dependent_databases (list
      
      (name (jinja "{{ icinga_web__database_name }}"))
      (owner (jinja "{{ icinga_web__database_name }}"))
      
      (name (jinja "{{ icinga_web__director_database_name }}"))
      (owner (jinja "{{ icinga_web__director_database_name }}"))
      (state (jinja "{{ \"present\" if icinga_web__director_enabled | bool else \"ignore\" }}"))))
  (icinga_web__postgresql__dependent_groups (list
      
      (roles (list
          (jinja "{{ icinga_web__database_user }}")))
      (groups (list
          (jinja "{{ icinga_web__database_name }}")))
      (database (jinja "{{ icinga_web__database_name }}"))
      
      (roles (list
          (jinja "{{ icinga_web__director_database_user }}")))
      (groups (list
          (jinja "{{ icinga_web__director_database_name }}")))
      (database (jinja "{{ icinga_web__director_database_name }}"))
      (state (jinja "{{ \"present\" if icinga_web__director_enabled | bool else \"ignore\" }}"))))
  (icinga_web__postgresql__dependent_privileges (list
      
      (roles (list
          (jinja "{{ icinga_web__database_user }}")))
      (database (jinja "{{ icinga_web__database_name }}"))
      (objs (list
          "ALL_DEFAULT"))
      (privs (list
          "SELECT"
          "INSERT"
          "UPDATE"
          "DELETE"))
      (type "default_privs")))
  (icinga_web__postgresql__dependent_extensions (list
      
      (database (jinja "{{ icinga_web__director_database_name }}"))
      (extension "pgcrypto")
      (state (jinja "{{ \"present\" if icinga_web__director_enabled | bool else \"ignore\" }}"))))
  (icinga_web__mariadb__dependent_databases (list
      
      (name (jinja "{{ icinga_web__database_name }}"))
      (state (jinja "{{ \"present\" if icinga_web__database_type == \"mariadb\" else \"ignore\" }}"))
      
      (name (jinja "{{ icinga_web__director_database_name }}"))
      (state (jinja "{{ \"present\"
                if (icinga_web__director_enabled | bool and icinga_web__director_database_type == \"mariadb\")
                else \"ignore\" }}"))
      
      (name (jinja "{{ icinga_web__x509_database_name }}"))
      (state (jinja "{{ \"present\" if icinga_web__x509_enabled | bool else \"ignore\" }}"))))
  (icinga_web__mariadb__dependent_users (list
      
      (database (jinja "{{ icinga_web__database_name }}"))
      (user (jinja "{{ icinga_web__database_user }}"))
      (password (jinja "{{ icinga_web__database_password }}"))
      (state (jinja "{{ \"present\" if icinga_web__database_type == \"mariadb\" else \"ignore\" }}"))
      
      (database (jinja "{{ icinga_web__director_database_name }}"))
      (user (jinja "{{ icinga_web__director_database_user }}"))
      (password (jinja "{{ icinga_web__director_database_password }}"))
      (state (jinja "{{ \"present\"
                if (icinga_web__director_enabled | bool and icinga_web__director_database_type == \"mariadb\")
                else \"ignore\" }}"))
      
      (database (jinja "{{ icinga_web__x509_database_name }}"))
      (user (jinja "{{ icinga_web__x509_database_user }}"))
      (state (jinja "{{ \"present\" if icinga_web__x509_enabled | bool else \"ignore\" }}"))))
  (icinga_web__php__dependent_packages (list
      "mysql"
      "intl"
      "ldap"
      "imagick"
      "pgsql"
      "curl"
      "yaml"
      "gmp"))
  (icinga_web__php__dependent_pools (list
      
      (name "icingaweb")
      (user "www-data")
      (group "www-data")))
  (icinga_web__nginx__dependent_upstreams (list
      
      (name "php_icingaweb")
      (type "php")
      (php_pool "icingaweb")))
  (icinga_web__nginx__dependent_servers (list
      
      (by_role "debops.icinga_web")
      (type "php")
      (name (jinja "{{ icinga_web__fqdn }}"))
      (root "/usr/share/icingaweb2/public")
      (webroot_create "False")
      (filename "debops.icinga_web")
      (php_upstream "php_icingaweb")
      (php_limit_except (list
          "GET"
          "HEAD"
          "POST"
          "DELETE"))
      (options "if (!-d $request_filename) {
        rewrite ^/(.+)/$ /$1 permanent;
}
")
      (location_list (list
          
          (pattern "/")
          (options "try_files $1 $uri $uri/ /index.php$is_args$args;"))))))
