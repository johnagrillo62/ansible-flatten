(playbook "ansible-examples/wordpress-nginx/site.yml"
    (play
    (name "Install WordPress, MySQL, Nginx, and PHP-FPM")
    (hosts "all")
    (remote_user "root")
    (roles
      "common"
      "mysql"
      "nginx"
      "php-fpm"
      "wordpress")))
