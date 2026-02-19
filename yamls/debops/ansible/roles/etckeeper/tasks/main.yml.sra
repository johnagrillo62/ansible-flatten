(playbook "debops/ansible/roles/etckeeper/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save etckeeper local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/etckeeper.fact.j2")
        (dest "/etc/ansible/facts.d/etckeeper.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Divert original configuration under /etc"
      (debops.debops.dpkg_divert 
        (path "/etc/etckeeper/etckeeper.conf"))
      (when "etckeeper__enabled | bool and ansible_pkg_mgr == 'apt'"))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (etckeeper__base_packages
                              + etckeeper__packages)) }}"))
        (state "present"))
      (register "etckeeper__register_packages")
      (until "etckeeper__register_packages is succeeded")
      (when "etckeeper__enabled | bool"))
    (task "Create etckeeper configuration"
      (ansible.builtin.template 
        (src "etc/etckeeper/etckeeper.conf.j2")
        (dest "/etc/etckeeper/etckeeper.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "etckeeper__register_config")
      (notify (list
          "Commit changes in etckeeper"))
      (when "etckeeper__enabled | bool"))
    (task "Initialize VCS in /etc"
      (ansible.builtin.command "etckeeper init")
      (args 
        (creates "/etc/.etckeeper"))
      (register "etckeeper__register_init")
      (notify (list
          "Commit changes in etckeeper"))
      (when "etckeeper__enabled | bool"))
    (task "Manage entries in /etc/.gitignore"
      (ansible.builtin.blockinfile 
        (path "/etc/.gitignore")
        (block (jinja "{% for item in etckeeper__combined_gitignore | debops.debops.parse_kv_items %}") "
" (jinja "{% if (item.name | d() and item.state | d('present') != 'absent') %}") "
" (jinja "{% if item.comment | d() %}") "

" (jinja "{{ item.comment | regex_replace('\\n$', '') | comment(prefix='', postfix='') }}") (jinja "{% endif %}") "
" (jinja "{{ (item.ignore | d(item.name)) | regex_replace('\\n$', '') }}") "
" (jinja "{% if item.comment | d() %}") "

" (jinja "{% endif %}") "
" (jinja "{% endif %}") "
" (jinja "{% endfor %}") "
")
        (insertbefore "BOF")
        (marker (jinja "{{ etckeeper__block_marker }}"))
        (create "True")
        (owner "root")
        (group "root")
        (mode "0600"))
      (register "etckeeper__register_gitignore")
      (notify (list
          "Commit changes in etckeeper"))
      (when "etckeeper__enabled | bool and etckeeper__vcs == 'git'"))
    (task "Install /etc/.gitattributes configuration"
      (ansible.builtin.template 
        (src "etc/gitattributes.j2")
        (dest "/etc/.gitattributes")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "etckeeper__register_gitattributes")
      (when "etckeeper__enabled | bool and etckeeper__vcs == 'git'"))
    (task "Set repository permissions"
      (ansible.builtin.file 
        (path "/etc/.git")
        (state "directory")
        (owner "root")
        (group (jinja "{{ etckeeper__repository_group | d(\"root\") }}"))
        (mode (jinja "{{ etckeeper__repository_permissions | d(\"0700\") }}")))
      (when "etckeeper__enabled | bool and etckeeper__vcs == 'git'"))
    (task "Set user, email for the git repository"
      (community.general.ini_file 
        (dest "/etc/.git/config")
        (section "user")
        (option (jinja "{{ item.key }}"))
        (value (jinja "{{ item.value }}"))
        (mode "0644"))
      (with_dict 
        (name (jinja "{{ etckeeper__vcs_user }}"))
        (email (jinja "{{ etckeeper__vcs_email }}")))
      (when "etckeeper__enabled | bool and etckeeper__vcs == 'git' and etckeeper__vcs_user | d() and etckeeper__vcs_email | d()"))
    (task "Remove e-mail notification hook script"
      (ansible.builtin.file 
        (path "/etc/etckeeper/commit.d/99email")
        (state "absent"))
      (when "etckeeper__enabled | bool and etckeeper__email_on_commit_state == 'absent'"))
    (task "Install e-mail notification hook script"
      (ansible.builtin.template 
        (src "etc/etckeeper/commit.d/99email.j2")
        (dest "/etc/etckeeper/commit.d/99email")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Commit changes in etckeeper"))
      (when "etckeeper__enabled | bool and etckeeper__email_on_commit_state == 'present'"))
    (task "Configure other VCS software"
      (ansible.builtin.include_tasks "other_vcs.yml")
      (when "etckeeper__enabled | bool and etckeeper__vcs != 'git' and etckeeper__vcs_user | d() and etckeeper__vcs_email | d()"))
    (task "Unstage and remove ignored files from Git index"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && etckeeper vcs ls-files -i -c --exclude-standard -z | xargs -0 --no-run-if-empty etckeeper vcs rm --cached --")
      (args 
        (executable "bash"))
      (register "etckeeper__register_git_rm_cached_ignored_files")
      (when (list
          "etckeeper__enabled | bool"
          "etckeeper__vcs == \"git\""
          "etckeeper__register_gitignore is changed"))
      (changed_when "etckeeper__register_git_rm_cached_ignored_files.stdout"))
    (task "Commit changes in configuration"
      (ansible.builtin.command "etckeeper commit '" (jinja "{{ etckeeper__commit_message_update
                                if etckeeper__installed | bool
                                else etckeeper__commit_message_init }}") "'")
      (register "etckeeper__register_commit")
      (changed_when "etckeeper__register_commit.changed | bool")
      (when "(etckeeper__enabled | bool and (etckeeper__register_init is changed or etckeeper__register_config is changed or etckeeper__register_gitignore is changed or etckeeper__register_gitattributes is changed))"))))
