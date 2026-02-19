(playbook "debops/ansible/roles/sshd/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Pre hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"sshd/pre_main.yml\") }}")))
    (task "Make sure that Ansible local fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Ansible local fact script"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/sshd.fact.j2")
        (dest "/etc/ansible/facts.d/sshd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload Ansible local facts"
      (ansible.builtin.meta "flush_handlers"))
    (task "Make sure that OpenSSH configuration directory exists"
      (ansible.builtin.file 
        (path "/etc/ssh")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Block OpenSSH server from starting immediately when installed"
      (ansible.builtin.copy 
        (dest "/etc/ssh/sshd_not_to_be_run")
        (content "This file disables the ssh server.  It was created by debops.sshd.
This file will be removed when configuration is successfully completed.
")
        (mode "0644"))
      (when "(ansible_local | d() and ansible_local.sshd | d() and not (ansible_local.sshd.installed | d()) | bool)"))
    (task "Ensure that the '/run/sshd' directory exists on first install"
      (ansible.builtin.file 
        (path "/run/sshd")
        (state "directory")
        (mode "0755")))
    (task "Ensure OpenSSH support is installed"
      (ansible.builtin.apt 
        (name (jinja "{{ (sshd__base_packages
             + sshd__recommended_packages
             + sshd__optional_packages
             + sshd__ldap_packages
             + sshd__packages)
             | flatten }}"))
        (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.sshd | d())
               else \"latest\" }}"))
        (install_recommends "False"))
      (register "sshd__register_packages")
      (notify (list
          "Refresh host facts"))
      (until "sshd__register_packages is succeeded"))
    (task "Reload Ansible local facts"
      (ansible.builtin.meta "flush_handlers"))
    (task "Ensure that Ed25519 host key is present"
      (ansible.builtin.command "ssh-keygen -q -t ed25519 -N \"\" -f ssh_host_ed25519_key")
      (args 
        (chdir "/etc/ssh")
        (creates "/etc/ssh/ssh_host_ed25519_key"))
      (when "sshd__version is version('6.5', '>=')")
      (tags (list
          "role::sshd:config")))
    (task "Configure authorized_keys lookup"
      (ansible.builtin.include_tasks "authorized_keys_lookup.yml")
      (when "sshd__version is version('6.2', '>=') and sshd__authorized_keys_lookup | bool")
      (tags (list
          "role::sshd:config")))
    (task "Get list of available host keys"
      (ansible.builtin.shell "find /etc/ssh -maxdepth 1 -type f -name 'ssh_host_*_key.pub' -exec basename {} .pub \\;")
      (register "sshd__register_host_keys")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "role::sshd:config")))
    (task "Get list of available host certs"
      (ansible.builtin.shell "find /etc/ssh -maxdepth 1 -type f -name 'ssh_host_*_key-cert.pub' -exec basename {} .pub \\;")
      (register "sshd__register_host_certs")
      (changed_when "False")
      (check_mode "False")
      (when "sshd__scan_for_host_certs | bool")
      (tags (list
          "role::sshd:config")))
    (task "Setup trusted user CA key file"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/ssh/trusted_user_ca_file.pem.j2\") }}"))
        (dest (jinja "{{ sshd__trusted_user_ca_keys_file }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "sshd__trusted_user_ca_keys | d() | length > 0 and sshd__trusted_user_ca_keys_file is defined")
      (tags (list
          "role::sshd:config")))
    (task "Setup /etc/ssh/sshd_config"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/ssh/sshd_config.j2\") }}"))
        (dest "/etc/ssh/sshd_config")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Test sshd configuration and restart"))
      (tags (list
          "role::sshd:config")))
    (task "Configuration of additional SSH ports with socket activation"
      (block (list
          
          (name "Create systemd override directory if needed")
          (ansible.builtin.file 
            (path "/etc/systemd/system/ssh.socket.d")
            (state "directory")
            (mode "0755"))
          
          (name "Generate systemd socket configuration")
          (ansible.builtin.template 
            (src "etc/systemd/system/ssh.socket.d/listen.conf.j2")
            (dest "/etc/systemd/system/ssh.socket.d/listen.conf")
            (mode "0644"))
          (notify (list
              "Reload systemd daemon"))))
      (when "(sshd__ports | length > 1 and ansible_service_mgr == 'systemd' and (ansible_local.sshd.socket_activation | d('disabled')) == 'enabled')"))
    (task "Make sure the system-wide known_hosts file exists"
      (ansible.builtin.command "touch " (jinja "{{ sshd__known_hosts_file }}"))
      (args 
        (creates (jinja "{{ sshd__known_hosts_file }}")))
      (tags (list
          "role::sshd:known_hosts")))
    (task "Get list of already scanned host fingerprints"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && ssh-keygen -f " (jinja "{{ sshd__known_hosts_file }}") " -F " (jinja "{{ item }}") " | grep -q '^# Host " (jinja "{{ item }}") " found'")
      (args 
        (executable "bash"))
      (loop (jinja "{{ q(\"flattened\", sshd__known_hosts
                           + sshd__group_known_hosts
                           + sshd__host_known_hosts) }}"))
      (when "item is defined and item")
      (register "sshd__register_known_hosts")
      (changed_when "False")
      (failed_when "False")
      (check_mode "False")
      (tags (list
          "role::sshd:known_hosts")))
    (task "Scan SSH fingerprints of specified hosts"
      (ansible.builtin.shell (jinja "{{ sshd__known_hosts_command }}") " " (jinja "{{ item.item }}") " >> " (jinja "{{ sshd__known_hosts_file }}"))
      (with_items (jinja "{{ sshd__register_known_hosts.results | d([]) }}"))
      (register "sshd__register_known_hosts_scan")
      (changed_when "sshd__register_known_hosts_scan.changed | bool")
      (when "item is defined and item.rc > 0")
      (tags (list
          "role::sshd:known_hosts")))
    (task "Check if /etc/ssh/moduli contains weak DH parameters"
      (ansible.builtin.shell "awk '$5 < " (jinja "{{ (sshd__moduli_minimum | int - 1) }}") "' /etc/ssh/moduli")
      (register "sshd__register_moduli")
      (changed_when "sshd__register_moduli.stdout")
      (check_mode "False"))
    (task "Remove DH parameters smaller than the requested size"
      (ansible.builtin.shell "awk '$5 >= " (jinja "{{ (sshd__moduli_minimum | int - 1) }}") "' /etc/ssh/moduli > /etc/ssh/moduli.new ; [ -r /etc/ssh/moduli.new -a -s /etc/ssh/moduli.new ] && mv /etc/ssh/moduli.new /etc/ssh/moduli || true")
      (notify (list
          "Test sshd configuration and restart"))
      (register "sshd__register_moduli")
      (changed_when "sshd__register_moduli.changed | bool")
      (when "sshd__register_moduli.stdout"))
    (task "Remove block on OpenSSH server startup"
      (ansible.builtin.file 
        (name "/etc/ssh/sshd_not_to_be_run")
        (state "absent"))
      (notify (list
          "Test sshd configuration and restart")))
    (task "Add/remove diversion of /etc/pam.d/sshd"
      (debops.debops.dpkg_divert 
        (path "/etc/pam.d/sshd")
        (state (jinja "{{ \"present\"
               if sshd__pam_deploy_state | d(\"present\") != \"absent\"
               else \"absent\" }}"))
        (delete "True")))
    (task "Generate /etc/pam.d/sshd configuration"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/pam.d/sshd.j2\") }}"))
        (dest "/etc/pam.d/sshd")
        (mode "0644"))
      (when "sshd__pam_deploy_state == 'present'"))
    (task "Post hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"sshd/post_main.yml\") }}")))))
