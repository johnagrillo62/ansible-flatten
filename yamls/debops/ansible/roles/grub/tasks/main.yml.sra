(playbook "debops/ansible/roles/grub/tasks/main.yml"
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
    (task "Create /etc/default/grub.d directory"
      (ansible.builtin.file 
        (path "/etc/default/grub.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Generate GRUB configuration file"
      (ansible.builtin.template 
        (src "etc/default/grub.d/ansible.cfg.j2")
        (dest "/etc/default/grub.d/ansible.cfg")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Update GRUB")))
    (task "Ensure secrets directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ secret + \"/credentials/\" + inventory_hostname + \"/grub/\" + item.name }}"))
        (state "directory")
        (mode "0750"))
      (with_items (jinja "{{ grub__combined_users }}"))
      (become "False")
      (delegate_to "localhost")
      (when "item.name | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Save plaintext password in secrets"
      (ansible.builtin.copy 
        (content (jinja "{{ item.password + '\\n' }}"))
        (dest (jinja "{{ secret + \"/credentials/\" + inventory_hostname + \"/grub/\" + item.name + \"/password\" }}"))
        (mode "0640"))
      (with_items (jinja "{{ grub__combined_users }}"))
      (register "grub__register_pw_plain")
      (become "False")
      (delegate_to "localhost")
      (when "item.name | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Save temporary grub-mkpasswd formatted password in secrets"
      (ansible.builtin.template 
        (src "secret/credentials/inventory_hostname/grub/user_name/password_mkpasswd.j2")
        (dest (jinja "{{ secret + \"/credentials/\" + inventory_hostname + \"/grub/\" + item.0.name + \"/password_mkpasswd\" }}"))
        (mode "0640"))
      (with_together (list
          (jinja "{{ grub__combined_users }}")
          (jinja "{{ grub__register_pw_plain.results | d({}) }}")))
      (become "False")
      (delegate_to "localhost")
      (when "(item.0.name | d() and item.1 is changed)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate salted hash from user password"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && cat '" (jinja "{{ (secret + \"/credentials/\" + inventory_hostname + \"/grub/\" + item.0.name + \"/password_mkpasswd\") | quote }}") "' | LANG=C LC_ALL=C grub-mkpasswd-pbkdf2 " (jinja "{{ \"\" if grub__iter_time | d() == \"default\" else (\"--iteration-count=\" + grub__iter_time) }}") " " (jinja "{{ \"\" if grub__salt_length | d() == \"default\" else (\"--salt=\" + grub__salt_length) }}") " " (jinja "{{ \"\" if grub__hash_length | d() == \"default\" else (\"--buflen=\" + grub__hash_length) }}") " | perl -ne 's/^(:?Your PBKDF2|PBKDF2 hash of your password) is //ms && print'")
      (environment 
        (GRUB_PLAINTEXT_PASSWORD (jinja "{{ item.0.password }}")))
      (args 
        (executable "bash"))
      (with_together (list
          (jinja "{{ grub__combined_users }}")
          (jinja "{{ grub__register_pw_plain.results | d({}) }}")))
      (register "grub__register_pw_hashes")
      (become "False")
      (delegate_to "localhost")
      (changed_when "False")
      (when "(item.0.name | d() and item.1 is changed)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove temporary grub-mkpassword formatted password"
      (ansible.builtin.file 
        (path (jinja "{{ secret + \"/credentials/\" + inventory_hostname + \"/grub/\" + item.0.name + \"/password_mkpasswd\" }}"))
        (state "absent"))
      (with_together (list
          (jinja "{{ grub__combined_users }}")
          (jinja "{{ grub__register_pw_plain.results | d({}) }}")))
      (become "False")
      (delegate_to "localhost")
      (when "(item.0.name | d() and item.1 is changed)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Save hashed password in secrets"
      (ansible.builtin.copy 
        (content (jinja "{{ item.1.stdout_lines.0 + '\\n' }}"))
        (dest (jinja "{{ secret + \"/credentials/\" + inventory_hostname + \"/grub/\" + item.0.name + \"/password_hash\" }}"))
        (mode "0640"))
      (with_together (list
          (jinja "{{ grub__combined_users }}")
          (jinja "{{ grub__register_pw_hashes.results | d({}) }}")))
      (become "False")
      (delegate_to "localhost")
      (when "(item.1 is not skipped)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Configure users and passwords"
      (ansible.builtin.template 
        (src "etc/grub.d/01_users.j2")
        (dest "/etc/grub.d/01_users")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(not ansible_check_mode and grub__combined_users | length > 0)")
      (notify (list
          "Update GRUB")))
    (task "Remove users and passwords"
      (ansible.builtin.file 
        (path "/etc/grub.d/01_users")
        (state "absent"))
      (when "(grub__combined_users | length == 0)")
      (notify (list
          "Update GRUB")))
    (task "Add/remove diversion of /etc/grub.d/10_linux"
      (debops.debops.dpkg_divert 
        (path "/etc/grub.d/10_linux")
        (state (jinja "{{ \"present\" if grub__combined_users | length > 0 else \"absent\" }}"))
        (delete "True"))
      (notify (list
          "Update GRUB")))
    (task "Copy /etc/grub.d/10_linux.dpkg-divert to its original location"
      (ansible.builtin.copy 
        (src "/etc/grub.d/10_linux.dpkg-divert")
        (dest "/etc/grub.d/10_linux")
        (remote_src "True")
        (force "False")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(grub__combined_users | length > 0)"))
    (task "Allow configuration of the default menu entry parameters"
      (ansible.builtin.replace 
        (dest "/etc/grub.d/10_linux")
        (regexp "^CLASS=(?:\\$\\{[A-Z_]+:-)?([\"'][\\w _-]+)([\"'])\\}?")
        (replace "CLASS=${GRUB_LINUX_MENUENTRY_CLASS:-\\1 ${GRUB_LINUX_MENUENTRY_CLASS_ADDITIONAL:-}\\2}")
        (mode "0755"))
      (notify (list
          "Update GRUB"))
      (when "(grub__combined_users | length > 0)"))
    (task "Make sure that local fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save local GRUB facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/grub.fact.j2")
        (dest "/etc/ansible/facts.d/grub.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
