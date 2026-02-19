(playbook "debops/ansible/roles/owncloud/tasks/system_package_management.yml"
  (tasks
    (task "Configure ownCloud APT repository"
      (ansible.builtin.template 
        (src "etc/apt/sources.list.d/debops_owncloud.list.j2")
        (dest "/etc/apt/sources.list.d/debops_owncloud.list")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "owncloud__register_apt_repository")
      (when "(owncloud__variant in [\"owncloud\"])"))
    (task "Update APT repository cache"
      (ansible.builtin.apt 
        (update_cache "True"))
      (register "owncloud__register_apt_cache")
      (until "owncloud__register_apt_cache is succeeded")
      (when "owncloud__register_apt_repository is changed"))
    (task "Ensure specified packages are in there desired state"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (owncloud__base_packages
                              + owncloud__packages
                              + owncloud__group_packages
                              + owncloud__host_packages
                              + owncloud__dependent_packages)) }}"))
        (state (jinja "{{ \"absent\"
               if (owncloud__deploy_state in [\"absent\"])
               else (\"latest\"
                     if (ansible_local | d() and ansible_local.owncloud | d() and
                         ((ansible_local.owncloud.release | d(owncloud__release) != owncloud__release) or
                          (ansible_local.owncloud.auto_security_updates_enabled | d() | bool)))
                     else \"present\") }}")))
      (register "owncloud__register_apt_install")
      (until "owncloud__register_apt_install is succeeded"))))
