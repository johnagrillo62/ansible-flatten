(playbook "debops/ansible/roles/phpipam/defaults/main.yml"
  (phpipam__mode (list
      "webui"
      "scripts"))
  (phpipam__fqdn "ipam." (jinja "{{ ansible_domain }}"))
  (phpipam__nginx_auth_realm "IPAM access is restricted")
  (phpipam__nginx_access_policy "")
  (phpipam__webserver_user (jinja "{{ ansible_local.nginx.user
                             if (ansible_local is defined and
                                 ansible_local.nginx is defined and
                                 ansible_local.nginx.user is defined)
                             else \"www-data\" }}"))
  (phpipam__user "phpipam")
  (phpipam__group "phpipam")
  (phpipam__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                   + \"/\" + phpipam__user }}"))
  (phpipam__database_user "phpipam")
  (phpipam__database_host (jinja "{{ ansible_local.mariadb.server }}"))
  (phpipam__database_name "phpipam")
  (phpipam__database_password (jinja "{{ lookup('password', secret + '/mariadb/' +
                                ansible_local.mariadb.delegate_to +
                                '/credentials/' + phpipam__database_user +
                                '/password length=48') }}"))
  (phpipam__database_schema (jinja "{{ phpipam__git_checkout + \"/db/SCHEMA.sql\" }}"))
  (phpipam__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                  + \"/\" + phpipam__user }}"))
  (phpipam__www (jinja "{{ (ansible_local.nginx.www
                  if (ansible_local is defined and
                      ansible_local.nginx is defined and
                      ansible_local.nginx.www is defined)
                  else \"/srv/www\") + \"/\" + phpipam__user }}"))
  (phpipam__git_repo "https://github.com/phpipam/phpipam.git")
  (phpipam__git_dest (jinja "{{ phpipam__src + \"/\" + phpipam__git_repo.split(\"://\")[1] }}"))
  (phpipam__git_version "v1.4.1")
  (phpipam__git_checkout (jinja "{{ phpipam__www + \"/sites/\" + phpipam__fqdn + \"/public\" }}"))
  (phpipam__php_session_name (jinja "{{ lookup('password', secret + '/credentials/'
                               + inventory_hostname + '/phpipam/php_session_name
                               chars=hexdigits length=30') }}"))
  (phpipam__scripts_git_repo "https://github.com/debops/phpipam-scripts")
  (phpipam__scripts_git_dest (jinja "{{ \"/usr/local/src/phpipam/\" + phpipam__scripts_git_repo.split(\"://\")[1] }}"))
  (phpipam__scripts_git_version "master")
  (phpipam__scripts_database_user (jinja "{{ phpipam__database_user }}"))
  (phpipam__scripts_database_host (jinja "{{ phpipam__database_host }}"))
  (phpipam__scripts_database_name (jinja "{{ phpipam__database_name }}"))
  (phpipam__scripts_database_password (jinja "{{ phpipam__database_password }}"))
  (phpipam__scripts_config_sections (list))
  (phpipam__scripts_config_subnets (list))
  (phpipam__scripts_config_output "/etc/dhcp/dhcpd-hosts.conf")
  (phpipam__scripts_config_restart_command "/etc/init.d/isc-dhcp-server restart")
  (phpipam__scripts_config_groups 
    (hosts 
      (sections (jinja "{{ phpipam__scripts_config_sections }}"))
      (subnets (jinja "{{ phpipam__scripts_config_subnets }}"))
      (active "true")
      (reserved "false")
      (offline "false")
      (dhcp "false")
      (output (jinja "{{ phpipam__scripts_config_output }}"))
      (restart_command (jinja "{{ phpipam__scripts_config_restart_command }}"))
      (restart "true")))
  (phpipam__scripts_cron_period "*/5")
  (phpipam__php__dependent_packages (list
      "mysql"
      "gmp"
      "gd"
      "curl"
      "mcrypt"
      "ldap"
      "php-pear"))
  (phpipam__php__dependent_pools (list
      
      (name "phpipam")
      (enabled "True")
      (user (jinja "{{ phpipam__user }}"))
      (group (jinja "{{ phpipam__group }}"))
      (owner (jinja "{{ phpipam__user }}"))
      (home (jinja "{{ phpipam__home }}"))))
  (phpipam__nginx__dependent_upstreams (list
      
      (name "php_phpipam")
      (by_role "debops.phpipam")
      (enabled "True")
      (type "php")
      (php_pool "phpipam")))
  (phpipam__nginx__dependent_servers (list
      
      (name (jinja "{{ phpipam__fqdn }}"))
      (by_role "debops.phpipam")
      (enabled "True")
      (type "php")
      (root (jinja "{{ phpipam__git_checkout }}"))
      (webroot_create "False")
      (access_policy (jinja "{{ phpipam__nginx_access_policy }}"))
      (auth_basic_realm (jinja "{{ phpipam__nginx_auth_realm }}"))
      (php_upstream "php_phpipam")
      (error_pages 
        (400 "/index.php?page=error&section=400")
        (401 "/index.php?page=error&section=401")
        (403 "/index.php?page=error&section=403")
        (404 "/index.php?page=error&section=404")
        (500 "/index.php?page=error&section=500"))
      (location 
        (/api "try_files $uri $uri/ /api/index.php?$args =404;
")
        (/ "rewrite ^/login/dashboard/$                 /dashboard/ redirect;
rewrite ^/logout/dashboard/$                /dashboard/ redirect;
rewrite ^/tools/search/(.*)/(.*)/(.*)/(.*)$ /index.php?page=tools&section=search&addresses=$1&subnets=$2&vlans=$3&ip=$4 last;
rewrite ^/(.*)/(.*)/(.*)/(.*)/(.*)/$        /index.php?page=$1&section=$2&subnetId=$3&sPage=$4&ipaddrid=$5 last;
rewrite ^/(.*)/(.*)/(.*)/(.*)/$             /index.php?page=$1&section=$2&subnetId=$3&sPage=$4 last;
rewrite ^/(.*)/(.*)/(.*)/$                  /index.php?page=$1&section=$2&subnetId=$3 last;
rewrite ^/(.*)/(.*)/$                       /index.php?page=$1&section=$2 last;
rewrite ^/(.*)/$                            /index.php?page=$1 last;
try_files $uri $uri/ $uri.html $uri.htm /index.html /index.htm =404;
"))))
  (phpipam__mariadb__dependent_users (list
      
      (database (jinja "{{ phpipam__database_name }}"))
      (user (jinja "{{ phpipam__database_user }}"))
      (owner (jinja "{{ phpipam__user }}"))
      (group (jinja "{{ phpipam__group }}"))
      (home (jinja "{{ phpipam__home }}"))
      (system "True"))))
