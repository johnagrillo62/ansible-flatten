(playbook "debops/ansible/roles/keyring/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Get list of local GPG key fingerprints on Ansible Controller"
      (ansible.builtin.set_fact 
        (keyring__fact_local_keys (jinja "{{ (q(\"fileglob\", (keyring__local_path + \"/*.asc\"))
                                     | map(\"basename\") | map(\"replace\", \" \", \"\")
                                     | map(\"regex_replace\", \"^0x(.*)\\.asc\", \"\\1\")
                                     | list) if keyring__local_path | d() else [] }}"))))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (keyring__base_packages + keyring__packages)) }}"))
        (state "present"))
      (when "keyring__enabled | bool and ansible_pkg_mgr == 'apt'"))
    (task "Make sure that Ansible local fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save keyring local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/keyring.fact.j2")
        (dest "/etc/ansible/facts.d/keyring.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Import specified GPG keys to APT keyring"
      (ansible.builtin.apt_key 
        (id (jinja "{{ (item.id | d(item)) | replace(\" \", \"\") }}"))
        (data (jinja "{{ item.data | d((lookup(\"file\", keyring__local_path + \"/0x\" + ((item.id | d(item)) | replace(\" \", \"\")) + \".asc\"))
                            if (item.state | d(\"present\") != \"absent\" and item.url is undefined and item.keybase is undefined and
                                ((item.id | d(item)) | replace(\" \", \"\")) in keyring__fact_local_keys)
                            else omit) }}"))
        (keyserver (jinja "{{ item.keyserver | d(keyring__keyserver
                                      if (keyring__keyserver | d() and item.url is undefined and item.keybase is undefined and
                                          ((item.id | d(item)) | replace(\" \", \"\")) not in keyring__fact_local_keys)
                                      else omit) }}"))
        (keyring (jinja "{{ item.keyring | d(omit) }}"))
        (url (jinja "{{ item.url | d((keyring__keybase_api + item.keybase
                           + \"/pgp_keys.asc?fingerprint=\" + ((item.id | d(item)) | replace(\" \", \"\")))
                          if item.keybase | d() else omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (loop (jinja "{{ q(\"flattened\", (keyring__dependent_apt_keys)) }}"))
      (register "keyring__register_apt_key")
      (until "keyring__register_apt_key is succeeded")
      (when "keyring__enabled | bool and ansible_pkg_mgr == 'apt' and (item.id | d() or item is string) and (item.extrepo is undefined or item.extrepo not in (ansible_local.extrepo.sources | d([])))")
      (tags (list
          "role::keyring:apt_key")))
    (task "Configure specified upstream APT repositories"
      (ansible.builtin.apt_repository 
        (repo (jinja "{{ item.repo }}"))
        (filename (jinja "{{ item.filename | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (update_cache "False"))
      (loop (jinja "{{ q(\"flattened\", (keyring__dependent_apt_keys)) }}"))
      (register "keyring__register_apt_repository")
      (when "keyring__enabled | bool and ansible_pkg_mgr == 'apt' and item.repo | d() and (item.extrepo is undefined or item.extrepo not in (ansible_local.extrepo.sources | d([])))")
      (tags (list
          "role::keyring:apt_repository")))
    (task "Remove APT auth configuration if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/apt/auth.conf.d/\" + (item.name | regex_replace(\".conf$\", \"\")) + \".conf\" }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", (keyring__dependent_apt_auth_files)) }}"))
      (when "keyring__enabled | bool and ansible_pkg_mgr == 'apt' and item.state | d('present') == 'absent'")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate APT auth configuration"
      (ansible.builtin.template 
        (src "etc/apt/auth.conf.d/template.conf.j2")
        (dest (jinja "{{ \"/etc/apt/auth.conf.d/\" + (item.name | regex_replace(\".conf$\", \"\")) + \".conf\" }}"))
        (mode "0640"))
      (loop (jinja "{{ q(\"flattened\", (keyring__dependent_apt_auth_files)) }}"))
      (when "keyring__enabled | bool and ansible_pkg_mgr == 'apt' and item.machine | d() and item.login | d() and item.password | d() and item.state | d('present') not in ['absent', 'ignore']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Update APT cache when needed"
      (ansible.builtin.apt 
        (update_cache "True"))
      (when "keyring__enabled | bool and ansible_pkg_mgr == 'apt' and keyring__register_apt_repository is changed")
      (tags (list
          "role::keyring:apt_repository")))
    (task "Ensure that required UNIX groups exist"
      (ansible.builtin.group 
        (name (jinja "{{ item.group | d(item.user) }}"))
        (state "present")
        (system (jinja "{{ item.system | d(True) }}")))
      (loop (jinja "{{ q(\"flattened\", (keyring__dependent_gpg_keys)) }}"))
      (when "keyring__enabled | bool and (item.create_user | d(True)) | bool and item.user | d() and item.state | d('present') not in ['absent', 'ignore']"))
    (task "Ensure that required UNIX accounts exist"
      (ansible.builtin.user 
        (name (jinja "{{ item.user }}"))
        (group (jinja "{{ item.group | d(item.user) }}"))
        (home (jinja "{{ item.home | d(omit) }}"))
        (system (jinja "{{ item.system | d(True) }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", (keyring__dependent_gpg_keys)) }}"))
      (when "keyring__enabled | bool and (item.create_user | d(True)) | bool and item.user | d() and item.state | d('present') not in ['absent', 'ignore']"))
    (task "Gather information about existing UNIX accounts"
      (ansible.builtin.getent 
        (database "passwd"))
      (check_mode "False"))
    (task "Import specified GPG keys to account keyring"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && " (jinja "{{ keyring__var_gpg_command }}") " --list-keys '" (jinja "{{ (item.id | d(item)) | replace(\" \", \"\") }}") "' " (jinja "{% if item.state | d('present') == 'absent' %}") " && ( printf \"Removing key...\\n\" && " (jinja "{{ keyring__var_gpg_command }}") " --delete-key " (jinja "{{ (item.id | d(item)) | replace(\" \", \"\") }}") " ) || true " (jinja "{% else %}") " " (jinja "{% if ((item.id | d(item)) | replace(\" \", \"\")) not in keyring__fact_local_keys %}") " " (jinja "{% if item.url | d() %}") " || ( printf \"Adding key...\\n\" && curl " (jinja "{{ item.url }}") " | " (jinja "{{ keyring__var_gpg_command }}") " --import - ) " (jinja "{% elif item.keybase | d() %}") " || ( printf \"Adding key...\\n\" && curl " (jinja "{{ keyring__keybase_api + item.keybase
                                                  + '/pgp_keys.asc?fingerprint='
                                                  + ((item.id | d(item)) | replace(\" \", \"\")) }}") " | " (jinja "{{ keyring__var_gpg_command }}") " --import - ) " (jinja "{% elif (item.keyserver | d(keyring__keyserver if keyring__keyserver | d() else False)) %}") " || ( printf \"Adding key...\\n\" && gpg --keyserver " (jinja "{{ item.keyserver | d(keyring__keyserver if keyring__keyserver else \"\") }}") " \\ --batch --recv-key " (jinja "{{ (item.id | d(item)) | replace(\" \", \"\") }}") " && gpgconf --kill all ) " (jinja "{% endif %}") " " (jinja "{% else %}") " || ( printf \"Adding key...\\n\" && " (jinja "{{ keyring__var_gpg_command }}") " --import - ) " (jinja "{% endif %}") " " (jinja "{% endif %}"))
      (vars 
        (keyring__var_gpg_command (jinja "{{ \"gpg --batch\"
                                  if (keyring__gpg_version is version(\"2.0.0\", \"<\"))
                                  else \"gpg --no-autostart --batch\" }}")))
      (args 
        (executable "bash")
        (stdin (jinja "{{ item.data | d((lookup(\"file\", keyring__local_path + \"/0x\" + ((item.id | d(item)) | replace(\" \", \"\")) + \".asc\"))
                             if (item.state | d(\"present\") != \"absent\" and
                                 ((item.id | d(item)) | replace(\" \", \"\")) in keyring__fact_local_keys)
                             else omit) }}")))
      (become "True")
      (become_user (jinja "{{ item.user | d(keyring__dependent_gpg_user if keyring__dependent_gpg_user | d() else \"root\") }}"))
      (loop (jinja "{{ q(\"flattened\", (keyring__dependent_gpg_keys)) }}"))
      (register "keyring__register_gpg_key")
      (until "keyring__register_gpg_key.rc | d(0) == 0")
      (when "(keyring__enabled | bool and (item.id | d() or item is string) and (item.user | d(keyring__dependent_gpg_user if keyring__dependent_gpg_user | d() else \"root\")) in getent_passwd.keys())")
      (changed_when "(\"Adding key...\" in keyring__register_gpg_key.stdout_lines) or (\"Removing key...\" in keyring__register_gpg_key.stdout_lines)"))))
