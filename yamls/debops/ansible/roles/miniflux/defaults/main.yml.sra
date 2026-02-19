(playbook "debops/ansible/roles/miniflux/defaults/main.yml"
  (miniflux__domain (jinja "{{ ansible_domain }}"))
  (miniflux__fqdn "miniflux." (jinja "{{ miniflux__domain }}"))
  (miniflux__bind "127.0.0.1")
  (miniflux__port "3366")
  (miniflux__user "miniflux")
  (miniflux__group "miniflux")
  (miniflux__gecos "Miniflux")
  (miniflux__shell "/usr/sbin/nologin")
  (miniflux__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                    + \"/\" + miniflux__user }}"))
  (miniflux__database_host (jinja "{{ ansible_local.postgresql.server | d(\"localhost\") }}"))
  (miniflux__database_port (jinja "{{ ansible_local.postgresql.port | d(\"5432\") }}"))
  (miniflux__database_name "miniflux_production")
  (miniflux__database_user "miniflux")
  (miniflux__database_password (jinja "{{ lookup(\"password\", secret + \"/postgresql/\" +
                                    (ansible_local.postgresql.delegate_to | d(\"localhost\")) + \"/\" +
                                    (ansible_local.postgresql.port | d(\"5432\")) + \"/credentials/\" +
                                    miniflux__database_user + \"/password\") }}"))
  (miniflux__upstream_gpg_key "5A7A 89AC F055 24CA A0F3  6F9B AEB7 A164 0710 8DB5")
  (miniflux__upstream_type "apt")
  (miniflux__upstream_version "2.0.35")
  (miniflux__upstream_url_mirror "https://github.com/miniflux/v2/releases/")
  (miniflux__upstream_platform "linux-amd64")
  (miniflux__upstream_git_repository "https://github.com/miniflux/miniflux")
  (miniflux__binary (jinja "{{ ansible_local.golang.binaries[\"miniflux\"]
                      if (ansible_local.golang.binaries | d() and
                          ansible_local.golang.binaries.miniflux | d())
                      else \"\" }}"))
  (miniflux__default_configuration (list
      
      (name "run_migrations")
      (value "True")
      
      (name "database_url")
      (value (jinja "{{ \"postgres://\" + miniflux__database_user
               + \":\" + miniflux__database_password
               + \"@\" + miniflux__database_host
               + \":\" + miniflux__database_port
               + \"/\" + miniflux__database_name }}"))
      
      (name "listen_addr")
      (value (jinja "{{ miniflux__bind + \":\" + miniflux__port }}"))
      
      (name "base_url")
      (value (jinja "{{ \"https://\" + miniflux__fqdn }}"))))
  (miniflux__configuration (list))
  (miniflux__group_configuration (list))
  (miniflux__host_configuration (list))
  (miniflux__combined_configuration (jinja "{{ miniflux__default_configuration
                                      + miniflux__configuration
                                      + miniflux__group_configuration
                                      + miniflux__host_configuration }}"))
  (miniflux__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ miniflux__upstream_gpg_key }}"))
      (url "https://apt.miniflux.app/KEY.gpg")
      (repo "deb https://apt.miniflux.app/ /")
      (state (jinja "{{ \"present\"
               if (miniflux__upstream_type == \"apt\")
               else \"absent\" }}"))))
  (miniflux__postgresql__dependent_roles (list
      
      (name (jinja "{{ miniflux__database_user }}"))
      
      (name (jinja "{{ miniflux__database_name }}"))
      (flags (list
          "NOLOGIN"))))
  (miniflux__postgresql__dependent_groups (list
      
      (roles (list
          (jinja "{{ miniflux__database_user }}")))
      (groups (list
          (jinja "{{ miniflux__database_name }}")))
      (database (jinja "{{ miniflux__database_name }}"))))
  (miniflux__postgresql__dependent_databases (list
      
      (name (jinja "{{ miniflux__database_name }}"))
      (owner (jinja "{{ miniflux__database_name }}"))))
  (miniflux__postgresql__dependent_pgpass (list
      
      (owner (jinja "{{ miniflux__user }}"))
      (group (jinja "{{ miniflux__group }}"))
      (home (jinja "{{ miniflux__home }}"))
      (system "True")))
  (miniflux__postgresql__dependent_extensions (list
      
      (database (jinja "{{ miniflux__database_name }}"))
      (extension "hstore")))
  (miniflux__golang__dependent_packages (list
      
      (name "miniflux")
      (upstream_type (jinja "{{ miniflux__upstream_type }}"))
      (apt_packages (list
          "miniflux"))
      (gpg (list
          
          (id (jinja "{{ miniflux__upstream_gpg_key }}"))
          (url "https://apt.miniflux.app/KEY.gpg")))
      (url (list
          
          (src (jinja "{{ miniflux__upstream_url_mirror + \"download/\" + miniflux__upstream_version + \"/miniflux-\" + miniflux__upstream_platform }}"))
          (dest "releases/" (jinja "{{ miniflux__upstream_platform }}") "/miniflux/miniflux/\" + miniflux__upstream_version + \"/miniflux_\" + miniflux__upstream_version + \"_linux_amd64")))
      (url_binaries (list
          
          (src "releases/" (jinja "{{ miniflux__upstream_platform }}") "/miniflux/miniflux/\" + miniflux__upstream_version + \"/miniflux_\" + miniflux__upstream_version + \"_linux_amd64")
          (dest "miniflux")
          (notify (list
              "Restart miniflux"))))
      (git (list
          
          (repo (jinja "{{ miniflux__upstream_git_repository }}"))
          (version (jinja "{{ miniflux__upstream_version }}"))
          (build_script "make clean linux-amd64
")))
      (git_binaries (list
          
          (src "github.com/miniflux/v2/bin/miniflux.app")
          (dest "miniflux")
          (notify (list
              "Restart miniflux"))))))
  (miniflux__nginx__dependent_upstreams (list
      
      (name "miniflux-upstream")
      (server (jinja "{{ miniflux__bind }}") ":" (jinja "{{ miniflux__port }}"))))
  (miniflux__nginx__dependent_servers (list
      
      (name (jinja "{{ miniflux__fqdn }}"))
      (by_role "debops.miniflux")
      (filename "debops.miniflux")
      (type "proxy")
      (proxy_location "/")
      (proxy_headers "True")
      (proxy_options "proxy_redirect off;
")
      (proxy_pass "http://miniflux-upstream")))
  (miniflux__etc_services__dependent_list (list
      
      (name "miniflux")
      (port (jinja "{{ miniflux__port }}")))))
