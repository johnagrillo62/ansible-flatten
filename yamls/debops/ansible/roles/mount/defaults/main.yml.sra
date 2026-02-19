(playbook "debops/ansible/roles/mount/defaults/main.yml"
  (mount__enabled (jinja "{{ True
                    if (((ansible_system_capabilities_enforced | d()) | bool and
                         \"cap_sys_admin\" in ansible_system_capabilities) or
                        not (ansible_system_capabilities_enforced | d(True)) | bool)
                    else False }}"))
  (mount__base_packages (jinja "{{ [\"acl\"]
                          if (((mount__directories
                                + mount__group_directories
                                + mount__host_directories)
                               | flatten) | selectattr(\"acl\", \"defined\") | list
                               | subelements(\"acl\"))
                          else [] }}"))
  (mount__packages (list))
  (mount__devices (list))
  (mount__group_devices (list))
  (mount__host_devices (list))
  (mount__directories (list))
  (mount__group_directories (list))
  (mount__host_directories (list))
  (mount__files (list))
  (mount__group_files (list))
  (mount__host_files (list))
  (mount__binds (list))
  (mount__group_binds (list))
  (mount__host_binds (list)))
