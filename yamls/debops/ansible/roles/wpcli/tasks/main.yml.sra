(playbook "debops/ansible/roles/wpcli/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (wpcli__base_packages + wpcli__packages)) }}"))
        (state "present"))
      (register "wpcli__register_packages")
      (until "wpcli__register_packages is succeeded"))
    (task "Create wp-cli source directory"
      (ansible.builtin.file 
        (path (jinja "{{ wpcli__src }}"))
        (state "directory")
        (mode "0755")))
    (task "Download wp-cli release files"
      (ansible.builtin.get_url 
        (url (jinja "{{ item.url }}"))
        (dest (jinja "{{ item.dest }}"))
        (checksum (jinja "{{ item.checksum }}"))
        (mode "0644"))
      (loop (jinja "{{ wpcli__release_files }}"))
      (register "wpcli__register_release_files")
      (until "wpcli__register_release_files is succeeded")
      (when "item.version == wpcli__version"))
    (task "Verify and install wp-cli binary"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && gpg --batch --decrypt --output " (jinja "{{ wpcli__src + \"/wp-cli-\" + wpcli__version + \".phar\" }}") " \\ " (jinja "{{ wpcli__src + \"/wp-cli-\" + wpcli__version + \".phar.gpg\" }}") " && ( install --mode 755 --owner root --group root \\ " (jinja "{{ wpcli__src + \"/wp-cli-\" + wpcli__version + \".phar\" }}") " " (jinja "{{ wpcli__binary }}") " && install --mode 644 --owner root --group root \\ " (jinja "{{ wpcli__src + \"/wp-cli-\" + wpcli__version + \".completion.bash\" }}") " " (jinja "{{ wpcli__bash_completion }}") " ) || ( rm -f " (jinja "{{ wpcli__src + \"/wp-cli-\" + wpcli__version + \".phar\" }}") " && exit 2 )")
      (args 
        (executable "bash"))
      (when "wpcli__register_release_files is changed")
      (register "wpcli__register_install_files")
      (changed_when "wpcli__register_install_files.changed | bool"))
    (task "Install additional wp-cli scripts"
      (ansible.builtin.copy 
        (src "usr/local/bin/")
        (dest "/usr/local/bin/")
        (mode "0755")))
    (task "Manage wp-config.php security via cron"
      (ansible.builtin.cron 
        (name "Secure wp-config.php files on the server")
        (user "root")
        (cron_file "wpcli-secure-wpconfig")
        (job (jinja "{{ wpcli__secure_wpconfig_command }}"))
        (special_time (jinja "{{ wpcli__secure_wpconfig_interval }}"))
        (state (jinja "{{ \"present\" if wpcli__secure_wpconfig_enabled | bool else \"absent\" }}"))))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save wpcli local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/wpcli.fact.j2")
        (dest "/etc/ansible/facts.d/wpcli.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
