(playbook "debops/ansible/roles/librenms/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (([\"php5-memcached\"]
                               if librenms__memcached | d()
                               else [])
                              + librenms__base_packages
                              + librenms__monitoring_packages
                              + librenms__packages)) }}"))
        (state "present"))
      (register "librenms__register_packages")
      (until "librenms__register_packages is succeeded"))
    (task "Enable non-free MIBs support"
      (ansible.builtin.lineinfile 
        (dest "/etc/snmp/snmp.conf")
        (state "present")
        (regexp "mibs\\s:")
        (line "#mibs :")
        (mode "0644")))
    (task "Create LibreNMS group"
      (ansible.builtin.group 
        (name (jinja "{{ librenms__group }}"))
        (system "True")
        (state "present")))
    (task "Create LibreNMS user"
      (ansible.builtin.user 
        (name (jinja "{{ librenms__user }}"))
        (group (jinja "{{ librenms__group }}"))
        (home (jinja "{{ librenms__home }}"))
        (shell (jinja "{{ librenms__shell }}"))
        (comment "LibreNMS")
        (system "True")
        (state "present")))
    (task "Clone LibreNMS source from deploy server"
      (ansible.builtin.git 
        (repo (jinja "{{ librenms__install_repo }}"))
        (dest (jinja "{{ librenms__install_path }}"))
        (version (jinja "{{ librenms__install_version }}"))
        (update "False"))
      (become "True")
      (become_user (jinja "{{ librenms__user }}"))
      (register "librenms__register_source")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (tags (list
          "role::librenms:source")))
    (task "Update LibreNMS home directory permissions"
      (ansible.builtin.file 
        (path (jinja "{{ librenms__home }}"))
        (state "directory")
        (owner (jinja "{{ librenms__user }}"))
        (group (jinja "{{ librenms__webserver_user }}"))
        (mode "0750")))
    (task "Make sure log directory exists"
      (ansible.builtin.file 
        (dest (jinja "{{ librenms__log_dir }}"))
        (state "directory")
        (owner (jinja "{{ librenms__user }}"))
        (group (jinja "{{ librenms__group }}"))
        (mode "0750"))
      (tags (list
          "role::librenms:config")))
    (task "Make sure data directories exist"
      (ansible.builtin.file 
        (dest (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ librenms__user }}"))
        (group (jinja "{{ librenms__group }}"))
        (mode "0775"))
      (with_items (list
          (jinja "{{ librenms__data_path }}")
          (jinja "{{ librenms__rrd_dir }}")))
      (tags (list
          "role::librenms:config")))
    (task "Initialize SNMP credentials"
      (ansible.builtin.set_fact 
        (librenms__fact_snmp_v3_authlevel (jinja "{{ librenms__snmp_credentials[0][\"authlevel\"] }}"))
        (librenms__fact_snmp_v3_authalgo (jinja "{{ librenms__snmp_credentials[0][\"authalgo\"] }}"))
        (librenms__fact_snmp_v3_cryptoalgo (jinja "{{ librenms__snmp_credentials[0][\"cryptoalgo\"] }}"))
        (librenms__fact_snmp_v3_authname (jinja "{{ librenms__snmp_credentials[0][\"authname\"] }}"))
        (librenms__fact_snmp_v3_authpass (jinja "{{ librenms__snmp_credentials[0][\"authpass\"] }}"))
        (librenms__fact_snmp_v3_cryptopass (jinja "{{ librenms__snmp_credentials[0][\"cryptopass\"] }}")))
      (run_once "True")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (tags (list
          "role::librenms:config"
          "role::librenms:database"
          "role::librenms:snmp_conf")))
    (task "Create LibreNMS database"
      (community.mysql.mysql_db 
        (name (jinja "{{ librenms__database_name }}"))
        (state "present")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (delegate_to (jinja "{{ ansible_local.mariadb.delegate_to }}"))
      (register "librenms__register_database_status")
      (tags (list
          "role::librenms:database")))
    (task "Configure LibreNMS"
      (ansible.builtin.template 
        (src "srv/www/sites/public/config.php.j2")
        (dest (jinja "{{ librenms__install_path + \"/config.php\" }}"))
        (owner (jinja "{{ librenms__user }}"))
        (group (jinja "{{ librenms__group }}"))
        (mode (jinja "{{ librenms__config_mode }}")))
      (tags (list
          "role::librenms:config"
          "role::librenms:database")))
    (task "Install missing PHP packages via Composer"
      (community.general.composer 
        (command "install")
        (working_dir (jinja "{{ librenms__install_path }}")))
      (register "librenms__register_composer")
      (until "librenms__register_composer is succeeded")
      (when "(librenms__register_database_status | d() and librenms__register_database_status is changed)")
      (become "True")
      (become_user (jinja "{{ librenms__user }}")))
    (task "Initialize database"
      (ansible.builtin.command "./daily.sh")
      (args 
        (chdir (jinja "{{ librenms__install_path }}")))
      (become "True")
      (become_user (jinja "{{ librenms__user }}"))
      (register "librenms__register_database_init")
      (changed_when "librenms__register_database_init.changed | bool")
      (when "(librenms__register_database_status | d() and librenms__register_database_status is changed)")
      (tags (list
          "role::librenms:database")))
    (task "Get list of existing users from LibreNMS database"
      (ansible.builtin.command "mysql -ssNe \"select username from users\"")
      (become "True")
      (become_user (jinja "{{ librenms__user }}"))
      (register "librenms__register_users")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "role::librenms:config"
          "role::librenms:admins")))
    (task "Create admin accounts"
      (ansible.builtin.command "php adduser.php " (jinja "{{ item }}") " " (jinja "{{ lookup(\"password\", secret + \"/credentials/\" + inventory_hostname
                                                             + \"/librenms/admin/\" + item + \"/password\") }}") " 10")
      (args 
        (chdir (jinja "{{ librenms__install_path }}")))
      (check_mode "False")
      (become "True")
      (become_user (jinja "{{ librenms__user }}"))
      (with_items (jinja "{{ librenms__admin_accounts }}"))
      (register "librenms__register_admin_accounts")
      (changed_when "librenms__register_admin_accounts.changed | bool")
      (when "(librenms__admin_accounts | d([]) and (item not in librenms__register_users.stdout_lines))")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (tags (list
          "role::librenms:config"
          "role::librenms:admins")))
    (task "Configure cron tasks"
      (ansible.builtin.template 
        (src "etc/cron.d/librenms.j2")
        (dest "/etc/cron.d/librenms")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags (list
          "role::librenms:config")))
    (task "Check list of current user accounts"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && getent passwd | cut -d: -f1")
      (args 
        (executable "bash"))
      (register "librenms__register_passwd")
      (changed_when "False")
      (check_mode "False")
      (when "librenms__home_snmp_conf | d() and librenms__home_snmp_conf")
      (tags (list
          "role::librenms:config"
          "role::librenms:snmp_conf")))
    (task "Create ~/.snmp directories"
      (ansible.builtin.file 
        (path (jinja "{{ \"~\" + item + \"/.snmp\" }}"))
        (state "directory")
        (owner (jinja "{{ item }}"))
        (group (jinja "{{ item }}"))
        (mode "0700"))
      (with_items (jinja "{{ librenms__home_snmp_conf }}"))
      (check_mode "False")
      (when "((librenms__home_snmp_conf | d() and librenms__home_snmp_conf) and (librenms__register_passwd | d() and item in librenms__register_passwd.stdout_lines))")
      (tags (list
          "role::librenms:config"
          "role::librenms:snmp_conf")))
    (task "Generate ~/.snmp/snmp.conf configuration"
      (ansible.builtin.template 
        (src "home/snmp/snmp.conf.j2")
        (dest (jinja "{{ \"~\" + item + \"/.snmp/snmp.conf\" }}"))
        (owner (jinja "{{ item }}"))
        (group (jinja "{{ item }}"))
        (mode "0600"))
      (with_items (jinja "{{ librenms__home_snmp_conf }}"))
      (when "((librenms__home_snmp_conf | d() and librenms__home_snmp_conf) and (librenms__register_passwd | d() and item in librenms__register_passwd.stdout_lines))")
      (tags (list
          "role::librenms:config"
          "role::librenms:snmp_conf")))
    (task "Get list of known devices from LibreNMS database"
      (ansible.builtin.command "mysql -ssNe \"select hostname from devices\"")
      (become "True")
      (become_user (jinja "{{ librenms__user }}"))
      (register "librenms__register_devices")
      (changed_when "False")
      (tags (list
          "role::librenms:config"
          "role::librenms:devices")))
    (task "Add specified hosts to LibreNMS"
      (ansible.builtin.command "php addhost.php " (jinja "{{ item }}") " any v3")
      (args 
        (chdir (jinja "{{ librenms__install_path }}")))
      (become "True")
      (become_user (jinja "{{ librenms__user }}"))
      (with_items (jinja "{{ librenms__devices }}"))
      (register "librenms__register_addhost")
      (changed_when "librenms__register_addhost.changed | bool")
      (when "(librenms__devices | d([]) and (item not in librenms__register_devices.stdout_lines))")
      (tags (list
          "role::librenms:config"
          "role::librenms:devices")))))
