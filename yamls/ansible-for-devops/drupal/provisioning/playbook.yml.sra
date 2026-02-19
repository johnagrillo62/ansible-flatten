(playbook "ansible-for-devops/drupal/provisioning/playbook.yml"
    (play
    (hosts "all")
    (become "yes")
    (vars_files (list
        "vars.yml"))
    (pre_tasks
      (task "Update apt cache if needed."
        (apt "update_cache=yes cache_valid_time=3600")))
    (handlers
      (task "restart apache"
        (service "name=apache2 state=restarted")))
    (tasks
      (task "Get software for apt repository management."
        (apt 
          (state "present")
          (name (list
              "python3-apt"
              "python3-pycurl"))))
      (task "Add ondrej repository for later versions of PHP."
        (apt_repository "repo='ppa:ondrej/php' update_cache=yes"))
      (task "Install Apache, MySQL, PHP, and other dependencies."
        (apt 
          (state "present")
          (name (list
              "acl"
              "git"
              "curl"
              "unzip"
              "sendmail"
              "apache2"
              "php8.2-common"
              "php8.2-cli"
              "php8.2-dev"
              "php8.2-gd"
              "php8.2-curl"
              "php8.2-opcache"
              "php8.2-xml"
              "php8.2-mbstring"
              "php8.2-pdo"
              "php8.2-mysql"
              "php8.2-apcu"
              "libpcre3-dev"
              "libapache2-mod-php8.2"
              "python3-mysqldb"
              "mysql-server"))))
      (task "Disable the firewall (since this is for local dev only)."
        (service "name=ufw state=stopped"))
      (task "Start Apache, MySQL, and PHP."
        (service "name=" (jinja "{{ item }}") " state=started enabled=yes")
        (with_items (list
            "apache2"
            "mysql")))
      (task "Enable Apache rewrite module (required for Drupal)."
        (apache2_module "name=rewrite state=present")
        (notify "restart apache"))
      (task "Add Apache virtualhost for Drupal."
        (template 
          (src "templates/drupal.test.conf.j2")
          (dest "/etc/apache2/sites-available/" (jinja "{{ domain }}") ".test.conf")
          (owner "root")
          (group "root")
          (mode "0644"))
        (notify "restart apache"))
      (task "Enable the Drupal site."
        (command "a2ensite " (jinja "{{ domain }}") ".test creates=/etc/apache2/sites-enabled/" (jinja "{{ domain }}") ".test.conf
")
        (notify "restart apache"))
      (task "Disable the default site."
        (command "a2dissite 000-default removes=/etc/apache2/sites-enabled/000-default.conf
")
        (notify "restart apache"))
      (task "Adjust OpCache memory setting."
        (lineinfile 
          (dest "/etc/php/8.2/apache2/conf.d/10-opcache.ini")
          (regexp "^opcache.memory_consumption")
          (line "opcache.memory_consumption = 96")
          (state "present"))
        (notify "restart apache"))
      (task "Create a MySQL database for Drupal."
        (mysql_db "db=" (jinja "{{ domain }}") " state=present"))
      (task "Create a MySQL user for Drupal."
        (mysql_user 
          (name (jinja "{{ domain }}"))
          (password "1234")
          (priv (jinja "{{ domain }}") ".*:ALL")
          (host "localhost")
          (state "present")))
      (task "Download Composer installer."
        (get_url 
          (url "https://getcomposer.org/installer")
          (dest "/tmp/composer-installer.php")
          (mode "0755")))
      (task "Run Composer installer."
        (command "php composer-installer.php chdir=/tmp creates=/usr/local/bin/composer
"))
      (task "Move Composer into globally-accessible location."
        (command "mv /tmp/composer.phar /usr/local/bin/composer creates=/usr/local/bin/composer
"))
      (task "Ensure Drupal directory exists."
        (file 
          (path (jinja "{{ drupal_core_path }}"))
          (state "directory")
          (owner "www-data")
          (group "www-data")))
      (task "Check if Drupal project already exists."
        (stat 
          (path (jinja "{{ drupal_core_path }}") "/composer.json"))
        (register "drupal_composer_json"))
      (task "Create Drupal project."
        (composer 
          (command "create-project")
          (arguments "drupal/recommended-project \"" (jinja "{{ drupal_core_path }}") "\"")
          (working_dir (jinja "{{ drupal_core_path }}"))
          (no_dev "true"))
        (become_user "www-data")
        (when "not drupal_composer_json.stat.exists"))
      (task "Add drush to the Drupal site with Composer."
        (composer 
          (command "require")
          (arguments "drush/drush:11.*")
          (working_dir (jinja "{{ drupal_core_path }}")))
        (become_user "www-data")
        (when "not drupal_composer_json.stat.exists"))
      (task "Install Drupal."
        (command "vendor/bin/drush si -y --site-name=\"" (jinja "{{ drupal_site_name }}") "\" --account-name=admin --account-pass=admin --db-url=mysql://" (jinja "{{ domain }}") ":1234@localhost/" (jinja "{{ domain }}") " --root=" (jinja "{{ drupal_core_path }}") "/web chdir=" (jinja "{{ drupal_core_path }}") " creates=" (jinja "{{ drupal_core_path }}") "/web/sites/default/settings.php
")
        (notify "restart apache")
        (become_user "www-data")))))
