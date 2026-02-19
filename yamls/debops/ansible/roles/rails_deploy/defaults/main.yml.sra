(playbook "debops/ansible/roles/rails_deploy/defaults/main.yml"
  (rails_deploy_dependencies (list
      "database"
      "redis"
      "nginx"
      "ruby"
      "monit"))
  (rails_deploy_packages (list
      (jinja "{{ rails_deploy_database_package }}")))
  (rails_deploy_user_groups (list))
  (rails_deploy_user_sshkey (jinja "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"))
  (rails_deploy_hosts_group "debops_rails_deploy")
  (rails_deploy_hosts_master (jinja "{{ groups[rails_deploy_hosts_group][0] }}"))
  (rails_deploy_git_location "")
  (rails_deploy_git_version "master")
  (rails_deploy_git_remote "origin")
  (rails_deploy_git_access_token "False")
  (rails_deploy_service (jinja "{{ rails_deploy_git_location | basename | replace('.git', '') }}"))
  (rails_deploy_home "/var/local/" (jinja "{{ rails_deploy_service }}"))
  (rails_deploy_src (jinja "{{ rails_deploy_home }}") "/" (jinja "{{ rails_deploy_nginx_domains[0] }}") "/" (jinja "{{ rails_deploy_service }}") "/src")
  (rails_deploy_system_env "production")
  (rails_deploy_bundle_without (list
      "development"
      "staging"
      "production"
      "test"))
  (rails_deploy_service_timeout "60")
  (rails_deploy_backend "unicorn")
  (rails_deploy_backend_bind (jinja "{{ rails_deploy_service_socket }}"))
  (rails_deploy_backend_state "started")
  (rails_deploy_backend_enabled "True")
  (rails_deploy_backend_always_restart "False")
  (rails_deploy_database_create "True")
  (rails_deploy_database_prepare "True")
  (rails_deploy_database_migrate "True")
  (rails_deploy_database_force_migrate "False")
  (rails_deploy_database_adapter "postgresql")
  (rails_deploy_postgresql_cluster "9.1/main")
  (rails_deploy_database_host (jinja "{{ ansible_fqdn }}"))
  (rails_deploy_database_port "5432")
  (rails_deploy_postgresql_super_username "postgres")
  (rails_deploy_mysql_super_username "mysql")
  (rails_deploy_database_user_role_attrs "")
  (rails_deploy_database_pool "25")
  (rails_deploy_database_timeout "5000")
  (rails_deploy_worker_enabled "False")
  (rails_deploy_worker_state "started")
  (rails_deploy_worker "sidekiq")
  (rails_deploy_worker_host (jinja "{{ ansible_fqdn }}"))
  (rails_deploy_worker_port "6379")
  (rails_deploy_worker_url "redis://" (jinja "{{ rails_deploy_worker_host }}") ":" (jinja "{{ rails_deploy_worker_port }}") "/0")
  (rails_deploy_pre_migrate_shell_commands (list))
  (rails_deploy_post_migrate_shell_commands (list
      "bundle exec rake assets:precompile"
      "rm -rf tmp/cache"))
  (rails_deploy_post_restart_shell_commands (list))
  (rails_deploy_extra_services (list))
  (rails_deploy_logrotate_interval "weekly")
  (rails_deploy_logrotate_rotation "24")
  (rails_deploy_default_env 
    (RAILS_ENV (jinja "{{ rails_deploy_system_env }}"))
    (DATABASE_URL (jinja "{{ rails_deploy_database_adapter }}") "://" (jinja "{{ rails_deploy_service }}") ":" (jinja "{{ rails_deploy_database_user_password }}") "@" (jinja "{{ rails_deploy_database_host }}") ":" (jinja "{{ rails_deploy_database_port }}") "/" (jinja "{{ rails_deploy_service }}") "_" (jinja "{{ rails_deploy_system_env }}") "?pool=" (jinja "{{ rails_deploy_database_pool }}") "&timeout=" (jinja "{{ rails_deploy_database_timeout }}"))
    (SERVICE (jinja "{{ rails_deploy_service }}"))
    (LOG_FILE (jinja "{{ rails_deploy_log }}") "/" (jinja "{{ rails_deploy_service }}") ".log")
    (RUN_STATE_PATH (jinja "{{ rails_deploy_run }}"))
    (LISTEN_ON (jinja "{{ rails_deploy_backend_bind }}"))
    (THREADS_MIN "0")
    (THREADS_MAX "16")
    (WORKERS "2")
    (BACKGROUND_URL (jinja "{{ rails_deploy_worker_url }}"))
    (BACKGROUND_THREADS (jinja "{{ rails_deploy_database_pool }}")))
  (rails_deploy_env )
  (rails_deploy_nginx_server_enabled "True")
  (rails_deploy_nginx_domains (list
      (jinja "{{ ansible_fqdn }}")))
  (rails_deploy_nginx_upstream 
    (enabled (jinja "{{ rails_deploy_nginx_server_enabled }}"))
    (name (jinja "{{ rails_deploy_service }}"))
    (server (jinja "{{ 'unix:' + rails_deploy_backend_bind if not ':' in rails_deploy_backend_bind else rails_deploy_backend_bind }}")))
  (rails_deploy_nginx_server 
    (enabled (jinja "{{ rails_deploy_nginx_server_enabled }}"))
    (name (jinja "{{ rails_deploy_nginx_domains }}"))
    (root (jinja "{{ rails_deploy_src }}") "/public")
    (webroot_create "False")
    (error_pages 
      (404 "/404.html")
      (422 "/422.html")
      (500 "/500.html")
      (502 503 504 "/502.html"))
    (location_list (list
        
        (pattern "/")
        (options "try_files $uri $uri/index.html $uri.html @" (jinja "{{ rails_deploy_nginx_upstream.name }}") ";
")
        
        (pattern "~ ^/(assets|system)/")
        (options "gzip_static on;
expires max;
add_header Cache-Control public;
add_header Last-Modified \"\";
add_header ETag \"\";
")
        
        (pattern "@" (jinja "{{ rails_deploy_nginx_upstream.name }}"))
        (options "gzip off;
proxy_set_header   X-Forwarded-Proto $scheme;
proxy_set_header   Host              $http_host;
proxy_set_header   X-Real-IP         $remote_addr;
proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
proxy_redirect     off;
proxy_pass         http://" (jinja "{{ rails_deploy_nginx_upstream.name }}") ";
")))))
