(playbook "debops/ansible/roles/docker_registry/defaults/main.yml"
  (docker_registry__base_packages (jinja "{{ [\"docker-registry\"]
                                    if (not docker_registry__upstream | bool)
                                    else [] }}"))
  (docker_registry__packages (list))
  (docker_registry__version (jinja "{{ ansible_local.docker_registry.version | d(\"0.0.0\") }}"))
  (docker_registry__user "docker-registry")
  (docker_registry__group "docker-registry")
  (docker_registry__additional_groups (list
      (jinja "{{ ansible_local.redis_server.auth_group | d([]) }}")))
  (docker_registry__home "/var/lib/docker-registry")
  (docker_registry__comment "Docker Registry")
  (docker_registry__shell "/usr/sbin/nologin")
  (docker_registry__distribution_release (jinja "{{ ansible_local.core.distribution_release | d(ansible_distribution_release) }}"))
  (docker_registry__upstream (jinja "{{ True
                               if (docker_registry__distribution_release in
                                   [\"stretch\", \"trusty\", \"xenial\"])
                               else False }}"))
  (docker_registry__src (jinja "{{ docker_registry__home + \"/src\" }}"))
  (docker_registry__gopath (jinja "{{ docker_registry__home + \"/go\" }}"))
  (docker_registry__git_dest (jinja "{{ docker_registry__gopath + \"/src/\"
                               + docker_registry__git_repo.split(\"://\")[1] }}"))
  (docker_registry__git_dir (jinja "{{ docker_registry__src + \"/\" + docker_registry__git_repo.split(\"://\")[1] }}"))
  (docker_registry__git_gpg_key "8C7A 111C 2110 5794 B0E8  A27B F58C 5D0A 4405 ACDB")
  (docker_registry__git_repo "https://github.com/docker/distribution")
  (docker_registry__git_version "v2.7.1")
  (docker_registry__binary (jinja "{{ \"/usr/local/bin/docker-registry\"
                             if docker_registry__upstream | bool
                             else \"/usr/bin/docker-registry\" }}"))
  (docker_registry__fqdn "registry." (jinja "{{ docker_registry__domain }}"))
  (docker_registry__domain (jinja "{{ ansible_domain }}"))
  (docker_registry__backend_port "5070")
  (docker_registry__allow (list))
  (docker_registry__max_upload_size "4G")
  (docker_registry__basic_auth (jinja "{{ False
                                 if docker_registry__token_enabled | bool
                                 else True }}"))
  (docker_registry__basic_auth_realm "Docker Registry")
  (docker_registry__basic_auth_name "docker-registry")
  (docker_registry__basic_auth_users (jinja "{{ ansible_local.core.admin_users | d([]) }}"))
  (docker_registry__basic_auth_except_get "False")
  (docker_registry__storage_dir (jinja "{{ (ansible_local.fhs.data | d(\"/srv\"))
                                  + \"/\" + docker_registry__user + \"/storage\" }}"))
  (docker_registry__storage_mode "0755")
  (docker_registry__redis_enabled (jinja "{{ ansible_local.redis_server.installed | d() | bool }}"))
  (docker_registry__redis_host "127.0.0.1")
  (docker_registry__redis_port (jinja "{{ ansible_local.redis_server.port | d(\"6379\") }}"))
  (docker_registry__redis_password (jinja "{{ ansible_local.redis_server.password | d(\"\") }}"))
  (docker_registry__redis_db "0")
  (docker_registry__token_provider "gitlab")
  (docker_registry__token_enabled (jinja "{{ True
                                    if (ansible_local | d() and ansible_local[docker_registry__token_provider] | d() and
                                        (ansible_local[docker_registry__token_provider].registry | d()) | bool)
                                    else False }}"))
  (docker_registry__token_fqdn (jinja "{{ ansible_local[docker_registry__token_provider].fqdn
                                 if (ansible_local | d() and ansible_local[docker_registry__token_provider] | d() and
                                     ansible_local[docker_registry__token_provider].fqdn | d())
                                 else (\"code.\" + docker_registry__domain) }}"))
  (docker_registry__token_realm_url (jinja "{{ ansible_local[docker_registry__token_provider].registry_token_realm_url
                                      if (ansible_local | d() and ansible_local[docker_registry__token_provider] | d() and
                                          ansible_local[docker_registry__token_provider].registry_token_realm_url | d())
                                      else \"\" }}"))
  (docker_registry__token_issuer (jinja "{{ ansible_local[docker_registry__token_provider].registry_token_issuer
                                   if (ansible_local | d() and ansible_local[docker_registry__token_provider] | d() and
                                       ansible_local[docker_registry__token_provider].registry_token_issuer | d())
                                   else \"\" }}"))
  (docker_registry__token_service (jinja "{{ ansible_local[docker_registry__token_provider].registry_token_service
                                    if (ansible_local | d() and ansible_local[docker_registry__token_provider] | d() and
                                        ansible_local[docker_registry__token_provider].registry_token_service | d())
                                    else \"\" }}"))
  (docker_registry__token_pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (docker_registry__token_pki_realm (jinja "{{ ansible_local[docker_registry__token_provider].registry_pki_realm
                                      if (ansible_local | d() and ansible_local[docker_registry__token_provider] | d() and
                                          ansible_local[docker_registry__token_provider].registry_pki_realm | d())
                                      else \"domain\" }}"))
  (docker_registry__token_pki_crt "default.crt")
  (docker_registry__token_certificate (jinja "{{ docker_registry__token_pki_path + \"/\"
                                        + docker_registry__token_pki_realm + \"/\"
                                        + docker_registry__token_pki_crt }}"))
  (docker_registry__config_file "/etc/docker/registry/config.yml")
  (docker_registry__original_config (list
      
      (name "original-config")
      (config 
        (version "0.1")
        (log 
          (fields 
            (service "registry")))
        (storage 
          (cache 
            (blobdescriptor "inmemory")))
        (http 
          (addr ":5000")
          (headers 
            (X-Content-Type-Options (list
                "nosniff"))))
        (health 
          (storagedriver 
            (enabled "True")
            (interval "10s")
            (threshold "3"))))
      
      (name "original-storage")
      (config 
        (storage 
          (filesystem 
            (rootdirectory "/var/lib/registry"))))))
  (docker_registry__default_config (list
      
      (name "default-http")
      (config 
        (http 
          (addr "127.0.0.1:" (jinja "{{ docker_registry__backend_port }}"))))
      
      (name "original-storage")
      (state "absent")
      
      (name "default-storage")
      (config 
        (storage 
          (filesystem 
            (rootdirectory (jinja "{{ docker_registry__storage_dir }}")))
          (delete 
            (enabled "True"))))
      
      (name "default-redis")
      (state (jinja "{{ \"present\" if docker_registry__redis_enabled | bool else \"absent\" }}"))
      (config 
        (redis 
          (addr (jinja "{{ docker_registry__redis_host + \":\" + docker_registry__redis_port }}"))
          (password (jinja "{{ docker_registry__redis_password }}"))
          (db (jinja "{{ docker_registry__redis_db }}")))
        (storage 
          (cache 
            (blobdescriptor "redis"))))
      
      (name "default-token")
      (state (jinja "{{ \"present\" if docker_registry__token_enabled | bool else \"absent\" }}"))
      (config 
        (auth 
          (token 
            (realm (jinja "{{ docker_registry__token_realm_url }}"))
            (issuer (jinja "{{ docker_registry__token_issuer }}"))
            (service (jinja "{{ docker_registry__token_service }}"))
            (rootcertbundle (jinja "{{ docker_registry__token_certificate }}")))))))
  (docker_registry__config (list))
  (docker_registry__group_config (list))
  (docker_registry__host_config (list))
  (docker_registry__combined_config (jinja "{{ docker_registry__original_config
                                      + docker_registry__default_config
                                      + docker_registry__config
                                      + docker_registry__group_config
                                      + docker_registry__host_config }}"))
  (docker_registry__garbage_collector_enabled "True")
  (docker_registry__garbage_collector_interval "daily")
  (docker_registry__etc_services__dependent_list (list
      
      (name "docker-registry")
      (port (jinja "{{ docker_registry__backend_port }}"))
      (comment "Docker Registry")))
  (docker_registry__keyring__dependent_gpg_keys (list
      
      (user (jinja "{{ docker_registry__user }}"))
      (group (jinja "{{ docker_registry__group }}"))
      (home (jinja "{{ docker_registry__home }}"))
      (id (jinja "{{ docker_registry__git_gpg_key }}"))
      (state (jinja "{{ \"present\" if docker_registry__upstream | bool else \"absent\" }}"))))
  (docker_registry__python__dependent_packages3 (list
      "python3-yaml"))
  (docker_registry__python__dependent_packages2 (list
      "python-yaml"))
  (docker_registry__nginx__dependent_maps (list
      
      (name "docker_registry_headers")
      (map "$upstream_http_docker_distribution_api_version $docker_distribution_api_version")
      (mapping "''     'registry/2.0';
")
      (state "present")))
  (docker_registry__nginx__dependent_upstreams (list
      
      (name "docker-registry")
      (server "127.0.0.1:" (jinja "{{ docker_registry__backend_port }}"))))
  (docker_registry__nginx__dependent_htpasswd 
    (name (jinja "{{ docker_registry__basic_auth_name }}"))
    (users (jinja "{{ docker_registry__basic_auth_users }}")))
  (docker_registry__nginx__dependent_servers (list
      
      (name (jinja "{{ docker_registry__fqdn }}"))
      (filename "debops.docker_registry")
      (allow (jinja "{{ docker_registry__allow }}"))
      (auth_basic (jinja "{{ False
                    if (docker_registry__basic_auth_except_get | bool)
                    else (docker_registry__basic_auth | bool) }}"))
      (auth_basic_realm (jinja "{{ docker_registry__basic_auth_realm }}"))
      (auth_basic_name (jinja "{{ docker_registry__basic_auth_name }}"))
      (options "client_max_body_size " (jinja "{{ docker_registry__max_upload_size }}") ";

# required to avoid error HTTP 411: see Issue #1486 (https://github.com/moby/moby/issues/1486)
chunked_transfer_encoding on;
")
      (location_list (list
          
          (pattern "/")
          (options (jinja "{% if docker_registry__token_enabled | bool %}") "
return 307 $scheme://" (jinja "{{ docker_registry__token_fqdn }}") "/;
" (jinja "{% else %}") "
return 307 /v2/;
" (jinja "{% endif %}") "
")
          
          (pattern "/v2/")
          (options "# Do not allow connections from docker 1.5 and earlier
# docker pre-1.6.0 did not properly set the user agent on ping, catch \"Go *\" user agents
if ($http_user_agent ~ \"^(docker\\/1\\.(3|4|5(?!\\.[0-9]-dev))|Go ).*$\" ) {
  return 404;
}

" (jinja "{% if docker_registry__basic_auth_except_get | bool %}") "
set $auth_basic \"" (jinja "{{ docker_registry__basic_auth_realm }}") "\";
if ($request_method ~* \"^(GET|HEAD)$\") {
    set $auth_basic \"off\";
}
if ($force_authentication) {
    set $auth_basic \"" (jinja "{{ docker_registry__basic_auth_realm }}") "\";
}
auth_basic $auth_basic;
auth_basic_user_file " (jinja "{{ nginx_private_path + \"/\" + docker_registry__basic_auth_name }}") ";

set $auth_status \"deny\";
if ($request_uri ~* \"^/v2/([^/]+)/\") {
    set $user_path $1;
}
if ($remote_user = $user_path) {
    set $auth_status \"grant\";
}
if ($request_method ~* \"^(GET|HEAD)$\") {
    set $auth_status \"grant\";
}
if ($auth_status != \"grant\") {
    return 401;
}
" (jinja "{% endif %}") "

# If $docker_distribution_api_version is empty, the header will not be added.
# See the map directive above where this variable is defined.
add_header 'Docker-Distribution-Api-Version' $docker_distribution_api_version always;

proxy_pass http://docker-registry;
proxy_set_header Host              $http_host;
proxy_set_header X-Real-IP         $remote_addr;
proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Host  $server_name;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_read_timeout 900;
")
          (state "present"))))))
