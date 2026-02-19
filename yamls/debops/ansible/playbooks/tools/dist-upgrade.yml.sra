(playbook "debops/ansible/playbooks/tools/dist-upgrade.yml"
    (play
    (name "Upgrade all the things!")
    (hosts "all:!localhost")
    (become "True")
    (vars
      (dist_upgrade_version_map 
        (stretch "buster")
        (buster "bullseye")
        (bullseye "bookworm")
        (bookworm "trixie")
        (trixie "forky")
        (trusty "utopic"))
      (dist_upgrade_current_release (jinja "{{ ansible_distribution_release }}"))
      (dist_upgrade_new_release (jinja "{{ dist_upgrade_version_map[dist_upgrade_current_release] }}"))
      (dist_upgrade_lockfile "/tmp/dist-upgrade-in-progress")
      (dist_upgrade_mail_host "localhost")
      (dist_upgrade_mail_port "25")
      (dist_upgrade_mail_secure "try")
      (dist_upgrade_mail_to (list
          (jinja "{{ \"root@\" + ansible_domain }}")))
      (dist_upgrade_mail_subject (jinja "{{ ansible_fqdn }}") " has been upgraded from " (jinja "{{ ansible_distribution }}") " " (jinja "{{ dist_upgrade_current_release | capitalize }}") " to " (jinja "{{ ansible_distribution }}") " " (jinja "{{ dist_upgrade_new_release | capitalize }}"))
      (dist_upgrade_mail_body "Ansible performed an unattended 'apt-get dist-upgrade' on host

    " (jinja "{{ ansible_fqdn }}") "

Upgrade has been orchestrated by " (jinja "{{ansible_env.SUDO_USER | d(\"root\")}}") ".
You should reboot " (jinja "{{ ansible_fqdn }}") " as soon
as possible to complete the upgrade process and boot
with new kernel.

Log from the upgrade is included below:

============================
    apt-get dist-upgrade
============================

" (jinja "{% for line in dist_upgrade_register_upgrade.stdout_lines %}") "
" (jinja "{% if not line | regex_search('^\\(Reading\\s+database.*%') and
      not line | regex_search('^\\(Reading\\s+database\\s+\\.\\.\\.\\s+$') %}") "
" (jinja "{{ line }}") "
" (jinja "{% endif %}") "
" (jinja "{% endfor %}") "

==========================
    apt-get autoremove
==========================

" (jinja "{% for line in dist_upgrade_register_autoremove.stdout_lines %}") "
" (jinja "{% if not line | regex_search('^\\(Reading\\s+database.*%') and
      not line | regex_search('^\\(Reading\\s+database\\s+\\.\\.\\.\\s+$') %}") "
" (jinja "{{ line }}") "
" (jinja "{% endif %}") "
" (jinja "{% endfor %}") "

=========================
    apt-get autoclean
=========================

" (jinja "{% for line in dist_upgrade_register_autoclean.stdout_lines %}") "
" (jinja "{% if not line | regex_search('^\\(Reading\\s+database.*%') and
      not line | regex_search('^\\(Reading\\s+database\\s+\\.\\.\\.\\s+$') %}") "
" (jinja "{{ line }}") "
" (jinja "{% endif %}") "
" (jinja "{% endfor %}") "
"))
    (tasks
      (task "Check if lockfile exists"
        (ansible.builtin.stat 
          (path (jinja "{{ dist_upgrade_lockfile }}")))
        (register "dist_upgrade_register_lockfile"))
      (task "Find all apt sources.list files"
        (ansible.builtin.find 
          (paths "/etc/apt/")
          (patterns "*.list")
          (recurse "True"))
        (register "dist_upgrade_register_apt_sources"))
      (task "Change current release in APT sources"
        (ansible.builtin.replace 
          (dest (jinja "{{ item.path }}"))
          (regexp (jinja "{{ dist_upgrade_current_release }}"))
          (replace (jinja "{{ dist_upgrade_new_release }}")))
        (register "dist_upgrade_register_replace")
        (with_items (list
            (jinja "{{ dist_upgrade_register_apt_sources.files }}")))
        (when "dist_upgrade_current_release in dist_upgrade_version_map.keys() and dist_upgrade_new_release is defined and dist_upgrade_new_release"))
      (task "Fix APT sources (buster/updates becomes bullseye-security)"
        (ansible.builtin.replace 
          (dest (jinja "{{ item.path }}"))
          (regexp "\\s" (jinja "{{ dist_upgrade_new_release }}") "/updates\\s")
          (replace " " (jinja "{{ dist_upgrade_new_release }}") "-security "))
        (with_items (list
            (jinja "{{ dist_upgrade_register_apt_sources.files }}")))
        (when "dist_upgrade_new_release == 'bullseye'"))
      (task "Remove all APT preferences for backported packages"
        (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && grep -lrIZ 'Pin: release .*=" (jinja "{{ dist_upgrade_current_release }}") "-backports' /etc/apt/preferences.d | xargs -0 rm -f -- || true")
        (args 
          (executable "bash"))
        (register "dist_upgrade_register_remove")
        (changed_when "dist_upgrade_register_remove.changed | bool")
        (when "dist_upgrade_register_replace is defined and dist_upgrade_register_replace is changed"))
      (task "Create a lockfile"
        (ansible.builtin.file 
          (path (jinja "{{ dist_upgrade_lockfile }}"))
          (state "touch")
          (mode "0644"))
        (when "dist_upgrade_register_replace is defined and dist_upgrade_register_replace is changed"))
      (task "Perform apt-get dist-upgrade (this might take a while)"
        (ansible.builtin.apt 
          (update_cache "True")
          (upgrade "dist"))
        (register "dist_upgrade_register_upgrade")
        (when "((dist_upgrade_register_replace is defined and dist_upgrade_register_replace is changed) or (dist_upgrade_register_lockfile is defined and dist_upgrade_register_lockfile.stat.exists))"))
      (task "Check what init system is active"
        (ansible.builtin.stat 
          (path "/sbin/init"))
        (register "dist_upgrade_register_init"))
      (task "Install dbus package (required by systemd)"
        (ansible.builtin.apt 
          (name "dbus")
          (state "present")
          (install_recommends "False"))
        (when "dist_upgrade_register_init.stat.lnk_source is defined and dist_upgrade_register_init.stat.lnk_source == '/lib/systemd/systemd'"))
      (task "Automatically remove packages that are no longer needed"
        (ansible.builtin.apt 
          (autoremove "True"))
        (register "dist_upgrade_register_autoremove")
        (when "dist_upgrade_register_upgrade is defined and dist_upgrade_register_upgrade is changed"))
      (task "Clean APT package cache"
        (ansible.builtin.apt 
          (autoclean "True"))
        (register "dist_upgrade_register_autoclean")
        (when "dist_upgrade_register_upgrade is defined and dist_upgrade_register_upgrade is changed"))
      (task "Check if /etc/services.d exists"
        (ansible.builtin.stat 
          (path "/etc/services.d"))
        (register "dist_upgrade_register_etc_services")
        (when "dist_upgrade_register_upgrade is defined and dist_upgrade_register_upgrade is changed"))
      (task "Assemble /etc/services"
        (ansible.builtin.assemble 
          (src "/etc/services.d")
          (dest "/etc/services")
          (owner "root")
          (group "root")
          (mode "0644")
          (backup "False"))
        (when "dist_upgrade_register_etc_services is not skipped and dist_upgrade_register_etc_services is defined and dist_upgrade_register_etc_services.stat.exists"))
      (task "Remove the lockfile"
        (ansible.builtin.file 
          (path (jinja "{{ dist_upgrade_lockfile }}"))
          (state "absent")))
      (task "Send mail with information about the upgrade"
        (community.general.mail 
          (host (jinja "{{ dist_upgrade_mail_host }}"))
          (port (jinja "{{ dist_upgrade_mail_port }}"))
          (secure (jinja "{{ dist_upgrade_mail_secure }}"))
          (from (jinja "{{ \"root@\" + ansible_fqdn }}"))
          (to (jinja "{{ dist_upgrade_mail_to | join(\",\") }}"))
          (subject (jinja "{{ dist_upgrade_mail_subject }}"))
          (charset "utf8")
          (body (jinja "{{ dist_upgrade_mail_body }}")))
        (when "dist_upgrade_register_upgrade is defined and dist_upgrade_register_upgrade is changed")))))
