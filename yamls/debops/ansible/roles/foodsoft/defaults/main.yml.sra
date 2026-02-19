(playbook "debops/ansible/roles/foodsoft/defaults/main.yml"
  (foodsoft__base_packages (list
      (jinja "{{ [\"ruby2.0\", \"ruby2.0-dev\"] if (ansible_distribution == \"Ubuntu\" and ansible_distribution_release in [\"trusty\"]) else [] }}")
      "libcurl3-dev"
      "libxml2-dev"
      "libxslt-dev"
      "libffi-dev"
      "libreadline-dev"
      "g++"
      "libicu-dev"
      "pkg-config"
      "libmagickwand-dev"
      "ruby-magic"
      "libmagic-dev"
      (jinja "{{ [\"libsqlite3-dev\"] if (foodsoft__database in [\"sqlite\"]) else [] }}")
      (jinja "{{ [\"libmysqlclient-dev\", \"libmariadbd-dev\"] if (foodsoft__database in [\"mariadb\"]) else [] }}")))
  (foodsoft__deploy_state "present")
  (foodsoft__fqdn "foodsoft." (jinja "{{ foodsoft__domain }}"))
  (foodsoft__domain (jinja "{{ ansible_domain }}"))
  (foodsoft__database (jinja "{{ ansible_local.foodsoft.database
                        if (ansible_local.foodsoft.database | d())
                        else (\"mariadb\"
                              if (ansible_local | d() and ansible_local.mariadb is defined)
                              else (\"postgresql\"
                                    if (ansible_local | d() and ansible_local.postgresql is defined)
                                    else \"no-database-detected\")) }}"))
  (foodsoft__database_server (jinja "{{ ansible_local[foodsoft__database].server }}"))
  (foodsoft__database_port (jinja "{{ ansible_local[foodsoft__database].port }}"))
  (foodsoft__database_name "foodsoft")
  (foodsoft__database_user "foodsoft")
  (foodsoft__database_password_path (jinja "{{ secret + \"/\" + foodsoft__database + \"/\"
                                      + ansible_local[foodsoft__database].delegate_to
                                      + ((\"/\" + ansible_local[foodsoft__database].port)
                                         if (foodsoft__database == \"postgresql\")
                                         else \"\")
                                      + \"/credentials/\" + foodsoft__database_user + \"/password\" }}"))
  (foodsoft__database_password (jinja "{{ lookup(\"password\", foodsoft__database_password_path + \" length=48 chars=ascii_letters,digits,.:-_\") }}"))
  (foodsoft__database_name_map 
    (mariadb "mysql2")
    (sqlite "sqlite3")
    (mysql "mysql2"))
  (foodsoft__database_config 
    (production 
      (adapter (jinja "{{ foodsoft__database_name_map[foodsoft__database] }}"))
      (host (jinja "{{ foodsoft__database_server }}"))
      (reconnect "False")
      (pool "5")
      (username (jinja "{{ foodsoft__database_user }}"))
      (password (jinja "{{ foodsoft__database_password }}"))
      (database (jinja "{{ foodsoft__database_name }}"))
      (encoding "utf8")))
  (foodsoft__webserver (jinja "{{ ansible_local.foodsoft.webserver
                         if (ansible_local.foodsoft.webserver | d())
                         else (\"nginx\"
                               if (ansible_local.nginx.enabled | d() | bool)
                               else (\"apache\"
                                     if (ansible_local.apache.enabled | d() | bool)
                                     else \"no-webserver-detected\")) }}"))
  (foodsoft__webserver_user (jinja "{{ ansible_local.nginx.user | d(\"www-data\") }}"))
  (foodsoft__home_path (jinja "{{ ansible_local.nginx.www | d(\"/srv/www\") + \"/\" + foodsoft__user }}"))
  (foodsoft__www_path (jinja "{{ foodsoft__git_dest + \"/public\" }}"))
  (foodsoft__user "foodsoft")
  (foodsoft__group "foodsoft")
  (foodsoft__gecos "Foodsoft")
  (foodsoft__shell "/usr/sbin/nologin")
  (foodsoft__git_repo "https://github.com/foodcoops/foodsoft.git")
  (foodsoft__git_version "a7b6b0c803ca4a79ddab7cea92545b8cc188f952")
  (foodsoft__git_dest (jinja "{{ foodsoft__home_path + \"/foodcoops-foodsoft\" }}"))
  (foodsoft__git_update "True")
  (foodsoft__bundler_exclude_groups (list
      "test"
      "development"))
  (foodsoft__name "Foodcoop")
  (foodsoft__contact 
    (street "Grüne Straße 23")
    (zip_code "12323")
    (city "Berlin")
    (country "Deutschland")
    (email (jinja "{{ foodsoft__email_sender }}"))
    (phone "030 323 232323"))
  (foodsoft__default_scope "f")
  (foodsoft__homepage "https://" (jinja "{{ foodsoft__fqdn }}") "/" (jinja "{{ foodsoft__default_scope }}"))
  (foodsoft__page_footer "<a href=\"" (jinja "{{ foodsoft__homepage }}") "/\">" (jinja "{{ foodsoft__name }}") "</a>, setup by <a href=\"https://debops.org/\">DebOps</a>.")
  (foodsoft__email_sender "foodsoft@" (jinja "{{ foodsoft__domain }}"))
  (foodsoft__error_recipients (list
      "admin@" (jinja "{{ foodsoft__domain }}")))
  (foodsoft__multi_coop_install "False")
  (foodsoft__upstream_config (jinja "{{ lookup(\"file\", \"vars/sample_app_config.yml\") | from_yaml }}"))
  (foodsoft__role_config 
    (multi_coop_install (jinja "{{ foodsoft__multi_coop_install | bool }}"))
    (default_scope (jinja "{{ foodsoft__default_scope }}"))
    (name (jinja "{{ foodsoft__name }}"))
    (contact (jinja "{{ foodsoft__contact }}"))
    (homepage (jinja "{{ foodsoft__homepage }}"))
    (page_footer (jinja "{{ foodsoft__page_footer }}"))
    (email_sender (jinja "{{ foodsoft__email_sender }}"))
    (notification 
      (error_recipients (jinja "{{ foodsoft__error_recipients }}"))
      (sender_address "\"Foodsoft Error\" <" (jinja "{{ foodsoft__email_sender }}") ">")
      (email_prefix "[Foodsoft]")))
  (foodsoft__config )
  (foodsoft__group_config )
  (foodsoft__host_config )
  (foodsoft__combined_config (jinja "{{ foodsoft__upstream_config.default
                               | combine(foodsoft__role_config)
                               | combine(foodsoft__config)
                               | combine(foodsoft__group_config)
                               | combine(foodsoft__host_config) }}"))
  (foodsoft__mariadb__dependent_databases (list
      
      (database (jinja "{{ foodsoft__database_name }}"))
      (state (jinja "{{ \"present\" if (foodsoft__deploy_state != \"purged\") else \"absent\" }}"))))
  (foodsoft__mariadb__dependent_users (list
      
      (database (jinja "{{ foodsoft__database_name }}"))
      (state (jinja "{{ \"present\" if (foodsoft__deploy_state == \"present\") else \"absent\" }}"))
      (user (jinja "{{ foodsoft__database_user }}"))
      (password (jinja "{{ foodsoft__database_password }}"))))
  (foodsoft__nginx__dependent_servers (list
      
      (name (jinja "{{ foodsoft__fqdn }}"))
      (filename "debops.foodsoft")
      (by_role "debops-contrib.foodsoft")
      (enabled "True")
      (type "rails")
      (root (jinja "{{ foodsoft__www_path }}"))
      (webroot_create "False")
      (hsts_enabled "False")
      (frame_options "False")
      (content_type_options "False")
      (xss_protection (jinja "{{ omit }}"))
      (passenger_user (jinja "{{ foodsoft__user }}"))
      (passenger_group (jinja "{{ foodsoft__group }}")))))
