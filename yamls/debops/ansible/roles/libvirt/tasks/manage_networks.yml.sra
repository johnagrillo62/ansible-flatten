(playbook "debops/ansible/roles/libvirt/tasks/manage_networks.yml"
  (tasks
    (task "Stop networks if requested"
      (community.libvirt.virt_net 
        (name (jinja "{{ item.name }}"))
        (uri (jinja "{{ libvirt__connections[item.uri | d(libvirt__uri)] }}"))
        (state "inactive"))
      (loop (jinja "{{ q(\"flattened\", libvirt__networks) }}"))
      (become "False")
      (when "(item.name | d() and (item.state | d() in ['inactive', 'undefined', 'absent']))"))
    (task "Undefine networks if requested"
      (community.libvirt.virt_net 
        (name (jinja "{{ item.name }}"))
        (uri (jinja "{{ libvirt__connections[item.uri | d(libvirt__uri)] }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", libvirt__networks) }}"))
      (become "False")
      (when "(item.name | d() and (item.state | d() in ['undefined', 'absent']))"))
    (task "Define networks"
      (community.libvirt.virt_net 
        (name (jinja "{{ item.name }}"))
        (xml (jinja "{{ lookup(\"template\", \"lookup/network/\" + item.type + \".xml.j2\") }}"))
        (uri (jinja "{{ libvirt__connections[item.uri | d(libvirt__uri)] }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", libvirt__networks) }}"))
      (become "False")
      (when "((item.name | d()) and (item.state | d(\"active\") not in ['undefined', 'absent']) and (item.interface_present is undefined or (item.interface_present in ansible_interfaces and not item.uri | d())))"))
    (task "Start networks if not started"
      (community.libvirt.virt_net 
        (name (jinja "{{ item.name }}"))
        (state "active")
        (uri (jinja "{{ libvirt__connections[item.uri | d(libvirt__uri)] }}")))
      (loop (jinja "{{ q(\"flattened\", libvirt__networks) }}"))
      (become "False")
      (when "((item.name | d()) and (item.state is undefined or item.state in ['active']) and (item.interface_present is undefined or (item.interface_present in ansible_interfaces and not item.uri | d())))"))
    (task "Set autostart attribute on networks"
      (community.libvirt.virt_net 
        (name (jinja "{{ item.name }}"))
        (autostart (jinja "{{ \"yes\" if (item.autostart | d(True)) else \"no\" }}"))
        (uri (jinja "{{ libvirt__connections[item.uri | d(libvirt__uri)] }}")))
      (loop (jinja "{{ q(\"flattened\", libvirt__networks) }}"))
      (become "False")
      (when "((item.name | d()) and (item.state is undefined or item.state not in ['undefined', 'absent']) and (item.interface_present is undefined or (item.interface_present in ansible_interfaces and not item.uri | d())))"))))
