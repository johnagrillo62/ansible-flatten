(playbook "debops/ansible/roles/etherpad/defaults/main.yml"
  (etherpad__base_packages (list
      "build-essential"
      "pkg-config"
      "libssl-dev"
      "libpq-dev"
      "curl"
      "git"))
  (etherpad__document_packages (list
      "abiword"))
  (etherpad__packages (list))
  (etherpad_system_name "etherpad-lite")
  (etherpad_user (jinja "{{ etherpad_system_name }}"))
  (etherpad_group (jinja "{{ etherpad_system_name }}"))
  (etherpad_home (jinja "{{ (ansible_local.fhs.app | d(\"/var/local\"))
                   + \"/\" + etherpad_user }}"))
  (etherpad__shell "/usr/sbin/nologin")
  (etherpad_src_dir (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                      + \"/\" + etherpad_system_name }}"))
  (etherpad_log_dir (jinja "{{ (ansible_local.fhs.log | d(\"/var/log\"))
                      + \"/\" + etherpad_system_name }}"))
  (etherpad_log_to_file "False")
  (etherpad_version (jinja "{{ \"1.7.0\"
                      if (ansible_local.nodejs.npm_version | d() is version(\"6.4.0\", \"<\"))
                      else \"1.7.5\" }}"))
  (etherpad_source_address "https://github.com/ether")
  (etherpad_repository "etherpad-lite")
  (etherpad_dependencies "True")
  (etherpad_domain (list
      "pad." (jinja "{{ ansible_domain }}")))
  (etherpad_title "Etherpad")
  (etherpad_mail_admin "root@" (jinja "{{ ansible_domain }}"))
  (etherpad_welcome_text "Welcome to " (jinja "{{ etherpad_title }}") "!

This pad is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly on documents.

Contact with administrator: mailto:" (jinja "{{ etherpad_mail_admin }}") "
")
  (etherpad_database_server (jinja "{{ ansible_local.mariadb.server | d(ansible_local.postgresql.server | d(\"\")) }}"))
  (etherpad_database_user (jinja "{{ etherpad_system_name }}"))
  (etherpad_database_name (jinja "{{ etherpad_system_name }}"))
  (etherpad_database_password (jinja "{{ lookup('password', secret + '/'
                                + ('mariadb'
                                   if etherpad__database == 'mysql'
                                   else ('postgresql'
                                         if etherpad__database == 'postgres'
                                         else etherpad__database)) + '/'
                                + (ansible_local.mariadb.delegate_to + '/'
                                   if ansible_local.mariadb.delegate_to | d()
                                   else (ansible_local.postgresql.delegate_to + '/'
                                         if ansible_local.postgresql.delegate_to | d()
                                         else ''))
                                + (ansible_local.mariadb.port + '/'
                                   if ansible_local.mariadb.port | d()
                                   else (ansible_local.postgresql.port + '/'
                                         if ansible_local.postgresql.port | d()
                                         else ''))
                                + '/credentials/' + etherpad_database_user + '/password length=48') }}"))
  (etherpad__database (jinja "{{ \"mysql\"
                        if (ansible_local | d() and ansible_local.mariadb is defined)
                        else (\"postgres\"
                              if (ansible_local | d() and ansible_local.postgresql is defined)
                              else \"sqlite\") }}"))
  (etherpad_database_connection "socket")
  (etherpad_database_config 
    (dirty 
      (filename "var/dirty.db"))
    (sqlite 
      (filename "var/sqlite.db"))
    (mysql 
      (hostname (jinja "{{ etherpad_database_server }}"))
      (username (jinja "{{ etherpad_database_user }}"))
      (database (jinja "{{ etherpad_database_name }}"))
      (password (jinja "{{ etherpad_database_password }}"))
      (socket "/var/run/mysqld/mysqld.sock")
      (port "3306"))
    (postgres 
      (hostname (jinja "{{ etherpad_database_server }}"))
      (username (jinja "{{ etherpad_database_user }}"))
      (database (jinja "{{ etherpad_database_name }}"))
      (password (jinja "{{ etherpad_database_password }}"))
      (socket "/var/run/postgresql")
      (port "5432")))
  (etherpad_bind "127.0.0.1")
  (etherpad_port "9001")
  (etherpad_admins (list
      "admin"))
  (etherpad_users (list))
  (etherpad_password_hashing_algo "sha512")
  (etherpad_password_hashing_rounds "10")
  (etherpad_require_authentication "False")
  (etherpad_require_authorization "False")
  (etherpad_require_session "False")
  (etherpad_edit_only "False")
  (etherpad_trust_proxy "False")
  (etherpad_abiword "True")
  (etherpad__default_plugins (list
      
      (name "pg")
      (state (jinja "{{ \"present\"
               if (etherpad__database == \"postgres\")
               else \"absent\" }}"))
      
      (name "sqlite3")
      (state (jinja "{{ \"present\"
               if (etherpad__database == \"sqlite\")
               else \"absent\" }}"))
      "gyp"
      "bcrypt"
      "ep_adminpads"
      "ep_align"
      "ep_font_color"
      "ep_font_family"
      "ep_font_size"
      "ep_hash_auth"
      "ep_headings"
      "ep_hide_referrer"
      "ep_line_height"
      "ep_linkify"
      "ep_message_all"
      "ep_padlist"
      "ep_page_view"
      "ep_print"
      "ep_rss"
      "ep_scrollto"
      "ep_subscript"
      "ep_superscript"))
  (etherpad_plugins (list))
  (etherpad_allow (list))
  (etherpad_minify "True")
  (etherpad_max_age (jinja "{{ (60 * 60 * 6) }}"))
  (etherpad_disable_ip_logging "False")
  (etherpad_loglevel "INFO")
  (etherpad_custom_json "False")
  (etherpad_api_calls (list))
  (etherpad_api_version "1.2.12")
  (etherpad_api_key_file (jinja "{{ etherpad_home + \"/\" + etherpad_repository }}") "/APIKEY.txt")
  (etherpad_api_calls_debug "False")
  (etherpad__etc_services__dependent_list (list
      
      (name "etherpad-lite")
      (port (jinja "{{ etherpad_port }}"))
      (comment "Etherpad Lite")))
  (etherpad__logrotate__dependent_config (list
      
      (filename "etherpad-lite")
      (log (jinja "{{ etherpad_log_dir + \"/*.log\" }}"))
      (options "weekly
missingok
rotate 4
compress
notifempty
create 644 " (jinja "{{ etherpad_user }}") " " (jinja "{{ etherpad_group }}") "
")
      (comment "Logrotate configuration for etherpad-lite")))
  (etherpad__mariadb__dependent_users (list
      
      (name (jinja "{{ etherpad_database_user }}"))
      (password (jinja "{{ etherpad_database_password }}"))
      (owner (jinja "{{ etherpad_user }}"))
      (group (jinja "{{ etherpad_group }}"))
      (home (jinja "{{ etherpad_home }}"))))
  (etherpad__mariadb__dependent_databases (list
      
      (database (jinja "{{ etherpad_database_name }}"))))
  (etherpad__postgresql__dependent_roles (list
      
      (name (jinja "{{ etherpad_database_user }}"))
      (password (jinja "{{ etherpad_database_password }}"))
      (flags (list
          "NOSUPERUSER"
          "NOCREATEDB"
          "LOGIN"))))
  (etherpad__postgresql__dependent_databases (list
      
      (name (jinja "{{ etherpad_database_name }}"))
      (port "5432")
      (owner (jinja "{{ etherpad_database_user }}"))
      (encoding (jinja "{{ etherpad_database_encoding | d(omit) }}"))
      (lc_collate (jinja "{{ etherpad_database_collate | d(omit) }}"))
      (lc_ctype (jinja "{{ etherpad_database_ctype | d(omit) }}"))))
  (etherpad__nginx__dependent_upstreams (list
      
      (name (jinja "{{ etherpad_system_name }}"))
      (enabled "True")
      (server "127.0.0.1:" (jinja "{{ etherpad_port }}"))))
  (etherpad__nginx__dependent_servers (list
      
      (by_role "debops.etherpad")
      (enabled "True")
      (favicon "False")
      (name (jinja "{{ etherpad_domain }}"))
      (filename "debops.etherpad")
      (location 
        (~ ^/(locales/|locales.json|admin/|static/|pluginfw/|javascripts/|socket.io/|ep/|minified/|api/|ro/|error/|jserror/|favicon.ico|robots.txt) "proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_buffering off;
proxy_pass http://" (jinja "{{ etherpad_system_name }}") ";
")
        (/p/ "rewrite ^/p/(.*) /$1 redirect;
")
        (/redirect "proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_buffering off;
proxy_pass http://" (jinja "{{ etherpad_system_name }}") ";
")
        (~ ^/$ "proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_buffering off;
proxy_pass http://" (jinja "{{ etherpad_system_name }}") ";
")
        (/ "rewrite ^/admin(.*) /admin/$1 redirect;
rewrite ^/list(.*) /list break;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_buffering off;
proxy_pass http://" (jinja "{{ etherpad_system_name }}") "/p/;
proxy_redirect / /p/;
"))
      (location_allow 
        (~ ^/(locales/|locales.json|admin/|static/|pluginfw/|javascripts/|socket.io/|ep/|minified/|api/|ro/|error/|jserror/|favicon.ico|robots.txt) (jinja "{{ etherpad_allow }}"))
        (/p/ (jinja "{{ etherpad_allow }}"))
        (/redirect (jinja "{{ etherpad_allow }}"))
        (~ ^/$ (jinja "{{ etherpad_allow }}"))
        (/ (jinja "{{ etherpad_allow }}"))))))
