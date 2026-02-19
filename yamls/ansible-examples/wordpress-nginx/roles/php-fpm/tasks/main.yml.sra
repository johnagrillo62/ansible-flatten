(playbook "ansible-examples/wordpress-nginx/roles/php-fpm/tasks/main.yml"
  (tasks
    (task "Install php-fpm and deps"
      (yum "name=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "php"
          "php-fpm"
          "php-enchant"
          "php-IDNA_Convert"
          "php-mbstring"
          "php-mysql"
          "php-PHPMailer"
          "php-process"
          "php-simplepie"
          "php-xml")))
    (task "Disable default pool"
      (command "mv /etc/php-fpm.d/www.conf /etc/php-fpm.d/www.disabled creates=/etc/php-fpm.d/www.disabled")
      (notify "restart php-fpm"))
    (task "Copy php-fpm configuration"
      (template "src=wordpress.conf dest=/etc/php-fpm.d/")
      (notify "restart php-fpm"))))
