(playbook "debops/ansible/roles/persistent_paths/defaults/main.yml"
  (persistent_paths__paths )
  (persistent_paths__group_paths )
  (persistent_paths__host_paths )
  (persistent_paths__dependent_paths )
  (persistent_paths__combined_paths (jinja "{{
  persistent_paths__dependent_paths
  | combine(persistent_paths__paths)
  | combine(persistent_paths__group_paths)
  | combine(persistent_paths__host_paths) }}"))
  (persistent_paths__qubes_os_enabled (jinja "{{ True
                                        if (ansible_virtualization_role == \"guest\" and
                                            \"qubes\" in (ansible_kernel | lower))
                                        else False }}"))
  (persistent_paths__qubes_os_config_dir "/rw/config/qubes-bind-dirs.d")
  (persistent_paths__qubes_os_storage_path "/rw/bind-dirs")
  (persistent_paths__qubes_os_handler "/usr/lib/qubes/bind-dirs.sh")
  (persistent_paths__qubes_os_default_persistent_paths (list
      "/home"
      "/usr/local"
      "/var/spool/cron"
      "/rw")))
