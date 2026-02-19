(playbook "debops/ansible/roles/etesync/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (etesync__base_packages
                              + etesync__packages)) }}"))
        (state "present"))
      (register "etesync__register_packages")
      (until "etesync__register_packages is succeeded"))
    (task "Create EteSync system group"
      (ansible.builtin.group 
        (name (jinja "{{ etesync__group }}"))
        (state "present")
        (system "True")))
    (task "Create EteSync system user"
      (ansible.builtin.user 
        (name (jinja "{{ etesync__user }}"))
        (group (jinja "{{ etesync__group }}"))
        (home (jinja "{{ etesync__home }}"))
        (comment (jinja "{{ etesync__gecos }}"))
        (shell (jinja "{{ etesync__shell }}"))
        (state "present")
        (system "True")))
    (task "Create additional directories used by EteSync"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ etesync__user }}"))
        (group (jinja "{{ etesync__group }}"))
        (mode "0755"))
      (with_items (list
          (jinja "{{ etesync__etc }}")
          (jinja "{{ etesync__src }}")
          (jinja "{{ etesync__git_dest | dirname }}")
          (jinja "{{ etesync__lib }}")
          (jinja "{{ etesync__data }}"))))
    (task "Clone EteSync source code"
      (ansible.builtin.git 
        (repo (jinja "{{ etesync__git_repo }}"))
        (dest (jinja "{{ etesync__git_checkout }}"))
        (separate_git_dir (jinja "{{ etesync__git_dest }}"))
        (version (jinja "{{ etesync__git_version }}"))
        (update "True"))
      (become "True")
      (become_user (jinja "{{ etesync__user }}"))
      (register "etesync__register_source"))
    (task "Verify git tag signature"
      (ansible.builtin.shell "git verify-tag --raw \"$(git describe)\"")
      (args 
        (chdir (jinja "{{ etesync__git_checkout }}")))
      (become "True")
      (become_user (jinja "{{ etesync__user }}"))
      (changed_when "False"))
    (task "Install EteSync requirements in virtualenv"
      (ansible.builtin.pip 
        (virtualenv (jinja "{{ etesync__virtualenv }}"))
        (virtualenv_python "python3")
        (virtualenv_site_packages "True")
        (requirements (jinja "{{ etesync__git_checkout + \"/requirements.txt\" }}"))
        (extra_args "--upgrade"))
      (register "etesync__register_pip_install")
      (until "etesync__register_pip_install is succeeded")
      (become "True")
      (become_user (jinja "{{ etesync__user }}"))
      (notify (list
          "Restart gunicorn for etesync"))
      (when "etesync__register_source is changed"))
    (task "Clean up stale Python bytecode"
      (ansible.builtin.command "find . -name '*.pyc' -delete")
      (args 
        (chdir (jinja "{{ etesync__git_checkout }}")))
      (become "True")
      (become_user (jinja "{{ etesync__user }}"))
      (register "etesync__register_cleanup")
      (changed_when "etesync__register_cleanup.changed | bool")
      (when "etesync__register_source is changed"))
    (task "Exclude secret files from etckeeper"
      (ansible.builtin.copy 
        (content "secret.txt
")
        (dest (jinja "{{ etesync__etc + \"/.gitignore\" }}"))
        (owner "root")
        (group "root")
        (mode "0600"))
      (tags (list
          "role::etesync:config")))
    (task "Generate EteSync configuration"
      (ansible.builtin.template 
        (src "etc/etesync-server/etesync-server.ini.j2")
        (dest (jinja "{{ etesync__etc + \"/etesync-server.ini\" }}"))
        (owner "root")
        (group (jinja "{{ etesync__group }}"))
        (mode "0640"))
      (register "etesync__register_config")
      (notify (list
          "Restart gunicorn for etesync"))
      (tags (list
          "role::etesync:config")))
    (task "Generate extended EteSync configuration"
      (ansible.builtin.template 
        (src "usr/local/lib/etesync/app/etesync_site_settings.py.j2")
        (dest (jinja "{{ etesync__git_checkout + \"/etesync_site_settings.py\" }}"))
        (owner (jinja "{{ etesync__user }}"))
        (group (jinja "{{ etesync__group }}"))
        (mode "0640"))
      (register "etesync__register_config")
      (notify (list
          "Restart gunicorn for etesync"))
      (tags (list
          "role::etesync:config")))
    (task "Generate EteSync secret.txt file"
      (ansible.builtin.template 
        (src "etc/etesync-server/secret.txt.j2")
        (dest (jinja "{{ etesync__config_secret_key_filepath }}"))
        (owner "root")
        (group (jinja "{{ etesync__group }}"))
        (mode "0640"))
      (notify (list
          "Restart gunicorn for etesync"))
      (tags (list
          "role::etesync:config")))
    (task "Perform database installation or migration"
      (ansible.builtin.shell "set -o pipefail -o errexit;
source " (jinja "{{ etesync__virtualenv }}") "/bin/activate
./manage.py migrate
")
      (args 
        (chdir (jinja "{{ etesync__git_checkout }}"))
        (executable "bash"))
      (become "True")
      (become_user (jinja "{{ etesync__user }}"))
      (changed_when "(\"No migrations to apply.\" not in etesync__register_migration.stdout)")
      (when "etesync__register_source is changed or etesync__register_config is changed")
      (register "etesync__register_migration"))
    (task "Create superuser account"
      (ansible.builtin.shell "set -o pipefail -o errexit; source " (jinja "{{ etesync__virtualenv }}") "/bin/activate; echo \"from django.contrib.auth.models import User; User.objects.create_superuser('${SUPERUSER_NAME}', '${SUPERUSER_EMAIL}', '${SUPERUSER_PASSWORD}')\" | ./manage.py shell")
      (environment 
        (SUPERUSER_NAME (jinja "{{ etesync__superuser_name }}"))
        (SUPERUSER_EMAIL (jinja "{{ etesync__superuser_email }}"))
        (SUPERUSER_PASSWORD (jinja "{{ etesync__superuser_password }}")))
      (args 
        (chdir (jinja "{{ etesync__git_checkout }}"))
        (executable "bash"))
      (become "True")
      (become_user (jinja "{{ etesync__user }}"))
      (register "etesync__register_superuser")
      (changed_when "etesync__register_superuser.changed | bool")
      (when "(\"etesync\" not in ansible_local)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Send mail with the full URL of the EteSync server"
      (community.general.mail 
        (from "root@" (jinja "{{ ansible_fqdn }}"))
        (subject (jinja "{{ etesync__mail_subject }}"))
        (to (jinja "{{ etesync__mail_to | d([]) | list | join(\",\") }}"))
        (charset "utf8")
        (body (jinja "{{ etesync__mail_body }}")))
      (when "(etesync__http_psk_subpath | d() and etesync__mail_to | d() and \"etesync\" not in ansible_local)"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save EteSync local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/etesync.fact.j2")
        (dest "/etc/ansible/facts.d/etesync.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
