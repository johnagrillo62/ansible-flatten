(playbook "debops/ansible/roles/librenms/defaults/main.yml"
  (librenms__base_packages (list
      (list
        "snmp"
        "imagemagick"
        "fping"
        "whois"
        "mtr-tiny"
        "rrdtool"
        "nmap")
      (jinja "{{ \"snmp-mibs-downloader\"
        if (ansible_local | d() and ansible_local.apt | d() and
            (ansible_local.apt.nonfree | d()) | bool)
        else [] }}")))
  (librenms__monitoring_packages (jinja "{{ librenms__monitoring_packages_map[ansible_distribution]
                                   | d([\"monitoring-plugins\"]) }}"))
  (librenms__monitoring_packages_map 
    (Ubuntu (list
        "nagios-plugins")))
  (librenms__packages (list))
  (librenms__fqdn "nms." (jinja "{{ librenms__domain }}"))
  (librenms__domain (jinja "{{ ansible_domain }}"))
  (librenms__base_url "/")
  (librenms__nginx_auth_realm "LibreNMS access is restricted")
  (librenms__nginx_access_policy "")
  (librenms__webserver_user (jinja "{{ ansible_local.nginx.user | d(\"www-data\") }}"))
  (librenms__user "librenms")
  (librenms__group "librenms")
  (librenms__shell "/bin/bash")
  (librenms__home (jinja "{{ ansible_local.nginx.www | d(\"/srv/www\") + \"/\" + librenms__user }}"))
  (librenms__install_path (jinja "{{ librenms__home + \"/sites/public\" }}"))
  (librenms__data_path (jinja "{{ (ansible_local.fhs.data | d(\"/srv\"))
                         + \"/\" + librenms__user }}"))
  (librenms__rrd_dir (jinja "{{ librenms__data_path + \"/rrd\" }}"))
  (librenms__log_dir (jinja "{{ (ansible_local.fhs.log | d(\"/var/log\"))
                       + \"/librenms\" }}"))
  (librenms__config_mode "0600")
  (librenms__install_repo "https://github.com/librenms/librenms.git")
  (librenms__install_version "master")
  (librenms__update "True")
  (librenms__database_server (jinja "{{ ansible_local.mariadb.server }}"))
  (librenms__database_user "librenms")
  (librenms__database_name "librenms")
  (librenms__database_password (jinja "{{ lookup('password', secret + '/mariadb/' +
                                 ansible_local.mariadb.delegate_to +
                                 '/credentials/' + librenms__database_user +
                                 '/password length=48') }}"))
  (librenms__admin_accounts (jinja "{{ ansible_local.core.admin_users | d([]) }}"))
  (librenms__cron_threads (jinja "{{ (ansible_processor_cores | int * 4) }}"))
  (librenms__memcached "False")
  (librenms__memcached_host "localhost")
  (librenms__memcached_port "11211")
  (librenms__show_services "True")
  (librenms__site_style "light")
  (librenms__network_map_items (list
      "xdp"))
  (librenms__front_page "pages/front/tiles.php")
  (librenms__public_status "False")
  (librenms__devices (list
      (jinja "{{ librenms__own_hostname }}")))
  (librenms__own_hostname (jinja "{{ ansible_fqdn }}"))
  (librenms__discover_services "True")
  (librenms__autodiscover_networks (list
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"))
  (librenms__ignore_mount_string (list
      "cgroup"
      "/run/"
      "/dev/shm"))
  (librenms__snmp_version "v3")
  (librenms__snmp_communities (list
      "public"))
  (librenms__snmp_credentials (list
      (jinja "{{ librenms__snmp_credentials_default }}")))
  (librenms__snmp_credentials_default 
    (authname (jinja "{{ lookup(\"password\", secret + \"/snmp/credentials/agent/username\") }}"))
    (authpass (jinja "{{ lookup(\"password\", secret + \"/snmp/credentials/agent/password\") }}"))
    (cryptopass (jinja "{{ lookup(\"password\", secret + \"/snmp/credentials/agent/password\") }}"))
    (authlevel "authPriv")
    (authalgo "SHA")
    (cryptoalgo "AES"))
  (librenms__home_snmp_conf (jinja "{{ ([\"root\", librenms__user] +
                              librenms__admin_accounts | d([])) | unique }}"))
  (librenms__configuration_maps (list
      (jinja "{{ librenms__config_database }}")
      (jinja "{{ librenms__config_authentication }}")
      (jinja "{{ librenms__config_installation }}")
      (jinja "{{ librenms__config_memcached }}")
      (jinja "{{ librenms__config_webui }}")
      (jinja "{{ librenms__config_autodiscovery }}")
      (jinja "{{ librenms__config_snmp }}")
      (jinja "{{ librenms__config_custom }}")))
  (librenms__config_database 
    (comment "Database configuration")
    (db_host (jinja "{{ librenms__database_server }}"))
    (db_name (jinja "{{ librenms__database_name }}"))
    (db_user (jinja "{{ librenms__database_user }}"))
    (db_pass (jinja "{{ librenms__database_password }}")))
  (librenms__config_authentication 
    (comment "Authentication configuration")
    (auth_mechanism "mysql"))
  (librenms__config_installation 
    (comment "Application directories, installation")
    (install_dir (jinja "{{ librenms__install_path }}"))
    (base_url (jinja "{{ librenms__base_url }}"))
    (rrd_dir (jinja "{{ librenms__rrd_dir }}"))
    (log_dir (jinja "{{ librenms__log_dir }}"))
    (update (jinja "{{ librenms__update }}"))
    (user (jinja "{{ librenms__user }}")))
  (librenms__config_memcached 
    (comment "Memcached configuration")
    (memcached 
      (enable (jinja "{{ librenms__memcached }}"))
      (host (jinja "{{ librenms__memcached_host }}"))
      (port (jinja "{{ librenms__memcached_port }}"))))
  (librenms__config_webui 
    (comment "Web interface configuration")
    (site_style (jinja "{{ librenms__site_style }}"))
    (front_page (jinja "{{ librenms__front_page }}"))
    (public_status (jinja "{{ librenms__public_status }}"))
    (show_services (jinja "{{ librenms__show_services }}"))
    (network_map_items 
      (array (jinja "{{ librenms__network_map_items }}"))))
  (librenms__config_autodiscovery 
    (comment "Autodiscovery configuration")
    (own_hostname (jinja "{{ librenms__own_hostname }}"))
    (discover_services (jinja "{{ librenms__discover_services }}"))
    (nets (jinja "{{ librenms__autodiscover_networks }}"))
    (ignore_mount_string (jinja "{{ librenms__ignore_mount_string }}"))
    (auth_ldap_groups 
      (admin 
        (level "7"))))
  (librenms__config_snmp 
    (comment "SNMP configuration")
    (snmp 
      (version 
        (array (list
            (jinja "{{ librenms__snmp_version }}"))))
      (community 
        (array (jinja "{{ librenms__snmp_communities }}")))
      (v3 (jinja "{{ librenms__snmp_credentials }}"))))
  (librenms__config_custom )
  (librenms__python__dependent_packages3 (list
      "python3-mysqldb"))
  (librenms__python__dependent_packages2 (list
      "python-mysqldb"))
  (librenms__logrotate__dependent_config (list
      
      (filename "librenms")
      (logs (jinja "{{ librenms__log_dir }}") "/*.log")
      (options "weekly
missingok
rotate 4
compress
notifempty
copytruncate
delaycompress
")))
  (librenms__php__dependent_packages (list
      (list
        "mysql"
        "gmp"
        "gd"
        "snmp"
        "curl"
        "mcrypt"
        "json")
      (jinja "{{ [\"xml\", \"mbstring\", \"zip\"]
        if (php__version is version_compare(\"7.0\", \">=\")) else [] }}")))
  (librenms__php__dependent_pools (list
      
      (name "librenms")
      (user (jinja "{{ librenms__user }}"))
      (group (jinja "{{ librenms__group }}"))
      (owner (jinja "{{ librenms__user }}"))
      (home (jinja "{{ librenms__home }}"))))
  (librenms__nginx__dependent_upstreams (list
      
      (name "php_librenms")
      (type "php")
      (php_pool "librenms")))
  (librenms__nginx__dependent_servers (list
      
      (by_role "debops.librenms")
      (type "php")
      (name (list
          (jinja "{{ librenms__fqdn }}")))
      (root (jinja "{{ librenms__install_path + \"/html\" }}"))
      (webroot_create "False")
      (filename "debops.librenms")
      (access_policy (jinja "{{ librenms__nginx_access_policy }}"))
      (auth_basic_realm (jinja "{{ librenms__nginx_auth_realm }}"))
      (php_upstream "php_librenms")
      (location 
        (@librenms "rewrite ^api/v0(.*)$ /api_v0.php/$1 last;
rewrite ^(.+)$ /index.php/$1 last;
")
        (/ "try_files $uri $uri/ @librenms;
"))))
  (librenms__mariadb__dependent_users (list
      
      (database (jinja "{{ librenms__database_name }}"))
      (user (jinja "{{ librenms__database_user }}"))
      (owner (jinja "{{ librenms__user }}"))
      (group (jinja "{{ librenms__group }}"))
      (home (jinja "{{ librenms__home }}"))
      (system "True"))))
