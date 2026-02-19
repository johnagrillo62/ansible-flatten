(playbook "debops/ansible/roles/rstudio_server/defaults/main.yml"
  (rstudio_server__rstudio_in_apt (jinja "{{ True
                                    if (rstudio_server__register_package_rstudio.stdout)
                                    else False }}"))
  (rstudio_server__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                         + \"/\" + rstudio_server__user }}"))
  (rstudio_server__release_deb_map 
    (Ubuntu 
      (package "https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.1335-amd64.deb")
      (checksum "sha256:a41f16fd7e7e471fca77f081a4b302a1d66d14fb32dffcea1299e0c1dbf30e44"))
    (Debian 
      (package "https://download2.rstudio.org/server/debian9/x86_64/rstudio-server-1.2.1335-amd64.deb")
      (checksum "sha256:a95d0b33d1f7d85fbd7403a610aa39b3bb8354e7efdba3e80f4d919d1589ca95")))
  (rstudio_server__rstudio_deb_url (jinja "{{ rstudio_server__release_deb_map[ansible_distribution + \"_\" + ansible_distribution_release].package
                                     if (rstudio_server__release_deb_map[ansible_distribution + \"_\" + ansible_distribution_release] | d())
                                     else rstudio_server__release_deb_map[ansible_distribution].package }}"))
  (rstudio_server__rstudio_deb_checksum (jinja "{{ rstudio_server__release_deb_map[ansible_distribution + \"_\" + ansible_distribution_release].checksum
                                          if (rstudio_server__release_deb_map[ansible_distribution + \"_\" + ansible_distribution_release] | d())
                                          else rstudio_server__release_deb_map[ansible_distribution].checksum }}"))
  (rstudio_server__signing_key_id "FE85 64CF F1AB 93F1 7286  4519 3F32 EE77 E331 692F")
  (rstudio_server__base_packages (list
      "dpkg-sig"
      (jinja "{{ \"rstudio-server\"
        if rstudio_server__rstudio_in_apt | bool
        else [] }}")))
  (rstudio_server__packages (list))
  (rstudio_server__user "rstudio-server")
  (rstudio_server__group "rstudio-server")
  (rstudio_server__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                          + \"/\" + rstudio_server__user }}"))
  (rstudio_server__shell "/usr/sbin/nologin")
  (rstudio_server__comment "RStudio Server")
  (rstudio_server__allow_users (list))
  (rstudio_server__group_allow_users (list))
  (rstudio_server__host_allow_users (list))
  (rstudio_server__bind "127.0.0.1")
  (rstudio_server__port "8787")
  (rstudio_server__auth_group "rstudio-users")
  (rstudio_server__session_timeout "120")
  (rstudio_server__cran_mirror (jinja "{{ ansible_local.cran.mirror | d(\"https://cloud.r-project.org/\") }}"))
  (rstudio_server__rserver_conf (list
      
      (www-address (jinja "{{ rstudio_server__bind }}"))
      
      (www-port (jinja "{{ rstudio_server__port }}"))
      
      (auth-required-user-group (jinja "{{ rstudio_server__auth_group }}"))))
  (rstudio_server__rsession_conf (list
      
      (session-timeout-minutes (jinja "{{ rstudio_server__session_timeout }}"))
      
      (r-cran-repos (jinja "{{ rstudio_server__cran_mirror }}"))))
  (rstudio_server__fqdn "rstudio." (jinja "{{ rstudio_server__domain }}"))
  (rstudio_server__domain (jinja "{{ ansible_domain }}"))
  (rstudio_server__upload_size "50m")
  (rstudio_server__etc_services__dependent_list (list
      
      (name "rstudio")
      (port (jinja "{{ rstudio_server__port }}"))
      (comment "RStudio Server")))
  (rstudio_server__keyring__dependent_gpg_keys (list
      
      (user (jinja "{{ rstudio_server__user }}"))
      (group (jinja "{{ rstudio_server__group }}"))
      (home (jinja "{{ rstudio_server__home }}"))
      (id (jinja "{{ rstudio_server__signing_key_id }}"))))
  (rstudio_server__cran__dependent_packages (list
      "r-doc-html"))
  (rstudio_server__nginx__dependent_servers (list
      
      (by_role "debops.rstudio_server")
      (name (jinja "{{ rstudio_server__fqdn }}"))
      (filename "debops.rstudio_server")
      (options "client_max_body_size " (jinja "{{ rstudio_server__upload_size }}") ";
")
      (location_list (list
          
          (pattern "/")
          (options "proxy_pass http://127.0.0.1:" (jinja "{{ rstudio_server__port }}") ";
proxy_redirect http://127.0.0.1:" (jinja "{{ rstudio_server__port }}") "/ $scheme://$host/;
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $connection_upgrade;
proxy_read_timeout 20d;
")
          (state "present"))))))
