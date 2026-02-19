(playbook "debops/ansible/roles/php/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Get available PHP packages for selected version"
      (ansible.builtin.script "script/php-filter-packages.sh " (jinja "{{ php__combined_packages }}"))
      (environment 
        (LC_ALL "C")
        (PHP_VERSION (jinja "{{ php__version }}")))
      (register "php__register_filtered_packages")
      (changed_when "False")
      (check_mode "False"))
    (task "Install PHP packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", php__register_filtered_packages.stdout.strip().splitlines()) }}"))
        (state "present"))
      (register "php__register_packages")
      (until "php__register_packages is succeeded")
      (notify (list
          "Restart php-fpm")))
    (task "Install PHP Composer from upstream"
      (ansible.builtin.get_url 
        (url (jinja "{{ php__composer_upstream_url }}"))
        (dest (jinja "{{ php__composer_upstream_dest }}"))
        (checksum (jinja "{{ php__composer_upstream_checksum }}"))
        (mode "0755"))
      (when "php__composer_upstream_enabled | bool"))
    (task "Ensure older PHP packages are absent on reset"
      (ansible.builtin.include_tasks "packages_absent_for_version.yml")
      (loop_control 
        (loop_var "php__version_absent"))
      (when "php__reset | bool")
      (with_items (jinja "{{ php__version_preference | difference([\"php\" + php__version | d(\"\")]) | list }}")))
    (task "Create directory for php*-fpm logs"
      (ansible.builtin.file 
        (path "/var/log/php" (jinja "{{ php__version }}") "-fpm")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0700"))
      (when "\"fpm\" in php__server_api_packages"))
    (task "Ensure that required directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (with_items (list
          (jinja "{{ php__etc_base }}") "/ansible"
          (jinja "{{ php__etc_base }}") "/fpm/pool.d")))
    (task "Allow webadmins to control PHP-FPM system service using sudo"
      (ansible.builtin.template 
        (src "etc/sudoers.d/php-fpm_webadmins.j2")
        (dest "/etc/sudoers.d/php-fpm_webadmins")
        (owner "root")
        (group "root")
        (mode "0440"))
      (when "(ansible_local | d() and ansible_local.sudo | d() and (ansible_local.sudo.installed | d()) | bool)"))
    (task "Generate php.ini configuration"
      (ansible.builtin.template 
        (src "etc/php/ansible/php.ini.j2")
        (dest (jinja "{{ php__etc_base + \"/\" + item.path | d(\"ansible/\") + (item.filename | d(\"00-ansible\")) + \".ini\" }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", php__default_configuration
                           + php__configuration
                           + php__group_configuration
                           + php__host_configuration
                           + php__dependent_configuration) }}"))
      (when "item.state | d('present') != 'absent'")
      (notify (list
          "Restart php-fpm"))
      (tags (list
          "role::php:config")))
    (task "Remove php.ini configuration if requested"
      (ansible.builtin.file 
        (path (jinja "{{ php__etc_base + \"/\" + item.path | d(\"ansible/\") + (item.filename | d(\"00-ansible\")) + \".ini\" }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", php__default_configuration
                           + php__configuration
                           + php__group_configuration
                           + php__host_configuration
                           + php__dependent_configuration) }}"))
      (when "item.state | d() and item.state == 'absent'")
      (notify (list
          "Restart php-fpm"))
      (tags (list
          "role::php:config")))
    (task "Synchronize Ansible and PHP SAPI configuration"
      (ansible.builtin.script "script/php-synchronize-config.sh " (jinja "{{ php__version }}"))
      (environment 
        (LC_ALL "C"))
      (register "php__register_synchronize_config")
      (changed_when "php__register_synchronize_config.stdout is defined and php__register_synchronize_config.stdout | d()")
      (notify (list
          "Restart php-fpm"))
      (tags (list
          "role::php:config")))
    (task "Divert default PHP-FPM configuration and pool"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ item }}")))
      (with_items (list
          (jinja "{{ php__etc_base + \"/fpm/php-fpm.conf\" }}")
          (jinja "{{ php__etc_base + \"/fpm/pool.d/www.conf\" }}")))
      (when "\"fpm\" in php__server_api_packages")
      (notify (list
          "Restart php-fpm"))
      (tags (list
          "role::php:pools"
          "role::php:config")))
    (task "Generate php-fpm global configuration"
      (ansible.builtin.template 
        (src "etc/php/fpm/php-fpm.conf.j2")
        (dest (jinja "{{ php__etc_base }}") "/fpm/php-fpm.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "\"fpm\" in php__server_api_packages")
      (notify (list
          "Restart php-fpm"))
      (tags (list
          "role::php:pools"
          "role::php:config")))
    (task "Generate php-fpm pool configuration"
      (ansible.builtin.template 
        (src "etc/php/fpm/pool.d/pool.conf.j2")
        (dest (jinja "{{ php__etc_base }}") "/fpm/pool.d/" (jinja "{{ item.name }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", php__default_pools
                           + php__pools
                           + php__group_pools
                           + php__host_pools
                           + php__dependent_pools) }}"))
      (when "\"fpm\" in php__server_api_packages and item.state | d(\"present\") != \"absent\"")
      (notify (list
          "Restart php-fpm"))
      (tags (list
          "role::php:pools"
          "role::php:config")))
    (task "Remove php-fpm pool configuration if requested"
      (ansible.builtin.file 
        (dest (jinja "{{ php__etc_base }}") "/fpm/pool.d/" (jinja "{{ item.name }}") ".conf")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", php__default_pools
                           + php__pools
                           + php__group_pools
                           + php__host_pools
                           + php__dependent_pools) }}"))
      (when "\"fpm\" in php__server_api_packages and item.state | d() and item.state == \"absent\"")
      (notify (list
          "Restart php-fpm"))
      (tags (list
          "role::php:pools"
          "role::php:config")))
    (task "Make sure required system groups exist"
      (ansible.builtin.group 
        (name (jinja "{{ item.group | d(item.owner) }}"))
        (system (jinja "{{ (item.system | d(True)) | bool }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", php__default_pools
                           + php__pools
                           + php__group_pools
                           + php__host_pools
                           + php__dependent_pools) }}"))
      (when "\"fpm\" in php__server_api_packages and item.state | d(\"present\") != \"absent\" and item.owner | d() and item.home | d()"))
    (task "Make sure required system accounts exist"
      (ansible.builtin.user 
        (name (jinja "{{ item.owner }}"))
        (group (jinja "{{ item.group | d(item.owner) }}"))
        (home (jinja "{{ item.home }}"))
        (system (jinja "{{ (item.system | d(True)) | bool }}"))
        (createhome (jinja "{{ item.createhome | d(omit) }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", php__default_pools
                           + php__pools
                           + php__group_pools
                           + php__host_pools
                           + php__dependent_pools) }}"))
      (when "\"fpm\" in php__server_api_packages and item.state | d(\"present\") != \"absent\" and item.owner | d() and item.home | d()"))
    (task "Make sure that Ansible local facts directory is present"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save PHP-FPM local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/php.fact.j2")
        (dest "/etc/ansible/facts.d/php.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Gather facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
