(playbook "debops/ansible/roles/lxc/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "DebOps pre_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup('debops.debops.task_src', 'lxc/pre_main.yml') }}")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (lxc__base_packages
                              + lxc__packages)) }}"))
        (state "present"))
      (register "lxc__register_packages")
      (until "lxc__register_packages is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save LXC local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/lxc.fact.j2")
        (dest "/etc/ansible/facts.d/lxc.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Create required directories"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (loop (list
          "/etc/systemd/system/lxc.service.d"
          "/etc/systemd/system/lxc@.service.d"
          "/usr/local/lib/lxc")))
    (task "Install custom LXC hooks"
      (ansible.builtin.copy 
        (src "usr/local/lib/lxc/")
        (dest "/usr/local/lib/lxc/")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Install custom LXC helper scripts"
      (ansible.builtin.copy 
        (src "usr/local/bin/")
        (dest "/usr/local/bin/")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Remove systemd service overrides"
      (ansible.builtin.file 
        (path (jinja "{{ item.name | d(item) }}"))
        (state "absent"))
      (loop (list
          
          (name "/etc/systemd/system/lxc@.service.d/poweroff.conf")
          (state (jinja "{{ \"present\"
                 if (lxc__version is version(\"2.1.0\", \"<\"))
                 else \"absent\" }}"))))
      (register "lxc__register_systemd_overrides_remove")
      (when "item.state | d('present') == 'absent'"))
    (task "Install systemd service overrides"
      (ansible.builtin.template 
        (src (jinja "{{ item.name | d(item) }}") ".j2")
        (dest "/" (jinja "{{ item.name | d(item) }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (list
          "etc/systemd/system/lxc.service.d/exec-override.conf"
          "etc/systemd/system/lxc@.service.d/partof.conf"
          
          (name "etc/systemd/system/lxc@.service.d/poweroff.conf")
          (state (jinja "{{ \"present\"
                 if (lxc__version is version(\"2.1.0\", \"<\"))
                 else \"absent\" }}"))))
      (register "lxc__register_systemd_overrides_create")
      (when "item.state | d('present') != 'absent'"))
    (task "Disable internal network when requested"
      (ansible.builtin.systemd 
        (name "lxc-net.service")
        (state "stopped"))
      (when "(lxc__net_deploy_state == 'absent' and ansible_service_mgr == 'systemd')")
      (tags (list
          "role::lxc:net")))
    (task "Remove lxc-net support files"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          (jinja "{{ lxc__net_dnsmasq_conf }}")
          "/etc/systemd/system/lxc-net.service.d"
          "/etc/ferm/hooks/post.d/restart-lxc-net"))
      (register "lxc__register_net_remove")
      (when "lxc__net_deploy_state == 'absent'")
      (tags (list
          "role::lxc:net")))
    (task "Generate lxc-net configuration file"
      (ansible.builtin.template 
        (src "etc/default/lxc-net.j2")
        (dest "/etc/default/lxc-net")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "lxc__register_net_config")
      (tags (list
          "role::lxc:net")))
    (task "Generate lxc-net dnsmasq config file"
      (ansible.builtin.template 
        (src "etc/lxc/lxc-net-dnsmasq.conf.j2")
        (dest (jinja "{{ lxc__net_dnsmasq_conf }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "lxc__register_net_dnsmasq")
      (when "lxc__net_deploy_state == 'present'")
      (tags (list
          "role::lxc:net"
          "role::lxc:dnsmasq")))
    (task "Install lxc-net ferm hook"
      (ansible.builtin.template 
        (src "etc/ferm/hooks/post.d/restart-lxc-net.j2")
        (dest "/etc/ferm/hooks/post.d/restart-lxc-net")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(lxc__net_deploy_state == 'present' and ansible_local | d() and ansible_local.ferm | d() and (ansible_local.ferm.enabled | d()) | bool)")
      (tags (list
          "role::lxc:net")))
    (task "Create lxc-net service override directory"
      (ansible.builtin.file 
        (path "/etc/systemd/system/lxc-net.service.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "lxc__net_deploy_state == 'present'")
      (tags (list
          "role::lxc:net")))
    (task "Hook lxc-net-resolvconf script to the lxc-net service"
      (ansible.builtin.template 
        (src "etc/systemd/system/lxc-net.service.d/resolvconf.conf.j2")
        (dest "/etc/systemd/system/lxc-net.service.d/resolvconf.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "lxc__register_net_systemd")
      (when "lxc__net_deploy_state == 'present' and lxc__net_resolver == \"resolvconf\"")
      (tags (list
          "role::lxc:net")))
    (task "Hook lxc-net-systemd-resolved script to the lxc-net service"
      (ansible.builtin.template 
        (src "etc/systemd/system/lxc-net.service.d/systemd-resolved.conf.j2")
        (dest "/etc/systemd/system/lxc-net.service.d/systemd-resolved.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "lxc__register_net_systemd")
      (when "lxc__net_deploy_state == 'present' and lxc__net_resolver == \"systemd-resolved\"")
      (tags (list
          "role::lxc:net")))
    (task "Reconfigure systemd services when modified"
      (ansible.builtin.systemd 
        (name (jinja "{{ \"lxc-net.service\" if (lxc__net_deploy_state == \"present\") else omit }}"))
        (state (jinja "{{ \"restarted\" if (lxc__net_deploy_state == \"present\") else omit }}"))
        (daemon_reload "True"))
      (when "(ansible_service_mgr == 'systemd' and (lxc__register_net_remove | d({}) is changed or lxc__register_net_config | d({}) is changed or lxc__register_net_dnsmasq | d({}) is changed or lxc__register_net_systemd | d({}) is changed or lxc__register_systemd_overrides_create | d({}) is changed or lxc__register_systemd_overrides_remove | d({}) is changed))")
      (tags (list
          "role::lxc:net"
          "role::lxc:dnsmasq")))
    (task "Remove default SSH keys for root in containers if none are defined"
      (ansible.builtin.file 
        (path "/etc/lxc/root_authorized_keys")
        (state "absent"))
      (when "not lxc__default_container_ssh_root_sshkeys | d()"))
    (task "Define default SSH keys for root account in containers"
      (ansible.posix.authorized_key 
        (key (jinja "{{ lxc__default_container_ssh_root_sshkeys | join('\\n') }}"))
        (path "/etc/lxc/root_authorized_keys")
        (manage_dir "False")
        (user "root")
        (state "present")
        (exclusive "True"))
      (when "lxc__default_container_ssh_root_sshkeys | d()"))
    (task "Remove LXC configuration if requested"
      (ansible.builtin.file 
        (path "/etc/lxc/" (jinja "{{ item.filename | d(item.name + \".conf\") }}"))
        (state "absent"))
      (with_items (jinja "{{ lxc__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') == 'absent'"))
    (task "Generate LXC configuration"
      (ansible.builtin.template 
        (src "etc/lxc/template.conf.j2")
        (dest "/etc/lxc/" (jinja "{{ item.filename | d(item.name + \".conf\") }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ lxc__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Remove common LXC container configuration if requested"
      (ansible.builtin.file 
        (path "/usr/share/lxc/config/common.conf.d/" (jinja "{{ item.filename | d(item.name + \".conf\") }}"))
        (state "absent"))
      (with_items (jinja "{{ lxc__common_combined_conf | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') == 'absent'"))
    (task "Generate common LXC container configuration"
      (ansible.builtin.template 
        (src "etc/lxc/template.conf.j2")
        (dest "/usr/share/lxc/config/common.conf.d/" (jinja "{{ item.filename | d(item.name + \".conf\") }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ lxc__common_combined_conf | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Stop LXC containers if requested"
      (ansible.builtin.systemd 
        (name "lxc@" (jinja "{{ item.name | d(item) }}") ".service")
        (state "stopped")
        (enabled (jinja "{{ True if item.state | d(\"started\") == \"stopped\" else False }}")))
      (loop (jinja "{{ lxc__containers }}"))
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.name | d(item)) in ansible_local.lxc.containers | d() and item.state | d(\"started\") in [\"stopped\", \"absent\"]")
      (tags (list
          "role::lxc:containers")))
    (task "Destroy LXC containers if requested"
      (community.general.lxc_container 
        (name (jinja "{{ item.name | d(item) }}"))
        (state "absent"))
      (loop (jinja "{{ lxc__containers }}"))
      (tags (list
          "role::lxc:containers"))
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.name | d(item)) in ansible_local.lxc.containers | d() and item.state | d(\"started\") == \"absent\""))
    (task "Remove systemd LXC instance configuration if requested"
      (ansible.builtin.file 
        (path "/etc/systemd/system/lxc@" (jinja "{{ item.name }}") ".service.d")
        (state "absent"))
      (loop (jinja "{{ lxc__containers }}"))
      (register "lxc__register_systemd_remove_override")
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.name | d(item)) in ansible_local.lxc.containers | d() and item.state | d(\"started\") == \"absent\" and item.systemd_override | d()")
      (tags (list
          "role::lxc:containers")))
    (task "Create systemd override directories for LXC instances"
      (ansible.builtin.file 
        (path "/etc/systemd/system/lxc@" (jinja "{{ item.name }}") ".service.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (loop (jinja "{{ lxc__containers }}"))
      (when "item.state | d(\"started\") != \"absent\" and item.systemd_override | d()")
      (tags (list
          "role::lxc:containers")))
    (task "Generate systemd LXC instance override files"
      (ansible.builtin.template 
        (src "etc/systemd/system/lxc@.service.d/ansible-override.conf.j2")
        (dest "/etc/systemd/system/lxc@" (jinja "{{ item.name }}") ".service.d/ansible-override.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ lxc__containers }}"))
      (register "lxc__register_systemd_create_override")
      (when "item.state | d(\"started\") != \"absent\" and item.systemd_override | d()")
      (tags (list
          "role::lxc:containers")))
    (task "Reload systemd configuration when needed"
      (ansible.builtin.systemd 
        (daemon_reload "True"))
      (when "ansible_service_mgr == 'systemd' and lxc__register_systemd_create_override is changed or lxc__register_systemd_remove_override is changed")
      (tags (list
          "role::lxc:containers")))
    (task "Manage LXC containers"
      (community.general.lxc_container 
        (name (jinja "{{ item.name | d(item) }}"))
        (archive (jinja "{{ item.archive | d(omit) }}"))
        (archive_compression (jinja "{{ item.archive_compression | d(omit) }}"))
        (archive_path (jinja "{{ item.archive_path | d(omit) }}"))
        (backing_store (jinja "{{ item.backing_store | d(lxc__default_container_backing_store) }}"))
        (clone_name (jinja "{{ item.clone_name | d(omit) }}"))
        (clone_snapshot (jinja "{{ item.clone_snapshot | d(omit) }}"))
        (config (jinja "{{ item.config | d(lxc__default_container_config) }}"))
        (container_command (jinja "{{ item.container_command | d(omit) }}"))
        (container_config (jinja "{{ item.container_config | d(omit) }}"))
        (container_log (jinja "{{ item.container_log | d(omit) }}"))
        (container_log_level (jinja "{{ item.container_log_level | d(omit) }}"))
        (directory (jinja "{{ item.directory | d(omit) }}"))
        (fs_size (jinja "{{ item.fs_size | d(omit) }}"))
        (fs_type (jinja "{{ item.fs_type | d(omit) }}"))
        (lv_name (jinja "{{ item.lv_name | d(omit) }}"))
        (lxc_path (jinja "{{ item.lxc_path | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"started\"
                                            if (ansible_local | d() and ansible_local.lxc | d() and
                                                (item.name | d(item))
                                                in ansible_local.lxc.containers | d())
                                            else \"stopped\") }}"))
        (template (jinja "{{ item.template | d(lxc__default_container_template) }}"))
        (template_options (jinja "{{ item.template_options | d((lxc__var_template_options | join(\" \"))
                                                       if ((item.template
                                                            | d(lxc__default_container_template)) == \"download\")
                                                       else omit) }}"))
        (thinpool (jinja "{{ item.thinpool | d(omit) }}"))
        (vg_name (jinja "{{ item.vg_name | d(omit) }}"))
        (zfs_root (jinja "{{ item.zfs_root | d(omit) }}")))
      (environment 
        (DOWNLOAD_KEYSERVER (jinja "{{ ansible_local.keyring.keyserver | d(\"hkp://keyserver.ubuntu.com\") }}")))
      (vars 
        (lxc__var_template_options (list
            "--dist " (jinja "{{ (item.distribution | d(lxc__default_container_distribution)) | lower }}")
            "--release " (jinja "{{ (item.release | d(lxc__default_container_release)) | lower }}")
            "--arch " (jinja "{{ (item.architecture | d(lxc__default_container_architecture)) | lower }}"))))
      (loop (jinja "{{ lxc__containers }}"))
      (tags (list
          "role::lxc:containers"))
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.name | d(item)) not in ansible_local.lxc.containers | d() and item.state | d(\"started\") != \"absent\""))
    (task "Configure static MAC addresses for new LXC containers"
      (ansible.builtin.command "lxc-hwaddr-static " (jinja "{{ item.name | d(item) }}"))
      (loop (jinja "{{ lxc__containers }}"))
      (register "lxc__register_hwaddr_static")
      (changed_when "lxc__register_hwaddr_static.changed | bool")
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.name | d(item)) not in ansible_local.lxc.containers | d() and item.state | d(\"started\") == \"started\"")
      (tags (list
          "role::lxc:containers")))
    (task "Include fstab parameter in LXC container configuration for lxc<4.0"
      (ansible.builtin.lineinfile 
        (path "/var/lib/lxc/" (jinja "{{ item.name | d(item) }}") "/config")
        (regexp "^lxc\\.mount\\s+=\\s+")
        (line "lxc.mount = /var/lib/lxc/" (jinja "{{ item.name | d(item) }}") "/fstab")
        (insertafter "^lxc\\.rootfs\\.backend\\s+=\\s+")
        (state "present")
        (mode "0644"))
      (loop (jinja "{{ lxc__containers }}"))
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.name | d(item)) not in ansible_local.lxc.containers | d() and item.state | d(\"started\") == \"started\" and item.fstab | d() and lxc__version is version(\"4.0\", operator=\"lt\", strict=True)")
      (tags (list
          "role::lxc:containers")))
    (task "Include fstab parameter in LXC container configuration for lxc>=4.0"
      (ansible.builtin.lineinfile 
        (path "/var/lib/lxc/" (jinja "{{ item.name | d(item) }}") "/config")
        (regexp "^lxc\\.mount\\.fstab\\s+=\\s+")
        (line "lxc.mount.fstab = /var/lib/lxc/" (jinja "{{ item.name | d(item) }}") "/fstab")
        (insertafter "^lxc\\.rootfs\\.backend\\s+=\\s+")
        (state "present")
        (mode "0644"))
      (loop (jinja "{{ lxc__containers }}"))
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.name | d(item)) not in ansible_local.lxc.containers | d() and item.state | d(\"started\") == \"started\" and item.fstab | d() and lxc__version is version(\"4.0\", operator=\">=\", strict=True)")
      (tags (list
          "role::lxc:containers")))
    (task "Create custom fstab files for LXC containers"
      (ansible.builtin.copy 
        (content "# Filesystem table for the '" (jinja "{{ item.name | d(item) }}") "' LXC container
" (jinja "{{ item.fstab | regex_replace('\\n$', '') }}") "
")
        (dest "/var/lib/lxc/" (jinja "{{ item.name | d(item) }}") "/fstab")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ lxc__containers }}"))
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.name | d(item)) not in ansible_local.lxc.containers | d() and item.state | d(\"started\") == \"started\" and item.fstab | d()")
      (tags (list
          "role::lxc:containers")))
    (task "Start LXC containers after creation"
      (ansible.builtin.systemd 
        (name "lxc@" (jinja "{{ item.name | d(item) }}") ".service")
        (state (jinja "{{ \"restarted\" if (item.state is defined) else \"started\" }}"))
        (enabled (jinja "{{ True if item.state | d(\"started\") == \"started\" else False }}")))
      (loop (jinja "{{ lxc__containers }}"))
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.name | d(item)) not in ansible_local.lxc.containers | d() and item.state | d(\"started\") == \"started\"")
      (tags (list
          "role::lxc:containers")))
    (task "Restart LXC containers when modified"
      (ansible.builtin.systemd 
        (name "lxc@" (jinja "{{ item.0.name | d(item.0) }}") ".service")
        (state "restarted"))
      (loop (jinja "{{ lxc__containers | zip(lxc__register_systemd_create_override.results | d([])) | list }}"))
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.0.name | d(item.0)) in ansible_local.lxc.containers | d() and item.0.state | d('started') == 'started' and item.1 is changed")
      (tags (list
          "role::lxc:containers")))
    (task "Prepare SSH access in LXC containers"
      (ansible.builtin.shell "if lxc-attach -n \"" (jinja "{{ item.name | d(item) }}") "\" -- grep -q '127.0.1.1' /etc/hosts ; then
    lxc-attach -n \"" (jinja "{{ item.name | d(item) }}") "\" -- sed -i \"/127\\.0\\.1\\.1/d\" /etc/hosts > /dev/null
fi
until lxc-prepare-ssh " (jinja "{{ item.name | d(item) }}") " ; do
   ((c++)) && ((c==4)) && break
   printf \"Waiting for network connection inside container to settle...\\n\" ; sleep 5
done
")
      (loop (jinja "{{ lxc__containers }}"))
      (register "lxc__register_prepare_ssh")
      (changed_when "lxc__register_prepare_ssh.changed | bool")
      (when "ansible_local | d() and ansible_local.lxc | d() and (item.name | d(item)) not in ansible_local.lxc.containers | d() and (item.ssh | d(lxc__default_container_ssh)) | bool and item.state | d(\"started\") == \"started\"")
      (tags (list
          "role::lxc:containers")))
    (task "DebOps post_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup('debops.debops.task_src', 'lxc/post_main.yml') }}")))))
