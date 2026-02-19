(playbook "debops/ansible/roles/nginx/defaults/main.yml"
  (nginx__deploy_state "present")
  (nginx_base_packages (list))
  (nginx_flavor "full")
  (nginx__flavor_distribution_release (jinja "{{ ansible_local.core.distribution_release
                                         | d(ansible_distribution_release) }}"))
  (nginx__flavor_apt_key_id (jinja "{{ nginx__flavor_apt_key_id_map[nginx_flavor] | d() }}"))
  (nginx__flavor_apt_repository (jinja "{{ nginx__flavor_apt_repository_map[nginx_flavor] | d() }}"))
  (nginx__flavor_apt_key_id_map 
    (nginx.org "573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62")
    (passenger "16378A33A6EF16762922526E561F9B9CAC40B2F7"))
  (nginx__flavor_apt_repository_map 
    (nginx.org "deb https://nginx.org/packages/" (jinja "{{ ansible_distribution | lower }}") "/ " (jinja "{{ nginx__flavor_distribution_release }}") " nginx")
    (passenger "deb https://oss-binaries.phusionpassenger.com/apt/passenger " (jinja "{{ nginx__flavor_distribution_release }}") " main"))
  (nginx__flavor_packages (jinja "{{ nginx_flavor_package_map[nginx_flavor] }}"))
  (nginx_flavor_package_map 
    (full (list
        "nginx-full"))
    (light (list
        "nginx-light"))
    (extras (list
        "nginx-extras"))
    (passenger (list
        "nginx-extras"
        "ruby"
        (jinja "{{ \"passenger\"
          if (nginx__flavor_distribution_release in
              [\"trusty\", \"xenial\"])
          else \"libnginx-mod-http-passenger\" }}")))
    (nginx.org (list
        "nginx")))
  (nginx_user "www-data")
  (nginx_www "/srv/www")
  (nginx_public_dir_name "public")
  (nginx_etc_path "/etc/nginx")
  (nginx_private_path (jinja "{{ nginx_etc_path + \"/private\" }}"))
  (nginx_run_path "/run")
  (nginx_log_path (jinja "{{ \"unix:/dev/log\" if nginx_log_to_syslog else \"/var/log/nginx\" }}"))
  (nginx_log_to_syslog "False")
  (nginx_syslog_config "nohostname")
  (nginx_passenger_root "")
  (nginx_passenger_ruby "")
  (nginx_passenger_max_pool_size (jinja "{{ (ansible_processor_cores | int * 5) }}"))
  (nginx_passenger_options "False")
  (nginx_passenger_default_min_instances (jinja "{{ ansible_processor_cores }}"))
  (nginx_http_allow (list))
  (nginx_http_auth_basic (jinja "{{ nginx_http_auth_users }}"))
  (nginx_http_auth_basic_name "nginx_http")
  (nginx_http_auth_users (list))
  (nginx__http_auth_htpasswd 
    (name (jinja "{{ nginx_http_auth_basic_name }}"))
    (users (jinja "{{ nginx_http_auth_users }}")))
  (nginx_http_server_names_hash_bucket_size "64")
  (nginx_http_server_names_hash_max_size "512")
  (nginx_http_options "ssl_session_cache shared:SSL:10m;
ssl_session_timeout 5m;
sendfile on;
tcp_nopush on;
tcp_nodelay on;
types_hash_max_size 2048;
gzip on;
gzip_disable \"msie6\";
gzip_comp_level    5;
gzip_min_length    256;
gzip_proxied       any;
gzip_vary          on;
gzip_types
  application/atom+xml
  application/javascript
  application/json
  application/ld+json
  application/manifest+json
  application/rss+xml
  application/vnd.geo+json
  application/vnd.ms-fontobject
  application/x-font-ttf
  application/x-web-app-manifest+json
  application/xhtml+xml
  application/xml
  font/opentype
  image/bmp
  image/svg+xml
  image/x-icon
  text/cache-manifest
  text/css
  text/plain
  text/vnd.rim.location.xloc
  text/vtt
  text/x-component
  text/x-cross-domain-policy;
")
  (nginx_http_extra_options "")
  (nginx_extra_options "")
  (nginx_manage_ipv6only "True")
  (nginx_listen_port (list
      "[::]:80"))
  (nginx_listen_ssl_port (list
      "[::]:443"))
  (nginx_listen_socket (list))
  (nginx_listen_ssl_socket (list))
  (nginx_real_ip_from (list))
  (nginx_real_ip_header "X-Forwarded-For")
  (nginx_real_ip_recursive "False")
  (nginx_default_keepalive_timeout "60")
  (nginx_multi_accept "off")
  (nginx_pki (jinja "{{ ansible_local | d() and ansible_local.pki | d() and
               (ansible_local.pki.enabled | d() | bool) }}"))
  (nginx_pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (nginx_pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (nginx_pki_ca_realm (jinja "{{ ansible_local.pki.ca_realm | d(\"domain\") }}"))
  (nginx_pki_crt "default.crt")
  (nginx_pki_key "default.key")
  (nginx_pki_ca "CA.crt")
  (nginx_pki_trusted "trusted.crt")
  (nginx_pki_hook_name "nginx")
  (nginx_pki_hook_path (jinja "{{ ansible_local.pki.hooks | d(\"/etc/pki/hooks\") }}"))
  (nginx_pki_hook_action "reload")
  (nginx_ssl_dhparam (jinja "{{ (\"\"
                        if nginx_default_tls_protocols | length == 1 and
                           nginx_default_tls_protocols[0] == \"TLSv1.3\"
                        else
                           (ansible_local.dhparam[nginx_ssl_dhparam_set]
                            if (ansible_local | d() and ansible_local.dhparam | d() and
                                ansible_local.dhparam[nginx_ssl_dhparam_set] | d())
                            else \"\")) }}"))
  (nginx_ssl_dhparam_set "default")
  (nginx_default_ssl_ciphers (jinja "{{ \"mozilla_modern\"
                               if nginx_default_tls_protocols | length == 1 and
                                  nginx_default_tls_protocols[0] == \"TLSv1.3\"
                               else \"mozilla_intermediate\" }}"))
  (nginx_default_tls_protocols (jinja "{{ [\"TLSv1.2\", \"TLSv1.3\"]
                                 if ansible_local.nginx.version | d(\"0.0.0\") is version(\"1.13.0\", \">=\")
                                 else [\"TLSv1.2\"] }}"))
  (nginx_default_ssl_curve "secp384r1")
  (nginx_default_ssl_verify_client "False")
  (nginx_default_ssl_client_certificate "")
  (nginx_default_ssl_crl "")
  (nginx_ocsp "True")
  (nginx_ocsp_verify (jinja "{{ nginx_ocsp | bool }}"))
  (nginx_ocsp_resolvers (list))
  (nginx_hsts_age (jinja "{{ 2 * 365 * 24 * 60 * 60 }}"))
  (nginx_hsts_subdomains "True")
  (nginx_hsts_preload "False")
  (nginx_enable_http2 "True")
  (nginx__http_csp_append "")
  (nginx_default_name "")
  (nginx_default_ssl_name "")
  (nginx_default_type "default")
  (nginx_webroot_create "True")
  (nginx_webroot_owner "root")
  (nginx_webroot_group "root")
  (nginx_webroot_mode "0755")
  (nginx_welcome_template "srv/www/sites/welcome/public/index.html.j2")
  (nginx_welcome_domain (jinja "{{ ansible_domain }}"))
  (nginx_acme "True")
  (nginx_acme_root (jinja "{{ nginx_www + \"/sites/acme/public\" }}"))
  (nginx_acme_server "False")
  (nginx_acme_domain "acme." (jinja "{{ ansible_domain }}"))
  (nginx__hostname_domains (list
      (jinja "{{ ansible_domain }}")))
  (nginx_status (list))
  (nginx_status_localhost (jinja "{{ [\"127.0.0.1/32\", \"::1/128\"] + ansible_all_ipv4_addresses | d([]) +
                            (ansible_all_ipv6_addresses | d([])
                             | difference(ansible_all_ipv6_addresses | d([])
                             | ansible.utils.ipaddr(\"link-local\"))) }}"))
  (nginx_status_name "/nginx_status")
  (nginx_local_servers )
  (nginx_default_satisfy "any")
  (nginx_default_auth_basic_realm "Access to this website is restricted")
  (nginx_htpasswd_secret_path (jinja "{{ secret + \"/credentials/\" + inventory_hostname + \"/nginx/htpasswd\" }}"))
  (nginx__htpasswd_crypt_scheme "sha512_crypt")
  (nginx__htpasswd_password_length "32")
  (nginx__htpasswd_password_characters "ascii_letters,digits,.-_~&()*=")
  (nginx__htpasswd (list))
  (nginx__default_htpasswd (list
      (jinja "{{ nginx__http_auth_htpasswd }}")))
  (nginx__dependent_htpasswd (list))
  (nginx_access_policy_allow_map )
  (nginx_access_policy_auth_basic_map )
  (nginx_access_policy_satisfy_map )
  (nginx__maps (list))
  (nginx__default_maps (list
      
      (name "host_without_local")
      (map "$host $host_without_local")
      (mapping "~*^(?<subdomain>[a-zA-Z0-9\\-\\_\\.]+)\\.local$ $subdomain;")
      
      (name "connection_upgrade")
      (map "$http_upgrade $connection_upgrade")
      (mapping "''      Close;
")
      (default "Upgrade")))
  (nginx__dependent_maps (list))
  (nginx__upstreams (list))
  (nginx__default_upstreams (list
      (jinja "{{ nginx_upstream_php5_www_data }}")))
  (nginx__dependent_upstreams (list))
  (nginx_upstream_php5_www_data 
    (state "absent")
    (name "php5_www-data")
    (type "php5")
    (php5 "www-data"))
  (nginx__servers (list))
  (nginx__default_servers (list
      (jinja "{{ nginx_server_welcome }}")))
  (nginx__internal_servers (list
      (jinja "{{ nginx_server_localhost }}")
      (jinja "{{ nginx_server_acme }}")))
  (nginx__dependent_servers (list))
  (nginx_server_welcome 
    (enabled "True")
    (name (list
        "welcome"))
    (welcome "True")
    (welcome_domain (jinja "{{ nginx_welcome_domain }}"))
    (csp "default-src 'none'; style-src 'self' 'unsafe-inline'; img-src 'self';")
    (csp_enabled "True"))
  (nginx_server_localhost 
    (enabled "True")
    (name (list
        "localhost"
        "127.0.0.1"
        "[::1]"))
    (acme "False")
    (ssl "False")
    (welcome "True")
    (welcome_css "False"))
  (nginx_server_acme 
    (enabled (jinja "{{ nginx_acme_server | bool }}"))
    (delete (jinja "{{ not nginx_acme_server | bool }}"))
    (name (list
        (jinja "{{ nginx_acme_domain }}")))
    (filename "acme-challenge")
    (root (jinja "{{ nginx_acme_root }}")))
  (nginx_default_try_files (list
      "$uri"
      "$uri/"
      "$uri.html"
      "$uri.htm"
      "$uri/index.html"))
  (nginx__log_format (list))
  (nginx__dependent_log_format (list))
  (nginx__custom_config (list))
  (nginx__http_xss_protection "1; mode=block")
  (nginx__http_referrer_policy "same-origin")
  (nginx__http_permitted_cross_domain_policies (jinja "{{ omit }}"))
  (nginx__http_robots_tag (jinja "{{ omit }}"))
  (nginx_apt_preferences_dependent_list (jinja "{{ nginx__apt_preferences__dependent_list }}"))
  (nginx__apt_preferences__dependent_list (list
      
      (package "nginx nginx-*")
      (pin "release o=Phusion")
      (reason "Support for Phusion Passenger")
      (priority "600")
      (suffix "_passenger")
      (by_role "debops.nginx")
      (state (jinja "{{ ((nginx__deploy_state in [\"present\"]) and (nginx_flavor in [\"passenger\"])) | ternary(\"present\", \"absent\") }}"))))
  (nginx_php5_status "False")
  (nginx_php5_status_name "php5_status")
  (nginx_php5_ping_name "php5_ping")
  (nginx_privileged_group "webadmins")
  (nginx_ssl_ciphers 
    (bettercrypto_org__set_a "EDH+aRSA+AES256:EECDH+aRSA+AES256:!SSLv3")
    (bettercrypto_org__set_b "EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA256:EECDH:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA128-SHA:AES128-SHA")
    (bettercrypto_org__set_b_pfs "EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA256:EECDH:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH")
    (cipherli_st "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH")
    (pfs "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4")
    (pfs_rc4 "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS")
    (hardened "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS")
    (mozilla "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:ECDHE-RSA-RC4-SHA:ECDHE-ECDSA-RC4-SHA:AES128:AES256:RC4-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK")
    (mozilla_modern "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384")
    (mozilla_intermediate "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384")
    (mozilla_old "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA")
    (fips "FIPS@STRENGTH:!aNULL:!eNULL")
    (ncsc_nl "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-GCM-SHA256")
    (default ""))
  (nginx_allow (list))
  (nginx_group_allow (list))
  (nginx_host_allow (list))
  (nginx_ferm_dependent_rules (jinja "{{ nginx__ferm__dependent_rules }}"))
  (nginx__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "http"
          "https"))
      (saddr (jinja "{{ nginx_allow + nginx_group_allow + nginx_host_allow }}"))
      (accept_any "True")
      (weight "40")
      (by_role "nginx")
      (name "http_https")
      (multiport "True")
      (delete (jinja "{{ nginx__deploy_state != \"present\" }}"))))
  (nginx__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ nginx__flavor_apt_key_id }}"))
      (repo (jinja "{{ nginx__flavor_apt_repository }}"))
      (state (jinja "{{ \"present\"
               if (nginx_flavor in [\"nginx.org\", \"passenger\"] and
                   nginx__deploy_state == \"present\")
               else \"absent\" }}"))))
  (nginx__python__dependent_packages3 (list
      "python3-passlib"))
  (nginx__python__dependent_packages2 (list
      "python-passlib")))
