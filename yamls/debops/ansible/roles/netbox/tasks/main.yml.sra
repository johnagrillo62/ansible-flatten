(playbook "debops/ansible/roles/netbox/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (netbox__base_packages
                              + netbox__packages)) }}"))
        (state "present"))
      (register "netbox__register_packages")
      (until "netbox__register_packages is succeeded"))
    (task "Create NetBox system group"
      (ansible.builtin.group 
        (name (jinja "{{ netbox__group }}"))
        (state "present")
        (system "True")))
    (task "Create NetBox system user"
      (ansible.builtin.user 
        (name (jinja "{{ netbox__user }}"))
        (group (jinja "{{ netbox__group }}"))
        (home (jinja "{{ netbox__home }}"))
        (comment (jinja "{{ netbox__gecos }}"))
        (shell (jinja "{{ netbox__shell }}"))
        (state "present")
        (system "True")
        (generate_ssh_key (jinja "{{ netbox__napalm_ssh_generate | bool }}"))
        (ssh_key_bits (jinja "{{ netbox__napalm_ssh_generate_bits }}"))))
    (task "Create additional directories used by NetBox"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ netbox__user }}"))
        (group (jinja "{{ netbox__group }}"))
        (mode "0755"))
      (with_items (list
          (jinja "{{ netbox__src }}")
          (jinja "{{ netbox__lib }}")
          (jinja "{{ netbox__data }}")
          (jinja "{{ netbox__config_media_root }}")
          (jinja "{{ netbox__config_reports_root }}")
          (jinja "{{ netbox__config_scripts_root }}"))))
    (task "Clone NetBox source code"
      (ansible.builtin.git 
        (repo (jinja "{{ netbox__git_repo }}"))
        (dest (jinja "{{ netbox__git_dest }}"))
        (version (jinja "{{ netbox__git_version }}"))
        (bare "True")
        (update "True")
        (verify_commit "True"))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (register "netbox__register_source")
      (until "netbox__register_source is succeeded"))
    (task "Check if NetBox is installed"
      (ansible.builtin.stat 
        (path (jinja "{{ netbox__git_checkout }}")))
      (register "netbox__register_installed"))
    (task "Check current virtualenv version"
      (ansible.builtin.stat 
        (path (jinja "{{ netbox__virtualenv + \"/bin/python\" }}")))
      (register "netbox__register_virtualenv_version"))
    (task "Remove old python2 based virtualenv"
      (ansible.builtin.file 
        (path (jinja "{{ netbox__virtualenv }}"))
        (state "absent"))
      (register "netbox__register_virtalenv_deleted")
      (when "(netbox__virtualenv_version == '3' and netbox__register_virtualenv_version.stat.lnk_target | d() == 'python2')"))
    (task "Create NetBox checkout directory"
      (ansible.builtin.file 
        (path (jinja "{{ netbox__git_checkout }}"))
        (state "directory")
        (owner (jinja "{{ netbox__user }}"))
        (group (jinja "{{ netbox__group }}"))
        (mode "0755")))
    (task "Prepare NetBox git worktree"
      (ansible.builtin.copy 
        (content "gitdir: " (jinja "{{ netbox__git_dest }}"))
        (dest (jinja "{{ netbox__git_checkout + \"/.git\" }}"))
        (owner (jinja "{{ netbox__user }}"))
        (group (jinja "{{ netbox__group }}"))
        (mode "0644")))
    (task "Get commit hash of target checkout"
      (ansible.builtin.command "git rev-parse " (jinja "{{ netbox__git_version }}"))
      (environment 
        (GIT_WORK_TREE (jinja "{{ netbox__git_checkout }}")))
      (args 
        (chdir (jinja "{{ netbox__git_dest }}")))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (register "netbox__register_target_branch")
      (changed_when "netbox__register_target_branch.stdout != netbox__register_source.before"))
    (task "Checkout NetBox"
      (ansible.builtin.command "git checkout -f " (jinja "{{ netbox__git_version }}"))
      (environment 
        (GIT_WORK_TREE (jinja "{{ netbox__git_checkout }}")))
      (args 
        (chdir (jinja "{{ netbox__git_dest }}")))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (register "netbox__register_checkout")
      (changed_when "netbox__register_checkout.changed | bool")
      (until "netbox__register_checkout is succeeded")
      (notify (list
          "Restart gunicorn for netbox"
          "Restart netbox internal appserver"
          "Restart netbox Request Queue Worker"))
      (when "(netbox__register_source.before is undefined or (netbox__register_source.before | d() and netbox__register_target_branch.stdout | d() and netbox__register_source.before != netbox__register_target_branch.stdout) or not netbox__register_installed.stat.exists | bool or netbox__register_virtalenv_deleted.changed | bool)"))
    (task "Create Python virtualenv for NetBox"
      (ansible.builtin.pip 
        (name (list
            "pip"
            "setuptools"))
        (virtualenv (jinja "{{ netbox__virtualenv }}"))
        (virtualenv_python (jinja "{{ \"python\" + netbox__virtualenv_version }}"))
        (state "forcereinstall"))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (register "netbox__register_virtualenv")
      (until "netbox__register_virtualenv is succeeded")
      (changed_when "(netbox__register_virtualenv is success and netbox__register_virtualenv.stdout is search('New python executable in'))"))
    (task "Clean up stale Python bytecode"
      (ansible.builtin.command "find . -name '*.pyc' -delete")
      (args 
        (chdir (jinja "{{ netbox__git_checkout + \"/netbox\" }}")))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (register "netbox__register_cleanup")
      (changed_when "netbox__register_cleanup.changed | bool")
      (when "netbox__register_checkout is changed"))
    (task "Install NetBox requirements in virtualenv"
      (ansible.builtin.pip 
        (virtualenv (jinja "{{ netbox__virtualenv }}"))
        (requirements (jinja "{{ netbox__git_checkout + \"/requirements.txt\" }}"))
        (extra_args "--upgrade"))
      (register "netbox__register_pip_install")
      (until "netbox__register_pip_install is succeeded")
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (notify (list
          "Restart gunicorn for netbox"
          "Restart netbox internal appserver"
          "Restart netbox Request Queue Worker"))
      (when "netbox__register_checkout is changed"))
    (task "Install additional Python modules in virtualenv"
      (ansible.builtin.pip 
        (name (jinja "{{ item.name | d(item) }}"))
        (version (jinja "{{ item.version | d(omit) }}"))
        (virtualenv (jinja "{{ netbox__virtualenv }}")))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (loop (jinja "{{ q(\"flattened\", netbox__virtualenv_pip_packages) }}"))
      (when "netbox__register_checkout is changed and item.state | d('present') not in ['absent', 'ignore']"))
    (task "Generate NetBox configuration"
      (ansible.builtin.template 
        (src "usr/local/lib/netbox/configuration.py.j2")
        (dest (jinja "{{ netbox__git_checkout + \"/netbox/netbox/configuration.py\" }}"))
        (owner (jinja "{{ netbox__user }}"))
        (group (jinja "{{ netbox__group }}"))
        (mode "0640"))
      (notify (list
          "Restart gunicorn for netbox"
          "Restart netbox internal appserver"
          "Restart netbox Request Queue Worker"))
      (register "netbox__register_configuration")
      (tags (list
          "role::netbox:config")))
    (task "Generate NetBox LDAP configuration"
      (ansible.builtin.template 
        (src "usr/local/lib/netbox/ldap_config.py.j2")
        (dest (jinja "{{ netbox__git_checkout + \"/netbox/netbox/ldap_config.py\" }}"))
        (owner (jinja "{{ netbox__user }}"))
        (group (jinja "{{ netbox__group }}"))
        (mode "0640"))
      (notify (list
          "Restart gunicorn for netbox"
          "Restart netbox internal appserver"
          "Restart netbox Request Queue Worker"))
      (when "netbox__ldap_enabled | bool")
      (tags (list
          "role::netbox:config"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Perform database installation or migration"
      (ansible.builtin.shell 
        (cmd "set -o nounset -o pipefail -o errexit
./manage.py migrate
./manage.py trace_paths --no-input || :
(cd .. && mkdocs build)
./manage.py collectstatic --no-input
./manage.py remove_stale_contenttypes --no-input
./manage.py reindex --lazy
./manage.py clearsessions
")
        (chdir (jinja "{{ netbox__git_checkout + \"/netbox\" }}"))
        (executable "bash"))
      (environment 
        (VIRTUAL_ENV (jinja "{{ netbox__virtualenv }}"))
        (PATH (jinja "{{ netbox__virtualenv_env_path }}")))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (when "(netbox__register_checkout is changed and netbox__primary | bool)")
      (register "netbox__register_migration")
      (changed_when "netbox__register_migration.changed | bool"))
    (task "Generate static content"
      (ansible.builtin.shell 
        (cmd "set -o nounset -o pipefail -o errexit
./manage.py collectstatic --no-input
")
        (chdir (jinja "{{ netbox__git_checkout + \"/netbox\" }}"))
        (executable "bash"))
      (environment 
        (VIRTUAL_ENV (jinja "{{ netbox__virtualenv }}"))
        (PATH (jinja "{{ netbox__virtualenv_env_path }}")))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (when "(netbox__register_checkout is changed and not netbox__primary | bool)")
      (register "netbox__register_collectstatic")
      (changed_when "not netbox__register_collectstatic.stdout is search('0 static files copied')"))
    (task "Create local session directory"
      (ansible.builtin.file 
        (path (jinja "{{ netbox__data + \"/sessions\" }}"))
        (owner (jinja "{{ netbox__user }}"))
        (group (jinja "{{ netbox__group }}"))
        (mode "0770")
        (access_time "preserve")
        (modification_time "preserve")
        (state "directory"))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (when "(not netbox__primary | bool)"))
    (task "Cleanup stale contenttypes and sessions"
      (ansible.builtin.shell 
        (cmd "set -o nounset -o pipefail -o errexit
./manage.py remove_stale_contenttypes --no-input
./manage.py clearsessions
")
        (chdir (jinja "{{ netbox__git_checkout + \"/netbox\" }}"))
        (executable "bash"))
      (environment 
        (VIRTUAL_ENV (jinja "{{ netbox__virtualenv }}"))
        (PATH (jinja "{{ netbox__virtualenv_env_path }}")))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (when "(netbox__register_checkout is changed and not netbox__primary | bool)")
      (changed_when "false"))
    (task "Create Django superuser account"
      (community.general.django_manage 
        (command "createsuperuser --noinput --username=" (jinja "{{ netbox__superuser_name }}") " --email=" (jinja "{{ netbox__superuser_email }}"))
        (app_path (jinja "{{ netbox__git_checkout + \"/netbox\" }}"))
        (virtualenv (jinja "{{ netbox__virtualenv }}")))
      (environment 
        (DJANGO_SUPERUSER_PASSWORD (jinja "{{ netbox__superuser_password }}")))
      (become "True")
      (become_user (jinja "{{ netbox__user }}"))
      (register "netbox__register_django_superuser")
      (failed_when "('error' in netbox__register_django_superuser.out.lower() and 'that username is already taken.' not in netbox__register_django_superuser.out.lower())")
      (when "(netbox__primary | bool and not netbox__register_installed.stat.exists | bool and not netbox__register_migration.stdout is search('No migrations to apply.'))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate systemd service unit"
      (ansible.builtin.template 
        (src "etc/systemd/system/netbox.service.j2")
        (dest "/etc/systemd/system/netbox.service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload systemd daemon (netbox)"
          "Restart gunicorn for netbox"
          "Restart netbox internal appserver"))
      (when "netbox__app_internal_appserver | bool"))
    (task "Generate NetBox RQ systemd service unit"
      (ansible.builtin.template 
        (src "etc/systemd/system/netbox-rq.service.j2")
        (dest "/etc/systemd/system/netbox-rq.service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload systemd daemon (netbox)"
          "Restart netbox Request Queue Worker"))
      (when "netbox__app_internal_appserver | bool"))
    (task "Generate systemd NetBox Housekeeping service unit"
      (ansible.builtin.template 
        (src "etc/systemd/system/netbox-housekeeping.service.j2")
        (dest "/etc/systemd/system/netbox-housekeeping.service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload systemd daemon (netbox)")))
    (task "Generate systemd NetBox Housekeeping timer unit"
      (ansible.builtin.template 
        (src "etc/systemd/system/netbox-housekeeping.timer.j2")
        (dest "/etc/systemd/system/netbox-housekeeping.timer")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload systemd daemon (netbox)")))
    (task "Enable systemd NetBox Housekeeping timer"
      (ansible.builtin.systemd 
        (daemon_reload "True")
        (name "netbox-housekeeping.timer")
        (enabled "True")
        (state "started"))
      (when "ansible_service_mgr == 'systemd' and not ansible_check_mode"))
    (task "Generate NetBox netbox-manage script"
      (ansible.builtin.template 
        (src "usr/local/bin/netbox-manage.j2")
        (dest (jinja "{{ netbox__bin + \"/netbox-manage\" }}"))
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save NetBox local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/netbox.fact.j2")
        (dest "/etc/ansible/facts.d/netbox.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (tags (list
          "meta::facts")))))
