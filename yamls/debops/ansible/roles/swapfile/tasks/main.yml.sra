(playbook "debops/ansible/roles/swapfile/tasks/main.yml"
  (tasks
    (task "Disable swap files when requested"
      (ansible.builtin.shell "test -f " (jinja "{{ item.path | d(item) }}") " && swapoff " (jinja "{{ item.path | d(item) }}") " || true")
      (changed_when "False")
      (with_items (jinja "{{ swapfile__files }}"))
      (when "(item.state | d(\"present\") == 'absent' and ((ansible_system_capabilities_enforced | d()) | bool and \"cap_sys_admin\" in ansible_system_capabilities) or not (ansible_system_capabilities_enforced | d(True)) | bool)"))
    (task "Create swap files"
      (ansible.builtin.command (jinja "{% if swapfile__use_dd | bool %}") "
dd if=/dev/zero of=" (jinja "{{ item.path | d(item) }}") " bs=1M count=" (jinja "{{ item.size | d(swapfile__size) }}") "
" (jinja "{% else %}") "
fallocate -l " (jinja "{{ ((item.size | d(swapfile__size)) | int * 1024 * 1024) }}") " " (jinja "{{ item.path | d(item) }}") "
" (jinja "{% endif %}") "
")
      (args 
        (creates (jinja "{{ item.path | d(item) }}")))
      (register "swapfile__register_allocation")
      (with_items (jinja "{{ swapfile__files }}"))
      (when "(item.state | d(\"present\") != 'absent')"))
    (task "Enforce permissions"
      (ansible.builtin.file 
        (path (jinja "{{ item.path | d(item) }}"))
        (state "file")
        (owner "root")
        (group "root")
        (mode "0600"))
      (with_items (jinja "{{ swapfile__files }}"))
      (when "(item.state | d(\"present\") != 'absent' and not ansible_check_mode)"))
    (task "Initialize swap files"
      (ansible.builtin.command "mkswap " (jinja "{{ item.item.path | d(item.item) }}"))
      (register "swapfile__register_init")
      (changed_when "swapfile__register_init.changed | bool")
      (with_items (jinja "{{ swapfile__register_allocation.results | d([]) }}"))
      (when "(item is changed and item.state | d(\"present\") != 'absent')"))
    (task "Enable swap files"
      (ansible.builtin.command "swapon -p " (jinja "{{ item.item.priority | d(swapfile__priority) }}") " " (jinja "{{ item.item.path | d(item.item) }}"))
      (with_items (jinja "{{ swapfile__register_allocation.results | d([]) }}"))
      (register "swapfile__register_swapon")
      (changed_when "swapfile__register_swapon.changed | bool")
      (when "( (item is changed and item.state | d(\"present\") != 'absent') and (( (ansible_system_capabilities_enforced | d()) | bool and \"cap_sys_admin\" in ansible_system_capabilities ) or not (ansible_system_capabilities_enforced | d(True)) | bool ) )"))
    (task "Disable swap files"
      (ansible.builtin.shell "test -f " (jinja "{{ item.path | d(item) }}") " && swapoff -v " (jinja "{{ item.path | d(item) }}") " || true")
      (with_items (jinja "{{ swapfile__files }}"))
      (register "swapfile__register_swapoff")
      (changed_when "swapfile__register_swapoff.stdout == ('swapoff ' + item.path | d(item))")
      (when "( (item.state | d(\"present\") == 'absent') and (( (ansible_system_capabilities_enforced | d()) | bool and \"cap_sys_admin\" in ansible_system_capabilities ) or not (ansible_system_capabilities_enforced | d(True)) | bool ) )"))
    (task "Manage swap files in /etc/fstab"
      (ansible.posix.mount 
        (src (jinja "{{ item.path | d(item) }}"))
        (name "none")
        (fstype "swap")
        (opts "sw,nofail,pri=" (jinja "{{ item.priority | d(swapfile__priority) }}"))
        (dump "0")
        (passno "0")
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (with_items (jinja "{{ swapfile__files }}")))
    (task "Remove swap files"
      (ansible.builtin.file 
        (path (jinja "{{ item.path | d(item) }}"))
        (state "absent"))
      (with_items (jinja "{{ swapfile__files }}"))
      (when "(item.state | d(\"present\") == 'absent')"))
    (task "Remove legacy kernel parameters file"
      (ansible.builtin.file 
        (path (jinja "{{ swapfile__sysctl_file | d(\"/etc/sysctl.d/30-debops.swapfile.conf\") }}"))
        (state "absent")))))
