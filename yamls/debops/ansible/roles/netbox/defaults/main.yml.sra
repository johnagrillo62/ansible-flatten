(playbook "debops/ansible/roles/netbox/defaults/main.yml"
  (netbox__fqdn (list
      "dcim." (jinja "{{ netbox__domain }}")
      "ipam." (jinja "{{ netbox__domain }}")))
  (netbox__domain (jinja "{{ ansible_domain }}"))
  (netbox__primary "True")
  (netbox__base_packages (list
      "git"
      "build-essential"
      "libxml2-dev"
      "libxslt1-dev"
      "libffi-dev"
      "graphviz"
      "libpq-dev"
      "libssl-dev"
      (jinja "{{ [\"libldap2-dev\", \"libsasl2-dev\"]
        if netbox__ldap_enabled | bool
        else [] }}")))
  (netbox__packages (list))
  (netbox__user "netbox")
  (netbox__group "netbox")
  (netbox__gecos "NetBox")
  (netbox__shell "/usr/sbin/nologin")
  (netbox__napalm_ssh_generate "False")
  (netbox__napalm_ssh_generate_bits "2048")
  (netbox__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                  + \"/\" + netbox__user }}"))
  (netbox__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                 + \"/\" + netbox__user }}"))
  (netbox__lib (jinja "{{ (ansible_local.fhs.lib | d(\"/usr/local/lib\"))
                 + \"/\" + netbox__user }}"))
  (netbox__data (jinja "{{ (ansible_local.fhs.data | d(\"/srv\"))
                  + \"/\" + netbox__user }}"))
  (netbox__bin (jinja "{{ ansible_local.fhs.bin | d(\"/usr/local/bin\") }}"))
  (netbox__git_gpg_key_id "5DE3 E050 9C47 EA3C F04A  42D3 4AEE 18F8 3AFD EB23")
  (netbox__git_repo "https://github.com/netbox-community/netbox.git")
  (netbox__git_version "v4.4.1")
  (netbox__git_dest (jinja "{{ netbox__src + \"/\" + netbox__git_repo.split(\"://\")[1] }}"))
  (netbox__git_checkout (jinja "{{ netbox__virtualenv + \"/app\" }}"))
  (netbox__virtualenv_version (jinja "{{ \"\"
                                if (netbox__git_version | regex_search(\"^v?[0-9\\.]+\")
                                  and netbox__git_version | replace(\"v\", \"\") is version(\"2.5\", \"<\"))
                                else \"3\" }}"))
  (netbox__virtualenv (jinja "{{ netbox__lib + \"/virtualenv\" }}"))
  (netbox__virtualenv_env_path (jinja "{{ netbox__virtualenv }}") "/bin:/usr/local/bin:/usr/bin:/bin")
  (netbox__virtualenv_pip_packages (list
      
      (name "gunicorn")
      (version (jinja "{{ ansible_local.gunicorn.version | d(omit) }}"))
      "setproctitle"
      
      (name "django-auth-ldap")
      (state (jinja "{{ \"present\" if netbox__ldap_enabled | bool else \"ignore\" }}"))))
  (netbox__database_host (jinja "{{ ansible_local.postgresql.server | d(\"localhost\") }}"))
  (netbox__database_port (jinja "{{ ansible_local.postgresql.port | d(\"5432\") }}"))
  (netbox__database_name "netbox_production")
  (netbox__database_user (jinja "{{ netbox__user }}"))
  (netbox__database_password (jinja "{{ lookup(\"password\", secret + \"/postgresql/\" +
                               (ansible_local.postgresql.delegate_to | d(\"localhost\")) + \"/\" +
                               (ansible_local.postgresql.port | d(\"5432\")) + \"/credentials/\" +
                               netbox__database_user + \"/password\") }}"))
  (netbox__load_initial_data "True")
  (netbox__redis_host (jinja "{{ ansible_local.redis_server.host | d(\"localhost\") }}"))
  (netbox__redis_port (jinja "{{ ansible_local.redis_server.port | d(\"6379\") }}"))
  (netbox__redis_password (jinja "{{ ansible_local.redis_server.password | d(\"\") }}"))
  (netbox__redis_database "0")
  (netbox__redis_cache_database (jinja "{{ (netbox__redis_database | int + 1) }}"))
  (netbox__redis_ssl "False")
  (netbox__ldap_enabled (jinja "{{ True
                          if (ansible_local | d() and ansible_local.ldap | d() and
                              (ansible_local.ldap.enabled | d()) | bool)
                          else False }}"))
  (netbox__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (netbox__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (netbox__ldap_self_rdn "uid=netbox")
  (netbox__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (netbox__ldap_self_attributes 
    (uid (jinja "{{ netbox__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ netbox__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"NetBox\" service to access the LDAP directory"))
  (netbox__ldap_binddn (jinja "{{ ([netbox__ldap_self_rdn] + netbox__ldap_device_dn) | join(\",\") }}"))
  (netbox__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                                 + netbox__ldap_binddn | to_uuid + \".password length=32\"))
                         if netbox__ldap_enabled | bool
                         else \"\" }}"))
  (netbox__ldap_people_rdn (jinja "{{ ansible_local.ldap.people_rdn | d(\"ou=People\") }}"))
  (netbox__ldap_people_dn (jinja "{{ [netbox__ldap_people_rdn] + netbox__ldap_base_dn }}"))
  (netbox__ldap_group_authentication_enabled "True")
  (netbox__ldap_private_groups "True")
  (netbox__ldap_groups_rdn (jinja "{{ ansible_local.ldap.groups_rdn | d(\"ou=Groups\") }}"))
  (netbox__ldap_groups_dn (jinja "{{ ([netbox__ldap_groups_rdn, netbox__ldap_self_rdn]
                             + netbox__ldap_device_dn)
                            if netbox__ldap_private_groups | bool
                            else ([netbox__ldap_groups_rdn] + netbox__ldap_base_dn) }}"))
  (netbox__ldap_user_group_rdn "cn=NetBox Users")
  (netbox__ldap_user_group_dn (jinja "{{ [netbox__ldap_user_group_rdn]
                                + netbox__ldap_groups_dn }}"))
  (netbox__ldap_user_active_group_rdn "cn=NetBox Active Users")
  (netbox__ldap_user_active_group_dn (jinja "{{ [netbox__ldap_user_active_group_rdn]
                                       + netbox__ldap_groups_dn }}"))
  (netbox__ldap_user_staff_group_rdn "cn=NetBox Staff")
  (netbox__ldap_user_staff_group_dn (jinja "{{ [netbox__ldap_user_staff_group_rdn]
                                      + netbox__ldap_groups_dn }}"))
  (netbox__ldap_user_admin_group_rdn "cn=NetBox Administrators")
  (netbox__ldap_user_admin_group_dn (jinja "{{ [netbox__ldap_user_admin_group_rdn]
                                      + netbox__ldap_groups_dn }}"))
  (netbox__ldap_object_owner_rdn "uid=" (jinja "{{ lookup(\"env\", \"USER\") }}"))
  (netbox__ldap_object_ownerdn (jinja "{{ ([netbox__ldap_object_owner_rdn, netbox__ldap_people_rdn]
                                  + netbox__ldap_base_dn) | join(\",\") }}"))
  (netbox__ldap_server_uri (jinja "{{ ansible_local.ldap.uri | d([\"\"]) | first }}"))
  (netbox__ldap_server_port (jinja "{{ ansible_local.ldap.port | d(\"389\" if netbox__ldap_start_tls | bool else \"636\") }}"))
  (netbox__ldap_start_tls (jinja "{{ ansible_local.ldap.start_tls
                            if (ansible_local | d() and ansible_local.ldap | d() and
                                (ansible_local.ldap.start_tls | d()) | bool)
                            else True }}"))
  (netbox__ldap_user_filter "(uid=%(user)s)")
  (netbox__config_allowed_hosts (jinja "{{ netbox__fqdn }}"))
  (netbox__config_secret_key (jinja "{{ lookup(\"password\", secret + \"/netbox/\" +
                               netbox__domain + \"/config/secret_key length=64\") }}"))
  (netbox__config_admins (jinja "{{ lookup(\"template\", \"lookup/netbox__config_admins.j2\") | from_yaml }}"))
  (netbox__config_changelog_retention "90")
  (netbox__config_cors_origin_allow_all "False")
  (netbox__config_cors_origin_whitelist (list))
  (netbox__config_cors_origin_regex_whitelist (list))
  (netbox__config_default_language "en-us")
  (netbox__config_email_server "localhost")
  (netbox__config_email_port "25")
  (netbox__config_email_username "")
  (netbox__config_email_password "")
  (netbox__config_email_use_tls "True")
  (netbox__config_email_timeout "10")
  (netbox__config_email_from (jinja "{{ netbox__user }}") "@" (jinja "{{ netbox__fqdn
                                                  if netbox__fqdn is string
                                                  else netbox__fqdn[0] }}"))
  (netbox__config_logging )
  (netbox__config_login_required "True")
  (netbox__config_login_timeout (jinja "{{ (60 * 60 * 24 * 14) }}"))
  (netbox__config_base_path "")
  (netbox__config_maintenance_mode (jinja "{{ not netbox__primary | bool }}"))
  (netbox__config_paginate_count "50")
  (netbox__config_max_page_size "1000")
  (netbox__config_maps_url "https://www.openstreetmap.org/search?query=")
  (netbox__config_time_zone (jinja "{{ ansible_local.tzdata.timezone | d(\"Etc/UTC\") }}"))
  (netbox__config_date_format "N j, Y")
  (netbox__config_short_date_format "Y-m-d")
  (netbox__config_time_format "g:i a")
  (netbox__config_short_time_format "H:i:s")
  (netbox__config_datetime_format "N j, Y g:i a")
  (netbox__config_short_datetime_format "Y-m-d H:i")
  (netbox__config_banner_top "")
  (netbox__config_banner_bottom "")
  (netbox__config_banner_login "")
  (netbox__config_prefer_ipv4 "False")
  (netbox__config_census_reporting "True")
  (netbox__config_enforce_global_unique "False")
  (netbox__config_exempt_view_permissions (list))
  (netbox__config_metrics_enabled "False")
  (netbox__config_session_file_path (jinja "{{ \"\" if netbox__primary | bool else netbox__data + \"/sessions\" }}"))
  (netbox__config_media_root (jinja "{{ netbox__data + \"/media\" }}"))
  (netbox__config_reports_root (jinja "{{ netbox__data + \"/reports\" }}"))
  (netbox__config_scripts_root (jinja "{{ netbox__data + \"/scripts\" }}"))
  (netbox__config_plugins (list))
  (netbox__config_plugins_config )
  (netbox__config_custom "")
  (netbox__superuser_name (jinja "{{ ansible_local.core.admin_users[0] | d(\"admin\") }}"))
  (netbox__superuser_email (jinja "{{ ansible_local.core.admin_private_email[0]
                              | d(\"root@\" + netbox__domain) }}"))
  (netbox__superuser_password (jinja "{{ lookup(\"password\", secret + \"/netbox/\" +
                                netbox__domain + \"/superuser/\" +
                                netbox__superuser_name + \"/password\") }}"))
  (netbox__app_internal_appserver (jinja "{{ ansible_local.gunicorn.installed
                                     | d(ansible_service_mgr == \"systemd\") | bool }}"))
  (netbox__app_name (jinja "{{ netbox__user }}"))
  (netbox__app_runtime_dir (jinja "{{ \"gunicorn\"
                             if (ansible_distribution_release in
                                 [\"trusty\", \"xenial\"])
                             else \"gunicorn-netbox\" }}"))
  (netbox__app_bind "unix:/run/" (jinja "{{ netbox__app_runtime_dir }}") "/netbox.sock")
  (netbox__app_workers (jinja "{{ ansible_processor_vcpus | int + 1 }}"))
  (netbox__app_timeout "900")
  (netbox__app_params (list
      "--name=" (jinja "{{ netbox__app_name }}")
      "--bind=" (jinja "{{ netbox__app_bind }}")
      "--workers=" (jinja "{{ netbox__app_workers }}")
      "--timeout=" (jinja "{{ netbox__app_timeout }}")
      "netbox.wsgi"))
  (netbox__keyring__dependent_gpg_keys (list
      
      (user (jinja "{{ netbox__user }}"))
      (group (jinja "{{ netbox__group }}"))
      (home (jinja "{{ netbox__home }}"))
      (id (jinja "{{ netbox__git_gpg_key_id }}"))))
  (netbox__python__dependent_packages3 (list
      "python3-dev"))
  (netbox__python__dependent_packages2 (list
      "python-dev"))
  (netbox__ldap__dependent_tasks (list
      
      (name "Create NetBox account for " (jinja "{{ netbox__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ netbox__ldap_binddn }}"))
      (objectClass (jinja "{{ netbox__ldap_self_object_classes }}"))
      (attributes (jinja "{{ netbox__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\" if netbox__ldap_device_dn | d() else \"ignore\" }}"))
      
      (name "Create NetBox group container for " (jinja "{{ netbox__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ netbox__ldap_groups_dn }}"))
      (objectClass "organizationalStructure")
      (attributes 
        (ou (jinja "{{ netbox__ldap_groups_rdn.split(\"=\")[1] }}"))
        (description "User groups used in NetBox"))
      (state (jinja "{{ \"present\"
               if (netbox__ldap_device_dn | d() and
                   netbox__ldap_private_groups | bool)
               else \"ignore\" }}"))
      
      (name "Create NetBox user group for " (jinja "{{ netbox__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ netbox__ldap_user_group_dn }}"))
      (objectClass "groupOfNames")
      (attributes 
        (cn (jinja "{{ netbox__ldap_user_group_rdn.split(\"=\")[1] }}"))
        (owner (jinja "{{ netbox__ldap_object_ownerdn }}"))
        (member (jinja "{{ netbox__ldap_object_ownerdn }}")))
      (state (jinja "{{ \"present\" if netbox__ldap_device_dn | d() else \"ignore\" }}"))
      
      (name "Create NetBox active user group for " (jinja "{{ netbox__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ netbox__ldap_user_active_group_dn }}"))
      (objectClass "groupOfNames")
      (attributes 
        (cn (jinja "{{ netbox__ldap_user_active_group_rdn.split(\"=\")[1] }}"))
        (owner (jinja "{{ netbox__ldap_object_ownerdn }}"))
        (member (jinja "{{ netbox__ldap_object_ownerdn }}")))
      (state (jinja "{{ \"present\" if netbox__ldap_device_dn | d() else \"ignore\" }}"))
      
      (name "Create NetBox staff group for " (jinja "{{ netbox__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ netbox__ldap_user_staff_group_dn }}"))
      (objectClass "groupOfNames")
      (attributes 
        (cn (jinja "{{ netbox__ldap_user_staff_group_rdn.split(\"=\")[1] }}"))
        (owner (jinja "{{ netbox__ldap_object_ownerdn }}"))
        (member (jinja "{{ netbox__ldap_object_ownerdn }}")))
      (state (jinja "{{ \"present\" if netbox__ldap_device_dn | d() else \"ignore\" }}"))
      
      (name "Create NetBox admin group for " (jinja "{{ netbox__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ netbox__ldap_user_admin_group_dn }}"))
      (objectClass "groupOfNames")
      (attributes 
        (cn (jinja "{{ netbox__ldap_user_admin_group_rdn.split(\"=\")[1] }}"))
        (owner (jinja "{{ netbox__ldap_object_ownerdn }}"))
        (member (jinja "{{ netbox__ldap_object_ownerdn }}")))
      (state (jinja "{{ \"present\" if netbox__ldap_device_dn | d() else \"ignore\" }}"))))
  (netbox__gunicorn__dependent_applications (list
      
      (name "netbox")
      (mode "wsgi")
      (working_dir (jinja "{{ netbox__git_checkout + \"/netbox\" }}"))
      (python (jinja "{{ netbox__virtualenv + \"/bin/python\" }}"))
      (user (jinja "{{ netbox__user }}"))
      (group (jinja "{{ netbox__group }}"))
      (home (jinja "{{ netbox__home }}"))
      (system "True")
      (timeout (jinja "{{ netbox__app_timeout }}"))
      (workers (jinja "{{ netbox__app_workers }}"))
      (args (jinja "{{ netbox__app_params }}"))))
  (netbox__postgresql__dependent_roles (list
      
      (name (jinja "{{ netbox__database_user }}"))
      
      (name (jinja "{{ netbox__database_name }}"))
      (flags (list
          "NOLOGIN"))))
  (netbox__postgresql__dependent_groups (list
      
      (roles (list
          (jinja "{{ netbox__database_user }}")))
      (groups (list
          (jinja "{{ netbox__database_name }}")))
      (database (jinja "{{ netbox__database_name }}"))))
  (netbox__postgresql__dependent_databases (list
      
      (name (jinja "{{ netbox__database_name }}"))
      (owner (jinja "{{ netbox__database_name }}"))))
  (netbox__postgresql__dependent_pgpass (list
      
      (owner (jinja "{{ netbox__user }}"))
      (group (jinja "{{ netbox__group }}"))
      (home (jinja "{{ netbox__home }}"))
      (system "True")))
  (netbox__nginx__dependent_upstreams (list
      
      (name "netbox")
      (server (jinja "{{ netbox__app_bind }}"))))
  (netbox__nginx__dependent_servers (list
      
      (name (jinja "{{ netbox__fqdn }}"))
      (by_role "debops.netbox")
      (filename "debops.netbox")
      (options "client_max_body_size 25m;
")
      (location 
        (/static/ "alias " (jinja "{{ netbox__git_checkout }}") "/netbox/static/;
")
        (/ "proxy_pass http://netbox;
proxy_set_header X-Forwarded-Host $server_name;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_connect_timeout " (jinja "{{ netbox__app_timeout }}") ";
proxy_send_timeout " (jinja "{{ netbox__app_timeout }}") ";
proxy_read_timeout " (jinja "{{ netbox__app_timeout }}") ";
add_header P3P 'CP=\"ALL DSP COR PSAa PSDa OUR NOR ONL UNI COM NAV\"';
")))))
