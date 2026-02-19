(playbook "debops/ansible/roles/sks/vars/main.yml"
  (sks_recon_name "sks")
  (sks_recon_port "11370")
  (sks_hkp_frontend_name "hkp-backend")
  (sks_hkp_frontend_port "11372")
  (sks_nginx_frontend 
    (by_role "debops.sks")
    (enabled "True")
    (default "False")
    (name (jinja "{{ [\"default_sks\"] + sks_domain }}"))
    (root (jinja "{{ \"/srv/www/sites/\" + sks_domain[0] + \"/public\" }}"))
    (webroot_create "False")
    (ssl "False")
    (listen (list
        "[::]:80"
        "[::]:11371"))
    (location 
      (/ "try_files $uri $uri/ =404;
index index.html;
")
      (/pks "proxy_pass http://sks_servers/pks;
proxy_pass_header Server;
add_header Via \"1.1 " (jinja "{{ ansible_fqdn }}") " (nginx)\";
proxy_ignore_client_abort on;
")))
  (sks_nginx_ssl_frontend 
    (by_role "debops.sks")
    (enabled "True")
    (default "False")
    (state (jinja "{{ \"present\"
             if (ansible_local | d() and ansible_local.pki | d() and
                 (ansible_local.pki.enabled | d()) | bool)
             else \"absent\" }}"))
    (name (jinja "{{ sks_domain }}"))
    (listen "False")
    (location 
      (/ "try_files $uri $uri/ =404;
index index.html;
")
      (/pks "proxy_pass http://sks_servers/pks;
proxy_pass_header Server;
add_header Via \"1.1 " (jinja "{{ ansible_fqdn }}") " (nginx)\";
proxy_ignore_client_abort on;
")))
  (sks_nginx_upstreams 
    (enabled "True")
    (name "sks_servers")
    (server "localhost:" (jinja "{{ sks_hkp_frontend_port }}"))
    (cluster (jinja "{{ sks_cluster | difference(sks_frontends) }}"))
    (port "11371")))
