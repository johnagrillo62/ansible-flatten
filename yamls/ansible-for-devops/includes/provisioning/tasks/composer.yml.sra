(playbook "ansible-for-devops/includes/provisioning/tasks/composer.yml"
  (tasks
    (task "Download Composer installer."
      (get_url 
        (url "https://getcomposer.org/installer")
        (dest "/tmp/composer-installer.php")
        (mode "0755")))
    (task "Run Composer installer."
      (command "php composer-installer.php chdir=/tmp creates=/usr/local/bin/composer
"))
    (task "Move Composer into globally-accessible location."
      (command "mv /tmp/composer.phar /usr/local/bin/composer creates=/usr/local/bin/composer"))))
