(playbook "debops/ansible/roles/etckeeper/defaults/main.yml"
  (etckeeper__enabled "True")
  (etckeeper__installed (jinja "{{ ansible_local.etckeeper.installed | d(False) }}"))
  (etckeeper__base_packages (list
      (jinja "{{ \"mercurial\" if (etckeeper__vcs == \"hg\") else etckeeper__vcs }}")
      "etckeeper"))
  (etckeeper__packages (list))
  (etckeeper__highlevel_package_manager (jinja "{{ ansible_local.etckeeper.highlevel_package_manager | d(ansible_pkg_mgr) }}"))
  (etckeeper__lowlevel_package_manager (jinja "{{ ansible_local.etckeeper.lowlevel_package_manager | d(etckeeper__high_low_pkg_map[etckeeper__highlevel_package_manager]) }}"))
  (etckeeper__high_low_pkg_map 
    (apt "dpkg")
    (yum "rpm")
    (dnf "rpm")
    (zypper "rpm")
    (pacman "pacman"))
  (etckeeper__commit_message_init "Initial commit by \"debops.etckeeper\" Ansible role")
  (etckeeper__commit_message_update "Committed by \"debops.etckeeper\" Ansible role")
  (etckeeper__commit_message_fact "Committed by Ansible local facts")
  (etckeeper__block_marker "# {mark} section managed by debops.etckeeper Ansible role")
  (etckeeper__default_gitignore (list
      
      (name "tor-keys")
      (comment "There is no benefit in tracking Tor keys and it is a potential security
vulnerability.
")
      (ignore "tor/keys/")
      
      (name "ssh-host-keys")
      (comment "No need to track the SSH host keys")
      (ignore "ssh/ssh_host_*_key")
      
      (name "mandos-seckey")
      (comment "There is no benefit in tracking Mandos keys and it is a potential security
vulnerability in case the /etc/ repository is pushed to an external remote.
")
      (ignore "keys/mandos/seckey.txt")
      
      (name "borgmatic")
      (comment "The borgmatic configuration directory can contain sensitive credentials
allowing access to backups of the system and potentially other systems as
well. debops.borgbackup only stores credentials in
`/etc/borgmatic/${config_name}_passphrase.txt` so we only exclude the
passphrase files here.
")
      (ignore "borgmatic/*passphrase*
borgmatic.d/*passphrase*")
      
      (name "xorg-conf-backup")
      (ignore "X11/xorg.conf.backup")
      
      (name "apparmor-libvirt")
      (comment "Files are generated and managed by libvirt and it is believed that there
is very little benefit in tracking these files.
")
      (ignore "apparmor.d/libvirt/*.files")
      
      (name "zfs-zpool-cache")
      (ignore "zfs/zpool.cache")
      
      (name "gitlab-omnibus-secrets")
      (comment "Ignore GitLab Omnibus secrets")
      (ignore "gitlab/gitlab-secrets.json")
      
      (name "gitlab-runner-config")
      (comment "Do not commit GitLab runner private configuration")
      (ignore "gitlab-runner/config.toml")
      
      (name "docker-key")
      (comment "Do not commit Docker private configuration")
      (ignore "docker/key.json")))
  (etckeeper__gitignore (list))
  (etckeeper__group_gitignore (list))
  (etckeeper__host_gitignore (list))
  (etckeeper__combined_gitignore (jinja "{{ etckeeper__default_gitignore
                                   + etckeeper__gitignore
                                   + etckeeper__group_gitignore
                                   + etckeeper__host_gitignore }}"))
  (etckeeper__vcs (jinja "{{ ansible_local.etckeeper.vcs | d(\"git\") }}"))
  (etckeeper__vcs_user "The /etc Keeper")
  (etckeeper__vcs_email "root@" (jinja "{{ ansible_fqdn }}"))
  (etckeeper__git_commit_options (jinja "{{ ansible_local.etckeeper.git_commit_options | d(\"\") }}"))
  (etckeeper__hg_commit_options (jinja "{{ ansible_local.etckeeper.hg_commit_options | d(\"\") }}"))
  (etckeeper__bzr_commit_options (jinja "{{ ansible_local.etckeeper.bzr_commit_options | d(\"\") }}"))
  (etckeeper__darcs_commit_options (jinja "{{ ansible_local.etckeeper.darcs_commit_options | d(\"-a\") }}"))
  (etckeeper__avoid_daily_autocommits (jinja "{{ True
                                        if (ansible_local | d() and ansible_local.etckeeper | d() and
                                            (ansible_local.etckeeper.avoid_daily_autocommits | d() == \"1\"))
                                        else False }}"))
  (etckeeper__avoid_special_file_warning (jinja "{{ True
                                           if (ansible_local | d() and ansible_local.etckeeper | d() and
                                               (ansible_local.etckeeper.avoid_special_file_warning | d() == \"1\"))
                                           else False }}"))
  (etckeeper__avoid_commit_before_install (jinja "{{ True
                                            if (ansible_local | d() and ansible_local.etckeeper | d() and
                                                (ansible_local.etckeeper.avoid_commit_before_install | d() == \"1\"))
                                            else False }}"))
  (etckeeper__push_remote (jinja "{{ ansible_local.etckeeper.push_remote | d(\"\") }}"))
  (etckeeper__email_on_commit_state "absent")
  (etckeeper__email_on_commit_email (jinja "{{ etckeeper__vcs_email }}"))
  (etckeeper__gitattributes "")
  (etckeeper__apt_preferences__dependent_list (list
      
      (packages (list
          "etckeeper"))
      (backports (list
          "buster"))
      (reason "Support for Python 3")
      (by_role "debops.etckeeper"))))
