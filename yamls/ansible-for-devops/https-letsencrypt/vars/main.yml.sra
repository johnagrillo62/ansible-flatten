(playbook "ansible-for-devops/https-letsencrypt/vars/main.yml"
  (firewall_allowed_tcp_ports (list
      "22"
      "80"
      "443"))
  (nginx_vhosts (list))
  (nginx_remove_default_vhost "true")
  (nginx_ppa_version "stable")
  (nginx_docroot "/var/www/html")
  (certbot_create_if_missing "true")
  (certbot_admin_email (jinja "{{ letsencrypt_email }}"))
  (certbot_certs (list
      
      (domains (list
          (jinja "{{ inventory_hostname }}"))))))
