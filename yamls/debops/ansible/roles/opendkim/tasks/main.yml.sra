(playbook "debops/ansible/roles/opendkim/tasks/main.yml"
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
    (task "Install OpenDKIM support"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (opendkim__base_packages
                              + opendkim__packages)) }}"))
        (state "present"))
      (register "opendkim__register_packages")
      (until "opendkim__register_packages is succeeded")
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Divert original OpenDKIM configuration"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ item }}")))
      (loop (list
          "/etc/opendkim.conf"
          "/etc/default/opendkim"))
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Make sure Ansible local facts directory exists"
      (ansible.builtin.file 
        (dest "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Configure OpenDKIM local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/opendkim.fact.j2")
        (dest "/etc/ansible/facts.d/opendkim.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Generate OpenDKIM configuration from /etc"
      (ansible.builtin.template 
        (src "etc/opendkim.conf.j2")
        (dest "/etc/opendkim.conf")
        (owner "root")
        (group (jinja "{{ opendkim__group }}"))
        (mode "0640"))
      (notify (list
          "Check opendkim and reload")))
    (task "Generate OpenDKIM configuration from /etc/default"
      (ansible.builtin.template 
        (src "etc/default/opendkim.j2")
        (dest "/etc/default/opendkim")
        (mode "0644"))
      (notify (list
          "Check opendkim and reload")))
    (task "Ensure that opendkim.service.d directory exists"
      (ansible.builtin.file 
        (path "/etc/systemd/system/opendkim.service.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(ansible_service_mgr == 'systemd' and ansible_distribution_release not in ['trusty', 'xenial', 'bionic'])"))
    (task "Fix OpenDKIM issues with systemd"
      (ansible.builtin.template 
        (src "etc/systemd/system/opendkim.service.d/pid-socket.conf.j2")
        (dest "/etc/systemd/system/opendkim.service.d/pid-socket.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload service manager"
          "Check opendkim and restart"))
      (when "(ansible_service_mgr == 'systemd' and ansible_distribution_release not in ['trusty', 'xenial', 'bionic'])"))
    (task "Ensure that DomainKey directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ opendkim__dkimkeys_path }}"))
        (state "directory")
        (owner (jinja "{{ opendkim__user }}"))
        (group (jinja "{{ opendkim__group }}"))
        (mode "0700")))
    (task "Install helper scripts on Ansible Controller"
      (ansible.builtin.copy 
        (src "secret/opendkim/lib/")
        (dest (jinja "{{ secret + \"/opendkim/lib/\" }}"))
        (mode "0755"))
      (become "False")
      (delegate_to "localhost")
      (run_once "True"))
    (task "Generate DomainKeys on Ansible Controller"
      (community.crypto.openssl_privatekey 
        (size (jinja "{{ item.size | d(opendkim__default_key_size) }}"))
        (type (jinja "{{ (item.type | d(\"rsa\")) | upper }}"))
        (path (jinja "{{ secret + \"/opendkim/domainkeys/\"
               + (item.domain | d(opendkim__domain)) + \"_\"
               + (item.selector | d(item.name | d(item))) + \".pem\" }}"))
        (regenerate (jinja "{{ item.regenerate | d(\"full_idempotence\"
                                        if ansible_version.full is version(\"2.10\", \">=\")
                                        else omit) }}")))
      (loop (jinja "{{ q(\"flattened\", opendkim__combined_keys) }}"))
      (become "False")
      (delegate_to "localhost")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove DomainKeys from hosts when requested"
      (ansible.builtin.file 
        (path (jinja "{{ opendkim__dkimkeys_path + \"/\"
              + (item.domain | d(opendkim__domain)) + \"_\"
              + (item.selector | d(item.name | d(item))) + \".pem\" }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", opendkim__combined_keys) }}"))
      (when "item.state | d('present') == 'absent'"))
    (task "Download DomainKeys from Ansible Controller"
      (ansible.builtin.copy 
        (src (jinja "{{ secret + \"/opendkim/domainkeys/\"
              + (item.domain | d(opendkim__domain)) + \"_\"
              + (item.selector | d(item.name | d(item))) + \".pem\" }}"))
        (dest (jinja "{{ opendkim__dkimkeys_path + \"/\"
              + (item.domain | d(opendkim__domain)) + \"_\"
              + (item.selector | d(item.name | d(item))) + \".pem\" }}"))
        (owner "root")
        (group (jinja "{{ opendkim__group }}"))
        (mode "0640"))
      (loop (jinja "{{ q(\"flattened\", opendkim__combined_keys) }}"))
      (when "item.state | d('present') != 'absent'")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate key configuration files"
      (ansible.builtin.template 
        (src "etc/dkimkeys/" (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ opendkim__dkimkeys_path + \"/\" + item }}"))
        (owner "root")
        (group (jinja "{{ opendkim__group }}"))
        (mode "0640"))
      (notify (list
          "Check opendkim and reload"))
      (with_items (list
          "KeyTable"
          "SigningTable"
          "TrustedHosts")))
    (task "Create OpenDKIM socket directory in Postfix chroot"
      (ansible.builtin.file 
        (path "/var/spool/postfix/opendkim")
        (state "directory")
        (owner (jinja "{{ opendkim__user }}"))
        (group (jinja "{{ opendkim__postfix_group }}"))
        (mode "02750"))
      (when "opendkim__postfix_integration | bool")
      (notify (list
          "Check opendkim and restart")))))
