(playbook "debops/ansible/roles/php/defaults/main.yml"
  (php__version_preference (list
      "php7.4"
      "php7.3"
      "php"
      "php5.6"))
  (php__sury (jinja "{{ ansible_local.php.sury
                | d(ansible_distribution_release in [\"stretch\", \"trusty\", \"xenial\"]) | bool }}"))
  (php__sury_apt_key_id (jinja "{{ php__sury_apt_key_id_map[ansible_distribution] }}"))
  (php__sury_apt_repo (jinja "{{ php__sury_apt_repo_map[ansible_distribution] }}"))
  (php__sury_apt_key_id_map 
    (Debian (list
        
        (id "1505 8500 A023 5D97 F5D1  0063 B188 E2B6 95BD 4743")
        (repo "deb https://packages.sury.org/php/ " (jinja "{{ ansible_distribution_release }}") " main")
        (state (jinja "{{ \"present\" if php__sury | bool else \"absent\" }}"))
        
        (id "DF3D 585D B8F0 EB65 8690  A554 AC0E 4758 4A7A 714D")
        (state "absent")))
    (Ubuntu (list
        
        (id "14AA 40EC 0831 7567 56D7  F66C 4F4E A0AA E526 7A6C")
        (repo "ppa:ondrej/php")
        (state (jinja "{{ \"present\" if php__sury | bool else \"absent\" }}")))))
  (php__sury_apt_repo_map 
    (Debian "deb https://packages.sury.org/php/ " (jinja "{{ ansible_distribution_release }}") " main")
    (Ubuntu "ppa:ondrej/php"))
  (php__server_api_packages (list
      "cli"
      "fpm"))
  (php__base_packages (list
      (jinja "{{ \"php\" + php__version }}")
      "curl"
      "gd"
      (jinja "{{ [] if php__composer_upstream_enabled | bool else \"composer\" }}")
      (jinja "{{ \"mcrypt\"
        if (php__version is version_compare(\"7.2\", \"<\"))
        else [] }}")))
  (php__packages (list))
  (php__group_packages (list))
  (php__host_packages (list))
  (php__dependent_packages (list))
  (php__combined_packages (jinja "{{ (lookup(\"flattened\",
                             php__server_api_packages
                             + php__base_packages
                             + php__packages
                             + php__group_packages
                             + php__host_packages
                             + php__dependent_packages).split(\",\")
                            | difference(php__included_packages))
                            | join(\" \") }}"))
  (php__reset "False")
  (php__included_packages (jinja "{{ php__php_included_packages
                            if php__sury
                            else (php__release_included_map[ansible_distribution_release]
                                  | d(php__php_included_packages)) }}"))
  (php__release_included_map 
    (stretch (jinja "{{ php__php_included_packages }}"))
    (buster (jinja "{{ php__php_included_packages }}"))
    (bullseye (jinja "{{ php__php_included_packages }}"))
    (sid (jinja "{{ php__php_included_packages }}"))
    (trusty (jinja "{{ php__php5_included_packages }}"))
    (xenial (jinja "{{ php__php_included_packages }}"))
    (zesty (jinja "{{ php__php_included_packages }}"))
    (bionic (jinja "{{ php__php_included_packages }}"))
    (focal (jinja "{{ php__php_included_packages }}"))
    (groovy (jinja "{{ php__php_included_packages }}")))
  (php__php5_included_packages (jinja "{{ php__common_included_packages
                                 + [\"bcmath\", \"bz2\", \"dba\", \"dom\", \"ereg\",
                                    \"mbstring\", \"mhash\", \"SimpleXML\", \"soap\",
                                    \"wddx\", \"xml\", \"xmlreader\", \"xmlwriter\",
                                    \"zip\"] }}"))
  (php__php_included_packages (jinja "{{ php__common_included_packages
                                + [\"sysvsem\", \"sysvshm\"] }}"))
  (php__common_included_packages (list
      "calendar"
      "ctype"
      "date"
      "exif"
      "fileinfo"
      "filter"
      "ftp"
      "gettext"
      "hash"
      "iconv"
      "libxml"
      "openssl"
      "pcntl"
      "pcre"
      "PDO"
      "Phar"
      "posix"
      "Reflection"
      "session"
      "shmop"
      "sockets"
      "SPL"
      "standard"
      "sysvmsg"
      "tokenizer"
      "zlib"))
  (php__composer_upstream_enabled (jinja "{{ True
                                    if (ansible_distribution_release in
                                        [\"stretch\", \"trusty\", \"xenial\",
                                         \"bionic\", \"focal\"])
                                    else False }}"))
  (php__composer_upstream_version "1.8.5")
  (php__composer_upstream_checksum "sha256:23b29b1a921b56db3c12ba531752dffcfaa3de0fcece3e54974e06990e46bbf9")
  (php__composer_upstream_url (jinja "{{ \"https://github.com/composer/composer/releases/download/\"
                                + php__composer_upstream_version + \"/composer.phar\" }}"))
  (php__composer_upstream_dest "/usr/local/bin/composer")
  (php__production "True")
  (php__ini_cgi_fix_pathinfo "False")
  (php__ini_max_execution_time "30")
  (php__ini_max_input_time "60")
  (php__ini_memory_limit "128M")
  (php__ini_post_max_size "8M")
  (php__ini_file_uploads "True")
  (php__ini_upload_max_filesize (jinja "{{ php__ini_post_max_size }}"))
  (php__ini_max_file_uploads "20")
  (php__ini_default_charset "UTF-8")
  (php__ini_allow_url_fopen "True")
  (php__ini_date_timezone (jinja "{{ ansible_local.tzdata.timezone | d(\"Etc/UTC\") }}"))
  (php__default_configuration (list
      
      (filename "00-ansible")
      (name "PHP")
      (sections (list
          
          (options "max_execution_time =     " (jinja "{{ php__ini_max_execution_time }}") "
max_input_time =         " (jinja "{{ php__ini_max_input_time }}") "
memory_limit =           " (jinja "{{ php__ini_memory_limit }}") "
error_reporting =        " (jinja "{{ (php__production | bool) | ternary('E_ALL & ~E_DEPRECATED & ~E_STRICT', 'E_ALL') }}") "
display_errors =         " (jinja "{{ (php__production | bool) | ternary('Off', 'On') }}") "
display_startup_errors = " (jinja "{{ (php__production | bool) | ternary('Off', 'On') }}") "
" (jinja "{% if php__version is version_compare(\"7.2\", \"<\") %}") "
track_errors =           " (jinja "{{ (php__production | bool) | ternary('Off', 'On') }}") "
" (jinja "{% endif %}") "
post_max_size =          " (jinja "{{ php__ini_post_max_size }}") "
default_charset =        " (jinja "{{ php__ini_default_charset }}") "
file_uploads =           " (jinja "{{ (php__ini_file_uploads | bool) | ternary('On', 'Off') }}") "
upload_max_filesize =    " (jinja "{{ php__ini_upload_max_filesize }}") "
max_file_uploads =       " (jinja "{{ php__ini_max_file_uploads }}") "
allow_url_fopen =        " (jinja "{{ (php__ini_allow_url_fopen | bool) | ternary('On', 'Off') }}") "
")
          
          (name "CGI")
          (options "cgi.fix_pathinfo =       " (jinja "{{ (php__ini_cgi_fix_pathinfo | bool) | ternary('1', '0') }}") "
")
          
          (name "Date")
          (options "date.timezone =          " (jinja "{{ php__ini_date_timezone }}") "
")))
      
      (filename "../cli/conf.d/30-memory_limit")
      (name "PHP")
      (options "; Don't limit memory for php-cli execution
memory_limit = -1
")))
  (php__configuration (list))
  (php__group_configuration (list))
  (php__host_configuration (list))
  (php__dependent_configuration (list))
  (php__fpm_privileged_group "webadmins")
  (php__fpm_syslog "False")
  (php__fpm_error_log (jinja "{{ (\"/var/log/php\" + php__version + \"-fpm.log\")
                        if not php__fpm_syslog | bool else \"syslog\" }}"))
  (php__fpm_syslog_ident "php-fpm")
  (php__fpm_syslog_facility "daemon")
  (php__fpm_log_level "notice")
  (php__fpm_emergency_restart_threshold "0")
  (php__fpm_emergency_restart_interval "0")
  (php__fpm_process_control_timeout "0")
  (php__fpm_process_max "128")
  (php__fpm_listen_owner "www-data")
  (php__fpm_listen_group "www-data")
  (php__fpm_listen_mode "0660")
  (php__fpm_listen_backlog "511")
  (php__fpm_pm "ondemand")
  (php__fpm_pm_max_children (jinja "{{ ansible_processor_vcpus }}"))
  (php__fpm_pm_start_servers (jinja "{{ ansible_processor_cores }}"))
  (php__fpm_pm_min_spare_servers "1")
  (php__fpm_pm_max_spare_servers (jinja "{{ php__fpm_pm_max_children }}"))
  (php__fpm_pm_process_idle_timeout "10s")
  (php__fpm_pm_max_requests "500")
  (php__fpm_pm_status "False")
  (php__fpm_pm_status_path "/status.php")
  (php__fpm_ping_path "/ping.php")
  (php__fpm_ping_response "pong")
  (php__fpm_access_log "False")
  (php__fpm_request_terminate_timeout (jinja "{{ php__ini_max_execution_time }}"))
  (php__fpm_rlimit_files "1024")
  (php__fpm_rlimit_core "0")
  (php__fpm_catch_workers_output "False")
  (php__fpm_security_limit_extensions (list
      ".php"))
  (php__fpm_clear_env "False")
  (php__fpm_environment )
  (php__fpm_group_environment )
  (php__fpm_host_environment )
  (php__default_pools (list
      (jinja "{{ php__pool_www_data }}")))
  (php__pools (list))
  (php__group_pools (list))
  (php__host_pools (list))
  (php__dependent_pools (list))
  (php__pool_www_data 
    (name "www-data"))
  (php__apt_preferences__dependent_list (list
      
      (package "*")
      (pin "origin \"packages.sury.org\"")
      (priority "100")
      (reason "Don't upgrade software automatically using packages from external repository")
      (role "debops.php")
      (suffix "_packages_sury_org")
      (state (jinja "{{ \"present\" if php__sury | bool else \"absent\" }}"))
      
      (packages (list
          "php"
          "php5"
          "php5*"
          "php7*"
          "dh-php"
          "php-*"
          "libpcre2-8-0"
          "libpcre3"
          "libzip4"
          "libpcre16-3"
          "libpcre32-3"
          "libpcrecpp0v5"
          "libpcre3-dev"
          "libapache2-mod-php"
          "libapache2-mod-php*"
          "libsodium23"))
      (pin "origin \"packages.sury.org\"")
      (priority "500")
      (reason "Prefer PHP packages from the same repository for consistency")
      (role "debops.php")
      (suffix "_packages_sury_org")
      (state (jinja "{{ \"present\" if php__sury | bool else \"absent\" }}"))))
  (php__keyring__dependent_apt_keys (list
      (jinja "{{ php__sury_apt_key_id }}")))
  (php__logrotate__dependent_config (list
      
      (filename "php" (jinja "{{ php__version }}") "-fpm")
      (divert "True")
      (logs (list
          "/var/log/php" (jinja "{{ php__version }}") "-fpm.log"
          "/var/log/php" (jinja "{{ php__version }}") "-fpm/*.log"))
      (options "create 0660 root adm
rotate 12
missingok
weekly
notifempty
compress
delaycompress
")
      (postrotate (jinja "{% if php__long_version is version_compare(\"5.5\", \"<\") %}") "
invoke-rc.d php" (jinja "{{ php__version }}") "-fpm reopen-logs > /dev/null
" (jinja "{% else %}") "
" (jinja "{{ php__logrotate_lib_base }}") "/php" (jinja "{{ php__version }}") "-fpm-reopenlogs
" (jinja "{% endif %}") "
"))))
