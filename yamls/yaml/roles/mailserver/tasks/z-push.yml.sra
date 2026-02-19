(playbook "yaml/roles/mailserver/tasks/z-push.yml"
  (tasks
    (task "Install required packages for z-push"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "php-soap"
          "php5"
          "php5-cli"
          "php5-imap"))
      (tags (list
          "dependencies")))
    (task "Download z-push release"
      (get_url "url=http://download.z-push.org/final/2.1/z-push-" (jinja "{{ zpush_version }}") ".tar.gz dest=/root/z-push-" (jinja "{{ zpush_version }}") ".tar.gz"))
    (task "Decompress z-push source"
      (unarchive "src=/root/z-push-" (jinja "{{ zpush_version }}") ".tar.gz dest=/root copy=no creates=/root/z-push-" (jinja "{{ zpush_version }}")))
    (task "Create /usr/share/z-push"
      (file "state=directory path=/usr/share/z-push"))
    (task "Copy z-push source files to /usr/share/z-push"
      (shell "cp -R z-push-" (jinja "{{ zpush_version }}") "/* /usr/share/z-push/ chdir=/root")
      (tags (list
          "skip_ansible_lint")))
    (task "Remove downloaded, temporary z-push source files"
      (shell "rm -rf z-push* chdir=/root")
      (tags (list
          "skip_ansible_lint")))
    (task "Ensure z-push state and log directories are in place"
      (file "state=directory path=" (jinja "{{ item }}") " owner=www-data group=www-data mode=0755")
      (with_items (list
          "/decrypted/zpush-state"
          "/var/log/z-push"))
      (notify "restart apache"))
    (task "Copy z-push's config.php into place"
      (template "src=usr_share_z-push_config.php.j2 dest=/usr/share/z-push/config.php"))
    (task "Create z-push apache alias and php configuration file"
      (copy "src=etc_apache2_conf.d_z-push.conf dest=/etc/apache2/conf-available/z-push.conf"))
    (task "Enable z-push Apache alias and PHP configuration file"
      (command "a2enconf z-push creates=/etc/apache2/conf-enabled/z-push.conf")
      (notify "restart apache"))
    (task "Configure z-push logrotate"
      (copy "src=etc_logrotate_z-push dest=/etc/logrotate.d/z-push owner=root group=root mode=0644"))))
