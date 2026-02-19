(playbook "debops/ansible/roles/phpmyadmin/vars/main.yml"
  (phpmyadmin_control_user "phpmyadmin")
  (phpmyadmin_control_database "phpmyadmin")
  (phpmyadmin_nginx_server 
    (by_role "debops.phpmyadmin")
    (enabled "True")
    (default "False")
    (type "php5")
    (name (jinja "{{ phpmyadmin_domain }}"))
    (root "/usr/share/phpmyadmin")
    (webroot_create "False")
    (options "client_max_body_size  " (jinja "{{ phpmyadmin_upload_size }}") ";
")
    (location 
      (/ "try_files $uri $uri/ =404;")
      (~ ^/(setup|libraries) "deny all;"))
    (location_allow 
      (/ (jinja "{{ phpmyadmin_allow }}")))
    (php5 "php5_phpmyadmin")
    (php5_options (jinja "{% if phpmyadmin_allow is defined and phpmyadmin_allow %}") "
" (jinja "{% for address in phpmyadmin_allow %}") "
allow " (jinja "{{ address }}") ";
" (jinja "{% endfor %}") "
deny all;
" (jinja "{% endif %}") "
"))
  (phpmyadmin_nginx_upstream_php5 
    (enabled "True")
    (name "php5_phpmyadmin")
    (type "php5")
    (php5 "phpmyadmin"))
  (phpmyadmin_php5_pool 
    (enabled "True")
    (name "phpmyadmin")
    (user "www-data")
    (group "www-data")
    (pm_max_children (jinja "{{ phpmyadmin_php5_max_children }}"))
    (php_value 
      (post_max_size (jinja "{{ phpmyadmin_upload_size }}"))
      (upload_max_filesize (jinja "{{ phpmyadmin_upload_size }}")))))
