(playbook "debops/ansible/roles/php/tasks/main_env.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Reset PHP Ansible local facts"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d/php.fact")
        (state "absent"))
      (notify (list
          "Refresh host facts"))
      (when "php__reset | bool")
      (tags (list
          "meta::facts")))
    (task "Gather facts on reset"
      (ansible.builtin.meta "flush_handlers"))
    (task "Detect PHP version from available packages"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && apt-cache madison " (jinja "{{ php__version_preference | join(' ') }}") " \\ | awk '{print $3}' \\ | sed -e 's/^.*://' -e 's/\\+.*$//' -e 's/\\d+\\.\\d+//' \\ | awk -F'.' '{print $1\".\"$2}' \\ | head -n 1")
      (environment 
        (LC_ALL "C"))
      (args 
        (executable "/bin/bash"))
      (register "php__register_version")
      (check_mode "False")
      (changed_when "False")
      (tags (list
          "role::php:pools"
          "role::php:config")))
    (task "Detect PHP long version from available packages"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && apt-cache madison " (jinja "{{ 'php' + php__register_version.stdout }}") " \\ | awk '{print $3}' | sed -e 's/^.*://' -e 's/\\+.*$//' -e 's/\\-.*$//' \\ | head -n 1")
      (environment 
        (LC_ALL "C"))
      (args 
        (executable "/bin/bash"))
      (register "php__register_long_version")
      (check_mode "False")
      (changed_when "False")
      (tags (list
          "role::php:pools"
          "role::php:config")))
    (task "Set PHP version"
      (ansible.builtin.set_fact 
        (php__version (jinja "{{ ansible_local.php.version | d(php__register_version.stdout) }}"))
        (php__long_version (jinja "{{ ansible_local.php.long_version
                           if (ansible_local | d() and ansible_local.php | d() and
                               ansible_local.php.long_version | d() != \"(none)\")
                           else php__register_long_version.stdout }}")))
      (tags (list
          "role::php:pools"
          "role::php:config")))
    (task "Set PHP base paths"
      (ansible.builtin.set_fact 
        (php__etc_base (jinja "{{ (\"/etc/php/\" + php__version)
                       if (php__version is version_compare(\"7.0\", \">=\") or php__sury | bool)
                       else \"/etc/php5\" }}"))
        (php__lib_base (jinja "{{ (\"/usr/lib/php/\" + php__version)
                       if (php__version is version_compare(\"7.0\", \">=\") or php__sury | bool)
                       else \"/usr/lib/php5\" }}"))
        (php__run_base (jinja "{{ \"/run/php\"
                       if (php__version is version_compare(\"7.0\", \">=\") or php__sury | bool)
                       else \"/run\" }}"))
        (php__logrotate_lib_base (jinja "{{ \"/usr/lib/php\"
                                 if (php__version is version_compare(\"7.0\", \">=\") or php__sury | bool)
                                 else \"/usr/lib/php5\" }}")))
      (tags (list
          "role::php:pools"
          "role::php:config")))))
