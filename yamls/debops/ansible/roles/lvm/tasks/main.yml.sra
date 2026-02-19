(playbook "debops/ansible/roles/lvm/tasks/main.yml"
  (tasks
    (task "Install LVM support"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", lvm__packages) }}"))
        (state "present"))
      (register "lvm__register_packages")
      (until "lvm__register_packages is succeeded"))
    (task "Divert original lvm.conf"
      (debops.debops.dpkg_divert 
        (path "/etc/lvm/lvm.conf")))
    (task "Check LVM version"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && dpkg-query -W -f='${Version}\\n' 'lvm2' | grep -v '^$' | cut -d- -f1")
      (environment 
        (LC_MESSAGES "C"))
      (args 
        (executable "bash"))
      (register "lvm__register_version")
      (changed_when "False")
      (check_mode "False"))
    (task "Lookup base LVM configuration"
      (ansible.builtin.include_vars (jinja "{{ item }}"))
      (with_first_found (list
          (jinja "{{ \"lvm_config_\" + lvm__config_lookup + \".yml\" }}")
          (jinja "{{ \"lvm_config_\" + lvm__register_version.stdout + \".yml\" }}")
          (jinja "{{ \"lvm_config_\" + ansible_distribution | lower + \"_\" + ansible_distribution_release + \".yml\" }}")
          (jinja "{{ \"lvm_config_\" + ansible_distribution | lower + \".yml\" }}")
          "lvm_config_default.yml")))
    (task "Configure LVM"
      (ansible.builtin.template 
        (src "etc/lvm/lvm.conf.j2")
        (dest "/etc/lvm/lvm.conf")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Enable/disable lvm2-lvmetad socket"
      (ansible.builtin.systemd 
        (name "lvm2-lvmetad.socket")
        (state (jinja "{{ \"started\" if lvm__global_use_lvmetad else \"stopped\" }}"))
        (enabled (jinja "{{ lvm__global_use_lvmetad }}")))
      (when "(ansible_distribution_release in ['stretch', 'trusty', 'xenial', 'bionic'])"))
    (task "Manage LVM"
      (ansible.builtin.include_tasks "manage_lvm.yml")
      (when "(((ansible_system_capabilities_enforced | d()) | bool and \"cap_sys_admin\" in ansible_system_capabilities) or not (ansible_system_capabilities_enforced | d(True)) | bool)"))))
