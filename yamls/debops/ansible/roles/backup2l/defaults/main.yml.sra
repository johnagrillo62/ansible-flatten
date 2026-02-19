(playbook "debops/ansible/roles/backup2l/defaults/main.yml"
  (backup2l__base_packages (list
      "backup2l"))
  (backup2l__packages (list))
  (backup2l__backup_dev "")
  (backup2l__backup_dir (jinja "{{ (ansible_local.fhs.backup | d(\"/var/backups\"))
                          + \"/backup2l\" }}"))
  (backup2l__pre_hook_dir (jinja "{{ (ansible_local.fhs.etc | d(\"/usr/local/etc\"))
                            + \"/backup/pre-hook.d\" }}"))
  (backup2l__post_hook_dir (jinja "{{ (ansible_local.fhs.etc | d(\"/usr/local/etc\"))
                             + \"/backup/post-hook.d\" }}"))
  (backup2l__include_file (jinja "{{ (ansible_local.fhs.etc | d(\"/usr/local/etc\"))
                            + \"/backup/include\" }}"))
  (backup2l__default_include (list
      "/etc"
      "/home"
      "/opt"
      "/root"
      "/srv"
      "/usr/local"
      "/var/backups"
      "/var/local"
      "/var/mail"
      "/var/spool/cron"))
  (backup2l__include (list))
  (backup2l__group_include (list))
  (backup2l__host_include (list))
  (backup2l__srclist_from_file "True")
  (backup2l__srclist (jinja "{{ (backup2l__default_include
                        + backup2l__include
                        + backup2l__group_include
                        + backup2l__host_include)
                       | join(\" \") }}"))
  (backup2l__default_exclude (list
      "-wholename \"" (jinja "{{ backup2l__backup_dir }}") "\" -prune"
      "-path \"*.ansible/tmp*\""
      "-path \"*.cache*\""
      "-path \"*.nobackup*\""
      "-name \"*.o\""
      "-name \"*.pyc\""))
  (backup2l__exclude (list))
  (backup2l__group_exclude (list))
  (backup2l__host_exclude (list))
  (backup2l__skipcond (jinja "{{ (backup2l__default_exclude
                         + backup2l__exclude
                         + backup2l__group_exclude
                         + backup2l__host_exclude)
                        | join(\" -o \") }}"))
  (backup2l__volname "all")
  (backup2l__max_level "3")
  (backup2l__max_per_level "8")
  (backup2l__max_full "2")
  (backup2l__generations "1")
  (backup2l__create_check_file "True")
  (backup2l__autorun "False")
  (backup2l__size_units "")
  (backup2l__timezone "UTC")
  (backup2l__create_driver "DRIVER_TAR_GZ_RSYNCABLE"))
