(playbook "debops/ansible/roles/homeassistant/defaults/main.yml"
  (homeassistant__base_packages (list
      "libffi-dev"
      "libssl-dev"
      "libjpeg-dev"
      "zlib1g-dev"
      "autoconf"
      "build-essential"
      "libopenjp2-7"
      "libtiff5"
      (jinja "{{ \"libturbojpeg\"
        if (ansible_distribution == \"Ubuntu\")
        else \"libturbojpeg0\" }}")
      "tzdata"))
  (homeassistant__packages (list))
  (homeassistant__dependency_python_packages (list
      "python3-dev"
      "python3-venv"
      "python3-pip"
      "python3-virtualenv"
      "python3-requests"
      "python3-yaml"
      "python3-tz"
      "python3-jinja2"
      "python3-voluptuous"
      (jinja "{{ [\"python3-aiohttp\"]
        if (ansible_distribution_release not in [\"trusty\"])
        else [] }}")
      (jinja "{{ [\"python3-async-timeout\"]
        if (ansible_distribution == \"Debian\" and ansible_distribution_major_version | int >= 9)
        else [] }}")
      "python3-chardet"))
  (homeassistant__optional_python_packages (list
      (jinja "{{ [\"python3-colorlog\"]
        if (ansible_distribution_release not in [\"trusty\"])
        else [] }}")
      "libffi-dev"
      "libssl-dev"
      "python3-crypto"
      "python3-cryptography"
      "python3-pyparsing"
      "python3-appdirs"))
  (homeassistant__combined_packages (jinja "{{ (homeassistant__base_packages
                                       + homeassistant__packages
                                       + (homeassistant__dependency_python_packages
                                          if (not homeassistant__virtualenv | bool)
                                          else [])
                                       + (homeassistant__optional_python_packages
                                          if (not homeassistant__virtualenv | bool)
                                          else []))
                                      | unique | sort }}"))
  (homeassistant__deploy_state "present")
  (homeassistant__fqdn "ha." (jinja "{{ homeassistant__domain }}"))
  (homeassistant__domain (jinja "{{ ansible_domain }}"))
  (homeassistant__verify_client_certificate "False")
  (homeassistant__basic_auth "False")
  (homeassistant__basic_auth_realm "Home Assistant")
  (homeassistant__basic_auth_name "homeassistant")
  (homeassistant__basic_auth_users (jinja "{{ ansible_local.core.admin_users | d([]) }}"))
  (homeassistant__webserver_user (jinja "{{ ansible_local.nginx.user | d(\"www-data\") }}"))
  (homeassistant__home_path (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                              + \"/\" + homeassistant__user }}"))
  (homeassistant__virtualenv_path (jinja "{{ homeassistant__home_path + \"/prod_venv\" }}"))
  (homeassistant__user "homeassistant")
  (homeassistant__group "homeassistant")
  (homeassistant__groups (list
      "dialout"))
  (homeassistant__gecos "Home Assistant")
  (homeassistant__shell "/usr/sbin/nologin")
  (homeassistant__virtualenv "True")
  (homeassistant__release_channel "release")
  (homeassistant__git_repo "https://github.com/home-assistant/home-assistant.git")
  (homeassistant__git_version (jinja "{{ \"master\" if (homeassistant__release_channel in [\"release\"]) else \"dev\" }}"))
  (homeassistant__git_dest (jinja "{{ homeassistant__home_path + \"/home-assistant\" }}"))
  (homeassistant__git_recursive "True")
  (homeassistant__git_depth (jinja "{{ omit }}"))
  (homeassistant__git_update "True")
  (homeassistant__daemon_path (jinja "{{ (homeassistant__home_path + \"/prod_venv/bin/hass\")
                                if (homeassistant__virtualenv | bool)
                                else (homeassistant__home_path + \"/.local/bin/hass\") }}"))
  (homeassistant__nginx__dependent_upstreams (list
      
      (name "homeassistant")
      (type "default")
      (state (jinja "{{ \"present\" if (homeassistant__deploy_state == \"present\") else \"absent\" }}"))
      (enabled "True")
      (server "localhost:8123")))
  (homeassistant__nginx__dependent_htpasswd 
    (name (jinja "{{ homeassistant__basic_auth_name }}"))
    (users (jinja "{{ homeassistant__basic_auth_users }}")))
  (homeassistant__nginx__dependent_servers (list
      
      (name (jinja "{{ homeassistant__fqdn }}"))
      (filename "debops.homeassistant")
      (by_role "debops-contrib.homeassistant")
      (state (jinja "{{ \"present\" if (homeassistant__deploy_state == \"present\") else \"absent\" }}"))
      (type "proxy")
      (ssl_verify_client (jinja "{{ homeassistant__verify_client_certificate | bool }}"))
      (auth_basic (jinja "{{ homeassistant__basic_auth | bool }}"))
      (auth_basic_realm (jinja "{{ homeassistant__basic_auth_realm }}"))
      (auth_basic_name (jinja "{{ homeassistant__basic_auth_name }}"))
      (options "proxy_buffering off;

location /local/ {
        autoindex off;
        alias " (jinja "{{ homeassistant__home_path }}") "/www/;
}
location /local_brands/ {
        rewrite /local_brands/(.*) /$1  break;

        proxy_pass https://brands.home-assistant.io/;

        proxy_set_header Host brands.home-assistant.io;
        proxy_ssl_verify on;
        proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
        proxy_ssl_server_name on;

        # Aggressively cache files on disk.
        proxy_buffering on;
        proxy_cache brands;
        # Exclude $scheme$proxy_host from key to ease testing with different proxy_pass.
        proxy_cache_key $request_uri;
        proxy_cache_lock on;

        # This might end up serving place holder files for 6 months.
        # Ref: https://github.com/home-assistant/brands#caching
        proxy_cache_valid 6M;

        proxy_cache_valid 404 60m;
        proxy_method GET;
        proxy_pass_request_body off;
        proxy_cache_use_stale error timeout http_500 http_502 http_503 http_504;
        proxy_cache_bypass $http_pragma;
        add_header X-Cache-Status $upstream_cache_status;
}
")
      (proxy_pass "http://homeassistant")
      (proxy_options "proxy_redirect http:// https://;
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $connection_upgrade;
"))))
