(playbook "ansible-for-devops/https-self-signed/provisioning/vars/main.yml"
  (firewall_allowed_tcp_ports (list
      "22"
      "80"
      "443"))
  (pip_install_packages (list
      "pyopenssl"))
  (nginx_vhosts (list))
  (nginx_remove_default_vhost "True")
  (nginx_ppa_version "stable")
  (nginx_docroot "/var/www/html")
  (certificate_dir "/etc/ssl/private")
  (server_hostname "https.test"))
