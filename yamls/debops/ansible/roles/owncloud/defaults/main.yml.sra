(playbook "debops/ansible/roles/owncloud/defaults/main.yml"
  (owncloud__base_packages (list
      (jinja "{{ [\"owncloud-complete-files\"]
        if (owncloud__variant == \"owncloud\")
        else [] }}")
      (jinja "{{ [\"curl\", \"unzip\"]
        if (owncloud__variant == \"nextcloud\")
        else [] }}")
      (jinja "{{ [\"libreoffice\"] if (owncloud__app_documents_libreoffice_enabled | bool) else [] }}")
      (jinja "{{ [\"smbclient\"] if (owncloud__smb_support | bool) else [] }}")
      (jinja "{{ [\"libsmbclient\"] if (owncloud__smb_support | bool and owncloud__release is version_compare(\"9.0\", \">=\")) else [] }}")))
  (owncloud__required_php_packages (list
      "iconv"
      "gd"
      "json"
      "xml"
      "bcmath"
      "gmp"))
  (owncloud__recommended_php_packages (list
      "curl"
      "bz2"
      "mcrypt"
      "gmp"))
  (owncloud__base_php_packages (list
      (jinja "{{ owncloud__required_php_packages
        if (owncloud__variant == \"nextcloud\")
        else [] }}")
      "mbstring"
      "zip"
      (jinja "{{ [\"php-xml\", \"php-apcu\", \"php7.4-mysql\", \"php7.4-redis\"] if (owncloud__variant != \"nextcloud\") else [] }}")
      "ldap"
      "soap"
      (jinja "{{ [\"apcu\"] if (owncloud__apcu_enabled | bool) else [] }}")
      (jinja "{{ [\"mysql\"] if (owncloud__database in [\"mariadb\", \"mysql\"]) else [] }}")
      (jinja "{{ [\"pgsql\"] if (owncloud__database in [\"postgresql\"]) else [] }}")
      (jinja "{{ [\"redis\"] if (owncloud__redis_enabled | bool) else [] }}")
      (jinja "{{ [\"igbinary\"]
        if (not (ansible_distribution == \"Ubuntu\" and (ansible_distribution_version is version_compare(\"15.10\", \"<\"))))
        else [] }}")
      (jinja "{{ [\"libsmbclient\"] if (owncloud__smb_support | bool and owncloud__release is version_compare(\"8.9.9\", \"<=\")) else [] }}")
      "json"))
  (owncloud__optional_php_packages (list
      (jinja "{{ owncloud__recommended_php_packages
        if (owncloud__variant == \"nextcloud\")
        else [] }}")
      "intl"
      "imagick"))
  (owncloud__packages (list))
  (owncloud__group_packages (list))
  (owncloud__host_packages (list))
  (owncloud__dependent_packages (list))
  (owncloud__deploy_state "present")
  (owncloud__system_user "nextcloud")
  (owncloud__system_group "nextcloud")
  (owncloud__system_home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                           + \"/\" + owncloud__system_user }}"))
  (owncloud__comment "Nextcloud Application Manager")
  (owncloud__shell "/usr/sbin/nologin")
  (owncloud__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                   + \"/\" + owncloud__system_user }}"))
  (owncloud__upstream_key_fingerprint "2880 6A87 8AE4 23A2 8372 792E D758 99B9 A724 937A")
  (owncloud__keyserver (jinja "{{ ansible_local.keyring.keyserver | d(\"hkp://keyserver.ubuntu.com\") }}"))
  (owncloud__variant (jinja "{{ ansible_local.owncloud.variant | d(\"nextcloud\") }}"))
  (owncloud__variant_download_url_map 
    (nextcloud "https://download.nextcloud.com/server/releases"))
  (owncloud__variant_url_map 
    (owncloud "https://owncloud.org/")
    (nextcloud "https://nextcloud.com/"))
  (owncloud__variant_name_map 
    (owncloud "ownCloud")
    (nextcloud "Nextcloud"))
  (owncloud__release (jinja "{{ \"10\"
                       if (owncloud__variant == \"owncloud\")
                       else \"24.0\" }}"))
  (owncloud__distribution (jinja "{{ owncloud__distribution_name + \"_\" +
                            owncloud__distribution_version }}"))
  (owncloud__distribution_name (jinja "{{ ansible_distribution }}"))
  (owncloud__distribution_version (jinja "{{ ansible_distribution_major_version }}"))
  (owncloud__apt_repo_base "download.opensuse.org/repositories/isv:/ownCloud:/server:/" (jinja "{{ owncloud__release }}"))
  (owncloud__apt_repo_key_id "1B07204CD71B690D409F57D24ABE1AC7557BEFF9")
  (owncloud__old_apt_repo_keys (list
      "F9EA4996747310AE79474F44977C43A8BA684223"
      "BCECA90325B072AB1245F739AB7C32C35180350A"))
  (owncloud__src_remote_dir (jinja "{{
  (ansible_local.fhs.src | d(\"/usr/local/src\"))
  + \"/owncloud\" }}"))
  (owncloud__apt_repo_source (jinja "{{ \"deb https://\" + owncloud__apt_repo_base + \"/\" +
                               owncloud__distribution + \"/ /\" }}"))
  (owncloud__app_user (jinja "{{ ansible_local.nginx.user | d(\"www-data\") }}"))
  (owncloud__app_group (jinja "{{ owncloud__app_user }}"))
  (owncloud__app_home (jinja "{{ \"/var/www/owncloud\"
                        if (owncloud__variant == \"owncloud\")
                        else ((ansible_local.nginx.www
                              if (ansible_local.nginx.www | d())
                              else \"/srv/www\") + \"/\" + owncloud__system_user) }}"))
  (owncloud__data_path (jinja "{{ owncloud__app_home }}") "/data")
  (owncloud__temp_path "")
  (owncloud__deploy_path (jinja "{{ owncloud__app_home }}"))
  (owncloud__deploy_path_mode "0750")
  (owncloud__apcu_enabled "True")
  (owncloud__redis_enabled (jinja "{{ ansible_local.redis_server.installed | d() | bool and
                             (not (ansible_distribution == \"Ubuntu\" and ansible_distribution_release == \"trusty\")) }}"))
  (owncloud__redis_host (jinja "{{ ansible_local.redis_server.host | d(\"localhost\") }}"))
  (owncloud__redis_port (jinja "{{ ansible_local.redis_server.port | d(\"6379\") }}"))
  (owncloud__redis_password (jinja "{{ ansible_local.redis_server.password | d(omit) }}"))
  (owncloud__database "mariadb")
  (owncloud__database_server (jinja "{{ ansible_local[owncloud__database].server }}"))
  (owncloud__database_port (jinja "{{ ansible_local[owncloud__database].port }}"))
  (owncloud__database_user (jinja "{{ owncloud__variant }}"))
  (owncloud__database_name (jinja "{{ owncloud__variant }}"))
  (owncloud__database_password_path (jinja "{{ secret + \"/\" + owncloud__database + \"/\"
                                      + ansible_local[owncloud__database].delegate_to
                                      + ((\"/\" + ansible_local[owncloud__database].port)
                                         if (owncloud__database == \"postgresql\")
                                         else \"\")
                                      + \"/credentials/\" + owncloud__database_user + \"/password\" }}"))
  (owncloud__database_password (jinja "{{ lookup(\"password\", owncloud__database_password_path + \" length=48\") }}"))
  (owncloud__database_map 
    (mariadb 
      (dbtype "mysql")
      (dbname (jinja "{{ owncloud__database_name | d(owncloud__app_user) }}"))
      (dbuser (jinja "{{ owncloud__database_user | d(owncloud__app_user) }}"))
      (dbpass (jinja "{{ owncloud__database_password }}"))
      (dbhost (jinja "{{ owncloud__database_server | d(\"localhost\") }}"))
      (dbtableprefix ""))
    (postgresql 
      (dbtype "pgsql")
      (dbname (jinja "{{ owncloud__database_name | d(owncloud__app_user) }}"))
      (dbuser (jinja "{{ owncloud__database_user | d(owncloud__app_user) }}"))
      (dbpass (jinja "{{ owncloud__database_password }}"))
      (dbhost (jinja "{{ owncloud__database_server | d(\"/var/run/postgresql\") }}"))
      (dbtableprefix ""))
    (sqlite 
      (dbtype "sqlite")))
  (owncloud__admin_username "admin-" (jinja "{{ lookup(\"env\", \"USER\") }}"))
  (owncloud__admin_password_path (jinja "{{ secret + \"/credentials/\" + inventory_hostname +
                                  \"/owncloud/admin/\" + owncloud__admin_username +
                                  \"/password\" }}"))
  (owncloud__password_length "20")
  (owncloud__admin_password (jinja "{{ lookup(\"password\", owncloud__admin_password_path
                              + \" length=\" + (owncloud__password_length | string)) }}"))
  (owncloud__autosetup "True")
  (owncloud__autosetup_url "http://" (jinja "{{ owncloud__fqdn if owncloud__fqdn is string else owncloud__fqdn[0] }}") "/index.php")
  (owncloud__fqdn "cloud." (jinja "{{ owncloud__domain }}"))
  (owncloud__domain (jinja "{{ ansible_domain }}"))
  (owncloud__upload_size "2G")
  (owncloud__cron_minute "*/15")
  (owncloud__timeout "3600")
  (owncloud__app_user_webfinger_support "False")
  (owncloud__role_config 
    (trusted_domains (jinja "{{ [owncloud__fqdn] if owncloud__fqdn is string else owncloud__fqdn }}"))
    (updatechecker (jinja "{{ True if (owncloud__variant in [\"nextcloud\"]) else False }}"))
    (memcache.local 
      (state (jinja "{{ \"present\" if (owncloud__apcu_enabled | bool or owncloud__redis_enabled | bool) else \"absent\" }}"))
      (value (jinja "{{ \"\\\\OC\\\\Memcache\\\\Redis\" if (owncloud__redis_enabled | bool) else \"\\\\OC\\\\Memcache\\\\APCu\" }}")))
    (memcache.locking 
      (state (jinja "{{ \"present\" if (owncloud__redis_enabled | bool) else \"absent\" }}"))
      (value "\\\\OC\\\\Memcache\\\\Redis"))
    (redis 
      (state (jinja "{{ \"present\" if (owncloud__redis_enabled | bool) else \"absent\" }}"))
      (value 
        (host (jinja "{{ owncloud__redis_host }}"))
        (port (jinja "{{ owncloud__redis_port | int }}"))
        (password (jinja "{{ owncloud__redis_password }}"))))
    (tempdirectory 
      (state (jinja "{{ \"present\" if (owncloud__temp_path | d()) else \"absent\" }}"))
      (value (jinja "{{ owncloud__temp_path }}"))))
  (owncloud__release_channel (jinja "{{ \"stable\"
                               if (owncloud__variant == \"nextcloud\" and
                                   owncloud__release is version(\"17.0\", \">=\"))
                               else \"production\" }}"))
  (owncloud__role_recommended_config 
    (logtimezone (jinja "{{ ansible_local.tzdata.timezone | d(\"Etc/UTC\") }}"))
    (loglevel "2")
    (logdateformat "Y-m-d H:i:s.u")
    (updater.release.channel (jinja "{{ owncloud__release_channel }}")))
  (owncloud__config )
  (owncloud__group_config )
  (owncloud__host_config )
  (owncloud__combined_config (jinja "{{ owncloud__role_config
                               | combine(owncloud__role_recommended_config,
                                         owncloud__config,
                                         owncloud__group_config,
                                         owncloud__host_config) }}"))
  (owncloud__role_apps_config 
    (documents 
      (enabled (jinja "{{ \"yes\" if (owncloud__app_documents_enabled | bool) else \"no\" }}"))
      (converter "local"))
    (password_policy 
      (minLength "8")))
  (owncloud__apps_config )
  (owncloud__group_apps_config )
  (owncloud__host_apps_config )
  (owncloud__dependent_apps_config )
  (owncloud__apps_config_combined (jinja "{{ owncloud__dependent_apps_config
                                    | combine(owncloud__role_apps_config,
                                              owncloud__apps_config,
                                              owncloud__group_apps_config,
                                              owncloud__host_apps_config) }}"))
  (owncloud__app_documents_enabled "False")
  (owncloud__app_documents_libreoffice_enabled "False")
  (owncloud__smb_support "False")
  (owncloud__role_occ_cmd_list (list
      
      (command "app:disable updater")
      (when (jinja "{{ owncloud__release is version_compare(\"8.2\", \"<=\") }}"))
      
      (command "app:enable user_ldap")
      (when (jinja "{{ owncloud__ldap_enabled | bool }}"))
      
      (command "app:enable files_external")
      (when (jinja "{{ owncloud__smb_support | bool }}"))))
  (owncloud__occ_cmd_list (list))
  (owncloud__group_occ_cmd_list (list))
  (owncloud__host_occ_cmd_list (list))
  (owncloud__dependent_occ_cmd_list (list))
  (owncloud__occ_bin_file_path (jinja "{{ (ansible_local.fhs.bin | d(\"/usr/local/bin\"))
                                 + \"/occ\" }}"))
  (owncloud__user_files (list))
  (owncloud__user_files_group (list))
  (owncloud__user_files_host (list))
  (owncloud__ldap_enabled (jinja "{{ True
                            if (ansible_local | d() and ansible_local.ldap | d() and
                                (ansible_local.ldap.enabled | d()) | bool)
                            else False }}"))
  (owncloud_ldap_update_settings "True")
  (owncloud__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (owncloud__ldap_base_groups_dn (jinja "{{ owncloud__ldap_base_dn | join(\",\") }}"))
  (owncloud__ldap_base_users_dn (jinja "{{ owncloud__ldap_base_dn | join(\",\") }}"))
  (owncloud__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (owncloud__ldap_self_rdn "uid=nextcloud")
  (owncloud__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (owncloud__ldap_self_attributes 
    (uid (jinja "{{ owncloud__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ owncloud__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"Nextcloud\" service to access the LDAP directory"))
  (owncloud__ldap_binddn (jinja "{{ ([owncloud__ldap_self_rdn] + owncloud__ldap_device_dn) | join(\",\") }}"))
  (owncloud__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                                   + owncloud__ldap_binddn | to_uuid + \".password length=32 \"
                                   + \"chars=ascii_letters,digits,!@_#$%^&*\"))
                           if owncloud__ldap_enabled | bool
                           else \"\" }}"))
  (owncloud__ldap_uri (jinja "{{ ansible_local.ldap.uri | d([]) }}"))
  (owncloud__ldap_primary_server (jinja "{{ owncloud__ldap_uri | first }}"))
  (owncloud__ldap_method "tls")
  (owncloud__ldap_port (jinja "{{ 636 if (owncloud__ldap_method in [\"ssl\"]) else 389 }}"))
  (owncloud__ldap_user_display_name "cn")
  (owncloud__ldap_user_filter "(| (objectclass=inetOrgPerson) )")
  (owncloud__ldap_user_filter_objectclass "inetOrgPerson")
  (owncloud__ldap_group_filter "(& (objectClass=groupOfNames) (nextcloudEnabled=true) )")
  (owncloud__ldap_group_filter_groups "")
  (owncloud__ldap_group_filter_objectclass "posixGroup")
  (owncloud__ldap_login_filter "(& (objectclass=inetOrgPerson) (| (uid=%uid) (| (mail=%uid) (entryUUID=%uid) ) ) (| (authorizedService=all) (authorizedService=nextcloud) (authorizedService=owncloud) (authorizedService=web:public) ) )")
  (owncloud__ldap_login_filter_attributes "")
  (owncloud__ldap_group_assoc_attribute "member")
  (owncloud__home_folder_naming_rule "attr:uid")
  (owncloud__ldap_cache_ttl "600")
  (owncloud__ldap_expert_username_attr "")
  (owncloud__ldap_config_id (jinja "{{ ansible_local.owncloud.ldap_config_id
                              if (ansible_local.owncloud.ldap_config_id | d())
                              else (owncloud__register_ldap_config_id.stdout
                                    if (owncloud__register_ldap_config_id | d() and
                                        owncloud__register_ldap_config_id.stdout | d())
                                    else \"\") }}"))
  (owncloud__ldap_quota_attribute "nextcloudQuota")
  (owncloud__ldap_quota_default "10 GB")
  (owncloud__ldap_default_config (list
      
      (name "ldapHost")
      (value (jinja "{{ owncloud__ldap_primary_server }}"))
      
      (name "ldapPort")
      (value (jinja "{{ owncloud__ldap_port }}"))
      
      (name "ldapAgentName")
      (value (jinja "{{ owncloud__ldap_binddn }}"))
      
      (name "ldapAgentPassword")
      (value (jinja "{{ owncloud__ldap_bindpw }}"))
      
      (name "ldapBase")
      (value (jinja "{{ owncloud__ldap_base_dn | join(\",\") }}"))
      
      (name "ldapBaseGroups")
      (value (jinja "{{ owncloud__ldap_base_groups_dn }}"))
      
      (name "ldapBaseUsers")
      (value (jinja "{{ owncloud__ldap_base_users_dn }}"))
      
      (name "ldapEmailAttribute")
      (value "mail")
      
      (name "ldapExpertUsernameAttr")
      (value (jinja "{{ owncloud__ldap_expert_username_attr }}"))
      
      (name "ldapConfigurationActive")
      (value "1")
      
      (name "ldapUserDisplayName")
      (value (jinja "{{ owncloud__ldap_user_display_name }}"))
      
      (name "ldapUserFilter")
      (value (jinja "{{ owncloud__ldap_user_filter }}"))
      
      (name "ldapUserFilterObjectclass")
      (value (jinja "{{ owncloud__ldap_user_filter_objectclass }}"))
      
      (name "ldapLoginFilter")
      (value (jinja "{{ owncloud__ldap_login_filter }}"))
      
      (name "ldapLoginFilterAttributes")
      (value (jinja "{{ owncloud__ldap_login_filter_attributes }}"))
      
      (name "ldapGroupFilter")
      (value (jinja "{{ owncloud__ldap_group_filter }}"))
      
      (name "ldapGroupFilterGroups")
      (value (jinja "{{ owncloud__ldap_group_filter_groups }}"))
      
      (name "ldapGroupFilterObjectclass")
      (value (jinja "{{ owncloud__ldap_group_filter_objectclass }}"))
      
      (name "ldapGroupMemberAssocAttr")
      (value (jinja "{{ owncloud__ldap_group_assoc_attribute }}"))
      
      (name "homeFolderNamingRule")
      (value (jinja "{{ owncloud__home_folder_naming_rule }}"))
      
      (name "ldapCacheTTL")
      (value (jinja "{{ owncloud__ldap_cache_ttl }}"))
      
      (name "ldapTLS")
      (value (jinja "{{ \"1\" if (owncloud__ldap_method == \"tls\") else \"0\" }}"))
      
      (name "ldapQuotaAttribute")
      (value (jinja "{{ owncloud__ldap_quota_attribute }}"))
      
      (name "ldapQuotaDefault")
      (value (jinja "{{ owncloud__ldap_quota_default }}"))
      
      (name "hasMemberOfFilterSupport")
      (value "1")
      
      (name "turnOnPasswordChange")
      (value "1")
      
      (name "ldapDefaultPPolicyDN")
      (value (jinja "{{ ([\"cn=Default Password Policy\", \"ou=Password Policies\"]
                + owncloud__ldap_base_dn) | join(\",\") }}"))))
  (owncloud__ldap_config (list))
  (owncloud__group_ldap_config (list))
  (owncloud__host_ldap_config (list))
  (owncloud__ldap_combined_config (jinja "{{ owncloud__ldap_default_config
                                    + owncloud__ldap_config
                                    + owncloud__group_ldap_config
                                    + owncloud__host_ldap_config }}"))
  (owncloud__mail_domain (jinja "{{ owncloud__fqdn if owncloud__fqdn is string else owncloud__fqdn[0] }}"))
  (owncloud__mail_from_address "noreply")
  (owncloud__mail_smtpmode "sendmail")
  (owncloud__mail_smtphost "smtp." (jinja "{{ owncloud__domain }}"))
  (owncloud__mail_smtpport "25")
  (owncloud__mail_conf_map 
    (mail_domain (jinja "{{ owncloud__mail_domain }}"))
    (mail_from_address (jinja "{{ owncloud__mail_from_address }}"))
    (mail_smtpmode (jinja "{{ owncloud__mail_smtpmode }}"))
    (mail_smtphost (jinja "{{ owncloud__mail_smtphost }}"))
    (mail_smtpport (jinja "{{ owncloud__mail_smtpport }}")))
  (owncloud__theme_active (jinja "{{ \"debops\"
                            if (owncloud__variant in [\"owncloud\"])
                            else \"\" }}"))
  (owncloud__theme_directory_name (jinja "{{ \"debops\"
                                    if (owncloud__variant in [\"owncloud\"])
                                    else \"\" }}"))
  (owncloud__theme_title "DebOps Cloud")
  (owncloud__theme_name "DebOps Cloud")
  (owncloud__theme_name_html (jinja "{{ owncloud__theme_name }}"))
  (owncloud__theme_entity_name "DebOps")
  (owncloud__theme_base_url "https://github.com/debops/ansible-owncloud")
  (owncloud__theme_slogan "Powered by <a href=\"" (jinja "{{ owncloud__variant_url_map[owncloud__variant] }}") "\">" (jinja "{{ owncloud__variant_name_map[owncloud__variant] }}") "</a>")
  (owncloud__theme_footer_short "'Setup by <a href=\"' . $this->getBaseUrl() . '\" target=\"_blank\\\">' . $this->getEntity() . '</a><br/>' .
'" (jinja "{{ owncloud__theme_slogan }}") "'
")
  (owncloud__theme_footer_long (jinja "{{ owncloud__theme_footer_short }}"))
  (owncloud__theme_doc_link_to_key "$this->getDocBaseUrl() . '/server/" (jinja "{{ owncloud__release }}") "/go.php?to=' . $key")
  (owncloud__theme_copy_files )
  (owncloud__theme_copy_files_host_group )
  (owncloud__theme_copy_files_host )
  (owncloud__theme_conf_map 
    (theme (jinja "{{ owncloud__theme_active }}")))
  (owncloud__http_psk_subpath_enabled "False")
  (owncloud__http_psk_subpath (jinja "{{ lookup(\"password\", secret + \"/credentials/\" +
                                  inventory_hostname + \"/owncloud/config/subpath chars=ascii_letters,digits length=10\")
                                if owncloud__http_psk_subpath_enabled | bool
                                else \"\" }}"))
  (owncloud__http_psk_subpath_begin_slash (jinja "{{ (\"/\" + owncloud__http_psk_subpath)
                                          if owncloud__http_psk_subpath_enabled | bool
                                          else \"\" }}"))
  (owncloud__http_psk_subpath_end_slash (jinja "{{ (owncloud__http_psk_subpath + \"/\")
                                          if owncloud__http_psk_subpath_enabled | bool
                                          else \"\" }}"))
  (owncloud__webserver (jinja "{{ ansible_local.owncloud.webserver
                         | d(\"apache\"
                             if (ansible_local.apache.enabled | d() | bool)
                             else (\"nginx\"
                                   if (ansible_local.nginx.enabled | d() | bool)
                                   else \"no-webserver-detected\")) }}"))
  (owncloud__apache_modules (list))
  (owncloud__nginx_client_body_temp_path "")
  (owncloud__nginx_access_log_assets "True")
  (owncloud__php_temp_path "")
  (owncloud__php_output_buffering "0")
  (owncloud__php_max_children "50")
  (owncloud__apt_preferences__dependent_list (list
      
      (package "php5-apcu")
      (backports (list
          "trusty"))
      (reason "ownCloud requires at least APCu version 4.0.6.")
      (by_role "debops.owncloud")
      (state (jinja "{{ owncloud__deploy_state }}"))))
  (owncloud__apt_preferences__dependent_list_optional (list
      
      (package "owncloud owncloud*")
      (reason "Use download.owncloud.org even when foreign sources are disabled by global APT preferences.")
      (pin "origin \"download.owncloud.org\"")
      (priority "995")
      (by_role "debops.owncloud")
      (state (jinja "{{ \"present\"
               if (owncloud__variant in [\"owncloud\"] and
                   owncloud__deploy_state == \"present\")
               else \"absent\" }}"))))
  (owncloud__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ owncloud__apt_repo_key_id }}"))
      (state (jinja "{{ \"present\" if (owncloud__variant in [\"owncloud\"]) else \"absent\" }}"))
      
      (id "F9EA4996747310AE79474F44977C43A8BA684223")
      (state "absent")
      
      (id "BCECA90325B072AB1245F739AB7C32C35180350A")
      (state "absent")))
  (owncloud__keyring__dependent_gpg_keys (list
      
      (user (jinja "{{ owncloud__system_user }}"))
      (group (jinja "{{ owncloud__system_group }}"))
      (home (jinja "{{ owncloud__system_home }}"))
      (id (jinja "{{ owncloud__upstream_key_fingerprint }}"))
      (state (jinja "{{ \"present\" if (owncloud__variant in [\"nextcloud\"]) else \"absent\" }}"))))
  (owncloud__ldap__dependent_tasks (list
      
      (name "Create Nextcloud account for " (jinja "{{ owncloud__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ owncloud__ldap_binddn }}"))
      (objectClass (jinja "{{ owncloud__ldap_self_object_classes }}"))
      (attributes (jinja "{{ owncloud__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\" if owncloud__ldap_device_dn | d() else \"ignore\" }}"))
      
      (name "Enable password management by " (jinja "{{ owncloud__ldap_binddn }}"))
      (dn (jinja "{{ ([\"cn=Password Reset Agent\", \"ou=Roles\"] + owncloud__ldap_base_dn) | join(\",\") }}"))
      (attributes 
        (roleOccupant (jinja "{{ owncloud__ldap_binddn }}")))
      (state (jinja "{{ \"present\" if owncloud__ldap_device_dn | d() else \"ignore\" }}"))))
  (owncloud__mariadb__dependent_databases (list
      
      (database (jinja "{{ owncloud__database_map[owncloud__database].dbname }}"))
      (state (jinja "{{ \"present\" if (owncloud__deploy_state != \"purged\") else \"absent\" }}"))))
  (owncloud__mariadb__dependent_users (list
      
      (database (jinja "{{ owncloud__database_map[owncloud__database].dbname }}"))
      (user (jinja "{{ owncloud__database_map[owncloud__database].dbuser }}"))
      (password (jinja "{{ owncloud__database_map[owncloud__database].dbpass }}"))))
  (owncloud__postgresql__dependent_roles (list
      
      (name (jinja "{{ owncloud__database_name }}"))
      
      (name (jinja "{{ owncloud__database_user }}"))))
  (owncloud__postgresql__dependent_groups (list
      
      (roles (list
          (jinja "{{ owncloud__database_user }}")))
      (groups (list
          (jinja "{{ owncloud__database_name }}")))
      (database (jinja "{{ owncloud__database_name }}"))
      (state (jinja "{{ \"present\" if (owncloud__deploy_state != \"purged\") else \"absent\" }}"))))
  (owncloud__postgresql__dependent_databases (list
      
      (name (jinja "{{ owncloud__database_name }}"))
      (owner (jinja "{{ owncloud__database_user }}"))))
  (owncloud__logrotate__dependent_config (list
      
      (filename (jinja "{{ owncloud__variant }}"))
      (log (jinja "{{ owncloud__data_path + \"/\" + owncloud__variant + \".log\" }}"))
      (state (jinja "{{ \"present\" if (owncloud__deploy_state == \"present\") else \"absent\" }}"))
      (options "rotate 12
weekly
missingok
notifempty
compress
su " (jinja "{{ owncloud__app_user }}") " " (jinja "{{ owncloud__app_group }}") "
delaycompress
")))
  (owncloud__apache__dependent_snippets 
    (owncloud 
      (enabled "False")
      (type "dont-create")))
  (owncloud__apache__dependent_vhosts (list
      
      (type "default")
      (name (jinja "{{ owncloud__fqdn }}"))
      (by_role "debops.owncloud")
      (filename "debops.owncloud")
      (root (jinja "{{ owncloud__app_home }}"))
      (options "+FollowSymLinks")
      (allow_override "All")
      (root_directives "<IfModule mod_dav.c>
      Dav off
</IfModule>

SetEnv HOME " (jinja "{{ owncloud__app_home }}") "
SetEnv HTTP_HOME " (jinja "{{ owncloud__app_home }}") "

" (jinja "{# Does not work.
      ## Tested while uploading with:
      ## while true; do df -h /tmp|tail -n 1; sleep 0.1; done
      ## Currently configured in PHP Apache scope: owncloud__php__dependent_configuration
      {% if owncloud__php_temp_path | d() %}
      <IfModule mod_php5.c>
        php_value sys_temp_dir '{{ owncloud__php_temp_path }}'
      </IfModule>
      <IfModule mod_php7.c>
        php_value sys_temp_dir '{{ owncloud__php_temp_path }}'
      </IfModule>
      {% endif %}
      # SetEnv TMPDIR '{{ owncloud__php_temp_path }}'
      #}") "
")
      (raw_content "<Directory \"" (jinja "{{ owncloud__app_home }}") "/data/\">
    # Just in case the .htaccess gets disabled.
    Require all denied
</Directory>
" (jinja "{% if owncloud__data_path != (owncloud__app_home + \"/data\") %}") "
<Directory " (jinja "{{ owncloud__data_path | quote }}") ">
    # Just in case someone changes the global Apache defaults and messed
    # with the \"Alias\" directive ;)
    Require all denied
</Directory>
" (jinja "{% endif %}") "
")
      (http_sec_headers_directive_options "set")))
  (owncloud__nginx__dependent_maps (list
      
      (name "asset_immutable")
      (map "$arg_v $asset_immutable")
      (mapping "\"\" \"\";")
      (default "immutable")))
  (owncloud__nginx_options "add_header X-Download-Options noopen;

# Remove X-Powered-By, which is an information leak
fastcgi_hide_header X-Powered-By;

# Specify how to handle directories -- specifying `/index.php$request_uri`
# here as the fallback means that Nginx always exhibits the desired behaviour
# when a client requests a path that corresponds to a directory that exists
# on the server. In particular, if that directory contains an index.php file,
# that file is correctly served; if it doesn't, then the request is passed to
# the front-end controller. This consistent behaviour means that we don't need
# to specify custom rules for certain paths (e.g. images and other assets,
# `/updater`, `/ocm-provider`, `/ocs-provider`), and thus
# `try_files $uri $uri/ /index.php$request_uri`
# always provides the desired behaviour.
index index.php index.html /index.php$request_uri;

# Set max upload size and increase upload timeout:
client_max_body_size " (jinja "{{ owncloud__upload_size }}") ";
client_body_timeout 300s;
" (jinja "{% if owncloud__nginx_client_body_temp_path %}") "
client_body_temp_path '" (jinja "{{ owncloud__nginx_client_body_temp_path }}") "';
" (jinja "{% endif %}") "
fastcgi_buffers 64 4K;

" (jinja "{% if owncloud__app_user_webfinger_support | bool %}") "
rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;
" (jinja "{% endif %}") "

" (jinja "{% if owncloud__variant == \"nextcloud\" %}") "
# Enable gzip but do not remove ETag headers
gzip on;
gzip_vary on;
gzip_comp_level 4;
gzip_min_length 256;
gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;
" (jinja "{% else %}") "
# Disable gzip to avoid the removal of the ETag header
gzip off;
" (jinja "{% endif %}") "

# Uncomment if your server is build with the ngx_pagespeed module
# This module is currently not supported.
#pagespeed off;

# The settings allows you to optimize the HTTP2 bandwitdth.
# See https://blog.cloudflare.com/delivering-http-2-upload-speed-improvements/
# for tuning hints
# TODO(ypid): Nginx will be able to autotune this value when the patch gets accepted.
# DebOps will drop this manual tuning based on Nextcloud recommendation
# when the Nginx release is available in Debian oldstable.
client_body_buffer_size 512k;

" (jinja "{% if not (owncloud__variant == \"nextcloud\" and
           owncloud__release is version(\"18.0\", \">=\")) %}") "
error_page            403             /core/templates/403.php;
error_page            404             /core/templates/404.php;
" (jinja "{% endif %}") "

# Default Cache-Control policy
expires 1m;


# Avoid to send the security headers twice as ownCloud
# also adds the X-* HTTP headers.
fastcgi_param modHeadersAvailable true;")
  (owncloud__nginx__dependent_servers (list
      
      (type "default")
      (enabled "True")
      (by_role "debops.owncloud")
      (filename "debops.owncloud")
      (name (jinja "{{ owncloud__fqdn }}"))
      (root (jinja "{{ owncloud__deploy_path }}"))
      (webroot_create "False")
      (deny_hidden "False")
      (favicon "False")
      (maintenance (jinja "{{ False if (owncloud__variant == \"nextcloud\") else True }}"))
      (robots_tag (list
          "none"))
      (permitted_cross_domain_policies "none")
      (frame_options (jinja "{{ omit if (owncloud__variant == \"nextcloud\" and
                                owncloud__release is version(\"17.0\", \"<\"))
                            else \"SAMEORIGIN\" }}"))
      (options (jinja "{% if not (owncloud__http_psk_subpath_enabled | bool) %}") "
" (jinja "{{ owncloud__nginx_options }}") "
" (jinja "{% endif %}") "
")
      (location_list (list
          
          (pattern "/")
          (options "deny all;")
          (enabled (jinja "{{ owncloud__http_psk_subpath_enabled | bool }}"))
          
          (pattern "= /" (jinja "{{ owncloud__http_psk_subpath }}"))
          (options "# Rule borrowed from `.htaccess` to handle Microsoft DAV clients
if ( $http_user_agent ~ ^DavClnt ) {
    return 302 /" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "remote.php/webdav/$is_args$args;
}

# Not used in the Nginx configuration example of Nextcloud/ownCloud.
# Needed because `security.limit_extensions` defaults to `.php` in DebOps.
rewrite ^ /" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "index.php;
")
          
          (pattern "= /robots.txt")
          (options "allow all;
log_not_found off;
")
          (enabled (jinja "{{ not (owncloud__http_psk_subpath_enabled | bool) }}"))
          
          (pattern "^~ /.well-known")
          (options "# Make a regex exception for `/.well-known` so that clients can still
# access it despite the existence of the regex rule
# `location ~ /(\\.|autotest|...)` which would otherwise handle requests
# for `/.well-known`.

location = /.well-known/carddav     { return 301 /remote.php/dav/; }
location = /.well-known/caldav      { return 301 /remote.php/dav/; }
# Anything else is dynamically handled by Nextcloud
location ^~ /.well-known            { return 301 /index.php$uri; }

try_files $uri $uri/ =404;
")
          (enabled (jinja "{{ not (owncloud__http_psk_subpath_enabled | bool) }}"))
          
          (pattern "~ ^/" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "(?:build|tests|config|lib|3rdparty|templates|data)\\/")
          (options "return 404;
")
          
          (pattern "~ ^/" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "(?:\\.|autotest|occ|issue|indie|db_|console)")
          (options "return 404;
")
          
          (pattern "~ ^/" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") ".*\\.php(?:$|/)")
          (options "# Ensure this block, which passes PHP files to the PHP process, is above the blocks
# which handle static assets (as seen below). If this block is not declared first,
# then Nginx will encounter an infinite rewriting loop when it prepends `/index.php`
# to the URI, resulting in a HTTP 500 error response.

# Required for legacy support
# https://github.com/nextcloud/documentation/pull/2197#issuecomment-721432337
rewrite ^/" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "(?!index|remote|public|cron|core\\/ajax\\/update|status|ocs\\/v[12]|updater\\/.+|oc[ms]-provider\\/.+|.+\\/richdocumentscode\\/proxy) /" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "index.php$request_uri;

# (/.*|): The \"or empty\" regex alternative is needed for custom
# subpath because otherwise the whole regex would not match and would
# not update ${fastcgi_script_name}.
fastcgi_split_path_info ^" (jinja "{{ owncloud__http_psk_subpath_begin_slash }}") "(.+?\\.php)(/.*|)$;
set $path_info $fastcgi_path_info;
" (jinja "{% if owncloud__http_psk_subpath_enabled | bool %}") "
set $script_name \"" (jinja "{{ owncloud__http_psk_subpath_begin_slash }}") "${fastcgi_script_name}\";
" (jinja "{% endif %}") "

try_files $fastcgi_script_name =404;

include fastcgi_params;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
" (jinja "{% if owncloud__http_psk_subpath_enabled | bool %}") "
fastcgi_param SCRIPT_NAME $script_name;
" (jinja "{% endif %}") "
fastcgi_param PATH_INFO $path_info;
fastcgi_param HTTPS on;

fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
fastcgi_param front_controller_active true;     # Enable pretty urls
fastcgi_pass php_owncloud;

fastcgi_intercept_errors on;
" (jinja "{% if (ansible_local.nginx.version | d(\"0.0\")) is version_compare(\"1.7.11\", '>=') %}") "
fastcgi_request_buffering off;
" (jinja "{% endif %}") "

fastcgi_read_timeout " (jinja "{{ owncloud__timeout }}") ";
")
          
          (pattern "~ " (jinja "{{ owncloud__http_psk_subpath_begin_slash }}") "(/.*\\.(?:css|js|svg|gif|png|jpg|ico|wasm|tflite))$")
          (options "try_files " (jinja "{{ \"$1\" if (owncloud__http_psk_subpath_enabled | bool) else \"$uri\" }}") " /" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "index.php$request_uri;
add_header Cache-Control \"public, max-age=15778463, $asset_immutable\";

" (jinja "{% if not (owncloud__nginx_access_log_assets | bool) %}") "
access_log off;
" (jinja "{% endif %}") "

location ~ \\.wasm$ {
    default_type application/wasm;
}
")
          
          (pattern "~ " (jinja "{{ owncloud__http_psk_subpath_begin_slash }}") "(/.*\\.woff2?)$")
          (options "try_files " (jinja "{{ \"$1\" if (owncloud__http_psk_subpath_enabled | bool) else \"$uri\" }}") " /" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "index.php$request_uri;
expires 7d;         # Cache-Control policy borrowed from `.htaccess`

" (jinja "{% if not (owncloud__nginx_access_log_assets | bool) %}") "
access_log off;
" (jinja "{% endif %}") "
")
          
          (pattern "^~ /" (jinja "{{ owncloud__http_psk_subpath }}"))
          (options (jinja "{{ owncloud__nginx_options }}") "
")
          (enabled (jinja "{{ owncloud__http_psk_subpath_enabled | bool }}"))
          
          (pattern "/" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "remote")
          (options "# Rule borrowed from `.htaccess`
return 301 /" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "remote.php$request_uri;
")
          
          (pattern "/" (jinja "{{ owncloud__http_psk_subpath_end_slash }}"))
          (options "try_files $uri $uri/ /" (jinja "{{ owncloud__http_psk_subpath_end_slash }}") "index.php$request_uri;
")))))
  (owncloud__nginx__dependent_upstreams (list
      
      (name "php_owncloud")
      (by_role "debops.owncloud")
      (enabled "True")
      (state (jinja "{{ owncloud__deploy_state }}"))
      (type "php")
      (php_pool "owncloud")))
  (owncloud__php__dependent_packages (list
      (jinja "{{ owncloud__base_php_packages }}")
      (jinja "{{ owncloud__optional_php_packages }}")
      (jinja "{{ [\"libapache2-mod-php\"] if (owncloud__webserver == \"apache\") else [] }}")))
  (owncloud__php__dependent_configuration (list
      
      (filename "10-owncloud")
      (by_role "debops.owncloud")
      (state (jinja "{{ \"present\" if (((owncloud__apcu_enabled | bool) and (owncloud__release is match(\"8\\.1\"))) or
            ((owncloud__variant in [\"nextcloud\"]) and
            (owncloud__release is version_compare(\"21.0\", \">=\"))))
            else \"absent\" }}"))
      (options "; Workaround for: https://github.com/owncloud/core/issues/17329
apc.enable_cli = 1
")
      
      (filename "30-owncloud-opcache")
      (by_role "debops.owncloud")
      (state (jinja "{{ \"present\"
               if (owncloud__variant in [\"nextcloud\"] and owncloud__release is version_compare(\"12.0\", \">=\"))
               else \"absent\" }}"))
      (options "; https://docs.nextcloud.com/server/25/admin_manual/installation/server_tuning.html#enable-php-opcache
; https://github.com/nextcloud/docker/blob/master/25/fpm/Dockerfile

[opcache]

opcache.enable=1
opcache.enable_cli=1
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=60
")
      
      (filename "debops.owncloud")
      (path "apache2/conf.d/")
      (by_role "debops.owncloud")
      (state (jinja "{{ (owncloud__php_temp_path | d() and owncloud__webserver == \"apache\") | ternary(\"present\", \"absent\") }}"))
      (sections (list
          
          (options "## TODO: Could not be configured on Apache vhost scope.
sys_temp_dir = " (jinja "{{ owncloud__php_temp_path | quote }}") "
")))))
  (owncloud__php__dependent_pools 
    (name "owncloud")
    (by_role "debops.owncloud")
    (user (jinja "{{ owncloud__app_user }}"))
    (group (jinja "{{ owncloud__app_group }}"))
    (pm_max_children (jinja "{{ owncloud__php_max_children }}"))
    (request_terminate_timeout (jinja "{{ owncloud__timeout }}"))
    (php_values 
      (output_buffering (jinja "{{ owncloud__php_output_buffering }}"))
      (upload_max_filesize (jinja "{{ owncloud__upload_size }}"))
      (post_max_size (jinja "{{ owncloud__upload_size }}"))
      (memory_limit (jinja "{{ owncloud__upload_size }}"))
      (max_input_time (jinja "{{ owncloud__timeout }}"))
      (max_execution_time (jinja "{{ owncloud__timeout }}")))
    (environment 
      (PATH "/usr/local/bin:/usr/bin:/bin")))
  (owncloud__unattended_upgrades__dependent_origins (list
      
      (origin "site=download.owncloud.org")
      (by_role "debops.owncloud")
      (state "absent"))))
