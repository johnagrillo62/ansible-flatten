(playbook "debops/ansible/roles/libvirt/tasks/manage_pools.yml"
  (tasks
    (task "Stop storage pools if requested"
      (community.libvirt.virt_pool 
        (name (jinja "{{ item.name }}"))
        (uri (jinja "{{ libvirt__connections[item.uri | d(libvirt__uri)] }}"))
        (state "inactive"))
      (loop (jinja "{{ q(\"flattened\", libvirt__pools) }}"))
      (become "False")
      (register "libvirt__register_stop")
      (when "((item.name | d()) and (item.state | d() in ['inactive', 'undefined', 'absent']))"))
    (task "Delete storage pools if requested"
      (community.libvirt.virt_pool 
        (name (jinja "{{ item.item.name }}"))
        (uri (jinja "{{ libvirt__connections[item.item.uri | d(libvirt__uri)] }}"))
        (command "delete")
        (mode (jinja "{{ item.item.mode | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", libvirt__register_stop.results) }}"))
      (become "False")
      (when "(item is changed and item.item.name | d() and item.item.delete | d(False) and item.item.state | d() in ['undefined'] and item.item.type in ['dir', 'nfs', 'logical'])"))
    (task "Undefine storage pools if requested"
      (community.libvirt.virt_pool 
        (name (jinja "{{ item.name }}"))
        (uri (jinja "{{ libvirt__connections[item.uri | d(libvirt__uri)] }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", libvirt__pools) }}"))
      (become "False")
      (when "((item.name | d()) and (item.state | d() in ['undefined', 'absent']))"))
    (task "Define storage pools"
      (community.libvirt.virt_pool 
        (name (jinja "{{ item.name }}"))
        (xml (jinja "{{ lookup(\"template\", \"lookup/pool/\" + item.type + \".xml.j2\") }}"))
        (uri (jinja "{{ libvirt__connections[item.uri | d(libvirt__uri)] }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", libvirt__pools) }}"))
      (become "False")
      (register "libvirt__register_define")
      (when "((item.name | d()) and (item.state | d('active') not in ['undefined', 'absent']))"))
    (task "Build new storage pools"
      (community.libvirt.virt_pool 
        (name (jinja "{{ item.item.name }}"))
        (uri (jinja "{{ libvirt__connections[item.item.uri | d(libvirt__uri)] }}"))
        (command "build")
        (mode (jinja "{{ item.item.mode | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", libvirt__register_define.results) }}"))
      (become "False")
      (when "(item is changed and item.item.name | d() and (item.item.state | d('active') not in ['undefined', 'absent']) and (item.item.build | d(True)) and (item.item.type in ['dir', 'nfs'] or (item.item.type == 'logical' and item.item.devices | d())))"))
    (task "Start storage pools if not started"
      (community.libvirt.virt_pool 
        (name (jinja "{{ item.name }}"))
        (state "active")
        (uri (jinja "{{ libvirt__connections[item.uri | d(libvirt__uri)] }}")))
      (loop (jinja "{{ q(\"flattened\", libvirt__pools) }}"))
      (become "False")
      (when "(item.name | d() and item.state | d('active') in ['active'])"))
    (task "Set autostart attribute on storage pools"
      (community.libvirt.virt_pool 
        (name (jinja "{{ item.name }}"))
        (autostart (jinja "{{ \"yes\" if (item.autostart | d(True)) else \"no\" }}"))
        (uri (jinja "{{ libvirt__connections[item.uri | d(libvirt__uri)] }}")))
      (loop (jinja "{{ q(\"flattened\", libvirt__pools) }}"))
      (become "False")
      (when "(item.name | d() and item.state | d('active') not in ['undefined', 'absent'])"))))
