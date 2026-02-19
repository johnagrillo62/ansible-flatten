(playbook "debops/ansible/roles/owncloud/tasks/tarball.yml"
  (tasks
    (task "Create Nextcloud group"
      (ansible.builtin.group 
        (name (jinja "{{ owncloud__system_group }}"))
        (state "present")
        (system "True"))
      (tags (list
          "role::nextcloud:download"
          "role::nextcloud:verify")))
    (task "Create Nextcloud user"
      (ansible.builtin.user 
        (name (jinja "{{ owncloud__system_user }}"))
        (group (jinja "{{ owncloud__system_group }}"))
        (home (jinja "{{ owncloud__system_home }}"))
        (comment (jinja "{{ owncloud__comment }}"))
        (shell (jinja "{{ owncloud__shell }}"))
        (system "True")
        (state "present"))
      (tags (list
          "role::nextcloud:download"
          "role::nextcloud:verify")))
    (task "Create source directory"
      (ansible.builtin.file 
        (path (jinja "{{ owncloud__src }}"))
        (state "directory")
        (owner (jinja "{{ owncloud__system_user }}"))
        (group (jinja "{{ owncloud__system_group }}"))
        (mode "0755")))
    (task "Create deployment directory"
      (ansible.builtin.file 
        (path (jinja "{{ owncloud__deploy_path }}"))
        (state "directory")
        (owner (jinja "{{ owncloud__app_user }}"))
        (group (jinja "{{ owncloud__app_group }}"))
        (mode (jinja "{{ owncloud__deploy_path_mode }}"))))
    (task "Download and validate the tarball"
      (block (list
          
          (name "Query for the full version string of the current release")
          (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && curl -s -m 900 " (jinja "{{ (owncloud__variant_download_url_map[owncloud__variant] + \"/\") | quote }}") " | sed --silent 's/.*href=\"nextcloud-\\(" (jinja "{{ owncloud__release | regex_escape() }}") "[^\"]\\+\\).zip.asc\".*/\\1/p' | sort --version-sort --reverse")
          (args 
            (executable "bash"))
          (register "owncloud__register_full_version")
          (changed_when "False")
          (check_mode "False")
          (tags (list
              "role::nextcloud:verify"))
          
          (name "Create source directories")
          (ansible.builtin.file 
            (path (jinja "{{ owncloud__src + \"/\" + owncloud__variant + \"/\" + owncloud__register_full_version.stdout_lines[0] }}"))
            (state "directory")
            (owner (jinja "{{ owncloud__system_user }}"))
            (group (jinja "{{ owncloud__system_group }}"))
            (mode "0755"))
          (tags (list
              "role::nextcloud:download"
              "role::nextcloud:verify"))
          
          (name "Download application files needed for verification")
          (ansible.builtin.get_url 
            (url (jinja "{{ owncloud__variant_download_url_map[owncloud__variant] + \"/\" +
                 owncloud__variant + \"-\" + owncloud__register_full_version.stdout_lines[0] + \".\" + item }}"))
            (dest (jinja "{{ owncloud__src + \"/\" + owncloud__variant + \"/\" + owncloud__register_full_version.stdout_lines[0] }}"))
            (mode "0644"))
          (with_items (list
              "zip.asc"
              "zip.sha512"))
          (register "owncloud__register_download_assurance")
          (until "owncloud__register_download_assurance is succeeded")
          (when "not ansible_check_mode")
          (tags (list
              "role::nextcloud:download"
              "role::nextcloud:verify"))
          
          (name "Read checksum from file")
          (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && cat " (jinja "{{ owncloud__src + \"/\" + owncloud__variant + \"/\"
                    + owncloud__register_full_version.stdout_lines[0] + \"/\"
                    + owncloud__variant + \"-\" + owncloud__register_full_version.stdout_lines[0]
                    + \".zip.sha512\" }}") " | grep '.zip$'")
          (args 
            (executable "bash"))
          (changed_when "False")
          (register "owncloud__register_checksum")
          (when "not ansible_check_mode")
          (tags (list
              "role::nextcloud:download"
              "role::nextcloud:verify"))
          
          (name "Download application archive")
          (ansible.builtin.get_url 
            (url (jinja "{{ owncloud__variant_download_url_map[owncloud__variant] + \"/\" +
                 owncloud__variant + \"-\" + owncloud__register_full_version.stdout_lines[0] + \".zip\" }}"))
            (dest (jinja "{{ owncloud__src + \"/\" + owncloud__variant + \"/\" + owncloud__register_full_version.stdout_lines[0] }}"))
            (checksum "sha512:" (jinja "{{ (owncloud__register_checksum.stdout_lines[0]).split(\" \") | first }}"))
            (mode "0644"))
          (register "owncloud__register_download_application")
          (until "owncloud__register_download_application is succeeded")
          (when "owncloud__register_download_assurance is changed")
          (tags (list
              "role::nextcloud:download"
              "role::nextcloud:verify"))
          
          (name "Verify OpenPGP signature")
          (environment 
            (LC_MESSAGES "C"))
          (ansible.builtin.shell "set -o nounset -o pipefail -o errexit
gpg --verify " (jinja "{{ owncloud__src + \"/\" + owncloud__variant + \"/\"
                + owncloud__register_full_version.stdout_lines[0] + \"/\"
                + owncloud__variant + \"-\" + owncloud__register_full_version.stdout_lines[0]
                + \".zip.asc\" }}") " \\
             " (jinja "{{ owncloud__src + \"/\" + owncloud__variant + \"/\"
                + owncloud__register_full_version.stdout_lines[0] + \"/\"
                + owncloud__variant + \"-\" + owncloud__register_full_version.stdout_lines[0]
                + \".zip\" }}") " 2>&1 \\
  | sed --silent 's/^Primary key fingerprint: \\(.*\\)$/\\1/p;'
")
          (args 
            (executable "bash"))
          (changed_when "False")
          (register "owncloud__register_verify_authenticity")
          (failed_when "(owncloud__register_verify_authenticity.rc != 0 or (owncloud__register_verify_authenticity.stdout | replace(\" \", \"\")) != (owncloud__upstream_key_fingerprint | replace(\" \", \"\")))")
          (tags (list
              "role::nextcloud:verify"))))
      (become "True")
      (become_user (jinja "{{ owncloud__system_user }}")))
    (task "Unpack the application archive"
      (ansible.builtin.unarchive 
        (remote_src "True")
        (src (jinja "{{ owncloud__src + \"/\" + owncloud__variant + \"/\" + owncloud__register_full_version.stdout_lines[0] + \"/\" +
             owncloud__variant + \"-\" + owncloud__register_full_version.stdout_lines[0] + \".zip\" }}"))
        (dest (jinja "{{ owncloud__deploy_path + \"/..\" }}"))
        (owner (jinja "{{ owncloud__app_user }}"))
        (group (jinja "{{ owncloud__app_group }}"))
        (mode "u=rwX,g=rX,o=rX")
        (creates (jinja "{{ owncloud__deploy_path + \"/index.php\" }}"))))))
