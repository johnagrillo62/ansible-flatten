(playbook "ansible-examples/wordpress-nginx_rhel7/site.yml"
    (play
    (name "Install WordPress, MariaDB, Nginx, and PHP-FPM")
    (hosts "wordpress-server")
    (remote_user "root")
    (roles
      "common"
      "mariadb"
      "nginx"
      "php-fpm"
      "wordpress")))
