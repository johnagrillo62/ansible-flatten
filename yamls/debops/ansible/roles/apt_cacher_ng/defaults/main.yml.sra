(playbook "debops/ansible/roles/apt_cacher_ng/defaults/main.yml"
  (apt_cacher_ng__base_packages (list
      "apt-cacher-ng"))
  (apt_cacher_ng__enabled "True")
  (apt_cacher_ng__deploy_state "present")
  (apt_cacher_ng__configuration_files (list
      
      (path "/etc/apt-cacher-ng/backends_debian")
      (mode "0644")
      
      (path "/etc/apt-cacher-ng/backends_ubuntu")
      (mode "0644")
      
      (path "/etc/apt-cacher-ng/backends_gentoo")
      (mode "0644")
      (divert "False")
      
      (path "/etc/apt-cacher-ng/acng.conf")
      (mode "0644")
      
      (path "/etc/apt-cacher-ng/security.conf")
      (group "apt-cacher-ng")
      (mode "0640")
      
      (path "/etc/apt-cacher-ng/userinfo.html")
      (mode "0644")
      (divert "False")))
  (apt_cacher_ng__port "3142")
  (apt_cacher_ng__bind_address (list))
  (apt_cacher_ng__fqdn "software-cache." (jinja "{{ ansible_domain }}"))
  (apt_cacher_ng__proxy "")
  (apt_cacher_ng__connect_protocol (list))
  (apt_cacher_ng__offline_mode "False")
  (apt_cacher_ng__network_timeout "60")
  (apt_cacher_ng__max_download_speed_kib "")
  (apt_cacher_ng__upstream_mirror_debian (jinja "{{ ansible_local.apt.default_sources_map.Debian[0]
                                            | d(\"http://deb.debian.org/debian\") }}"))
  (apt_cacher_ng__upstream_mirror_ubuntu (jinja "{{ ansible_local.apt.default_sources_map.Ubuntu[0]
                                            | d(\"http://archive.ubuntu.com/ubuntu\") }}"))
  (apt_cacher_ng__upstream_mirror_gentoo (jinja "{{ ansible_local.apt.default_sources_map.Gentoo[0] | d(\"\") }}"))
  (apt_cacher_ng__cache_dir "/var/cache/apt-cacher-ng")
  (apt_cacher_ng__cache_dir_owner "apt-cacher-ng")
  (apt_cacher_ng__cache_dir_group "apt-cacher-ng")
  (apt_cacher_ng__dir_perms "02755")
  (apt_cacher_ng__file_perms "00644")
  (apt_cacher_ng__cache_dir_enforce_permissions "lazy")
  (apt_cacher_ng__user "admin")
  (apt_cacher_ng__password (jinja "{{ lookup(\"password\", secret + \"/credentials/\" +
                             inventory_hostname + \"/apt_cacher_ng/\" +
                             apt_cacher_ng__user + \"/password length=24\") }}"))
  (apt_cacher_ng__log_dir "/var/log/apt-cacher-ng")
  (apt_cacher_ng__support_dir "/usr/lib/apt-cacher-ng")
  (apt_cacher_ng__debug "0")
  (apt_cacher_ng__verbose_log "True")
  (apt_cacher_ng__force_managed "False")
  (apt_cacher_ng__expiration_threshold "4")
  (apt_cacher_ng__expiration_abort_on_problems "default")
  (apt_cacher_ng__dns_cache_seconds "1800")
  (apt_cacher_ng__log_submitted_origin "True")
  (apt_cacher_ng__user_agent "default")
  (apt_cacher_ng__recompress_bz2 "False")
  (apt_cacher_ng__custom "")
  (apt_cacher_ng__allow (list))
  (apt_cacher_ng__group_allow (list))
  (apt_cacher_ng__host_allow (list))
  (apt_cacher_ng__interfaces (list))
  (apt_cacher_ng__etc_services__dependent_list (list
      
      (name "acng")
      (port (jinja "{{ apt_cacher_ng__port }}"))
      (comment "Apt-Cacher NG caching proxy server")
      (delete (jinja "{{ apt_cacher_ng__deploy_state != \"present\" }}"))))
  (apt_cacher_ng__apt_preferences__dependent_list (list))
  (apt_cacher_ng__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "acng"))
      (saddr (jinja "{{ (apt_cacher_ng__allow | d([]) | list) +
               (apt_cacher_ng__group_allow | d([]) | list) +
               (apt_cacher_ng__host_allow | d([]) | list) }}"))
      (accept_any "True")
      (interface (jinja "{{ apt_cacher_ng__interfaces }}"))
      (weight "40")
      (by_role "debops.apt_cacher_ng")
      (name "http_proxy")
      (rule_state (jinja "{{ apt_cacher_ng__deploy_state }}"))))
  (apt_cacher_ng__apparmor__dependent_config 
    (usr.sbin.apt-cacher-ng (list
        
        (comment "Allow Apt-Cacher-Ng access to the cache directory")
        (by_role "debops.apt_cacher_ng")
        (delete (jinja "{{ apt_cacher_ng__deploy_state != \"present\" }}"))
        (rules (list
            (jinja "{{ apt_cacher_ng__cache_dir }}") "/ r"
            (jinja "{{ apt_cacher_ng__cache_dir }}") "/** rw")))))
  (apt_cacher_ng__upstream_servers (list
      "localhost:" (jinja "{{ apt_cacher_ng__port }}")))
  (apt_cacher_ng__nginx__upstream 
    (enabled "True")
    (name "apt-cacher-ng")
    (server (jinja "{{ apt_cacher_ng__upstream_servers }}")))
  (apt_cacher_ng__nginx__servers (list
      
      (by_role "debops.apt_cacher_ng")
      (name (list
          (jinja "{{ apt_cacher_ng__fqdn }}")))
      (filename "debops.apt_cacher_ng_http")
      (enabled "True")
      (allow (jinja "{{ apt_cacher_ng__allow + apt_cacher_ng__group_allow + apt_cacher_ng__host_allow }}"))
      (ssl "False")
      (webroot_create "False")
      (type "proxy")
      (proxy_pass "http://apt-cacher-ng")
      (proxy_options "if ($request_uri !~ \"^/.*(\\.js|\\.css|\\.html|\\.ico)(.*)?$\") {
        rewrite ^/(.*)$ /$host/$1 break;
}
proxy_redirect off;
proxy_buffering off;
")
      (options "location ~ /acng-report.html {
        return 307 https://$host$request_uri;
}
")
      
      (by_role "debops.apt_cacher_ng")
      (name (list
          (jinja "{{ apt_cacher_ng__fqdn }}")))
      (filename "debops.apt_cacher_ng_https")
      (enabled "True")
      (allow (jinja "{{ apt_cacher_ng__allow + apt_cacher_ng__group_allow + apt_cacher_ng__host_allow }}"))
      (state (jinja "{{ \"present\" if (ansible_local.pki | d()) else \"absent\" }}"))
      (listen "False")
      (webroot_create "False")
      (type "proxy")
      (proxy_pass "http://apt-cacher-ng")
      (proxy_options "if ($request_uri !~ \"^/.*(\\.js|\\.css|\\.html|\\.ico)(.*)?$\") {
        rewrite ^/(.*)$ /$host/$1 break;
}
proxy_redirect off;
proxy_buffering off;
"))))
