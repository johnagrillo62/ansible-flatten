(playbook "debops/ansible/roles/dhcp_probe/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (dhcp_probe__base_packages + dhcp_probe__packages)) }}"))
        (state "present"))
      (register "dhcp_probe__register_packages")
      (until "dhcp_probe__register_packages is succeeded"))
    (task "Ensure that sysvinit dhcp-probe service is stopped on install"
      (ansible.builtin.systemd 
        (name "dhcp-probe.service")
        (state "stopped"))
      (when "((ansible_local is undefined or ansible_local.dhcp_probe is undefined) and ansible_service_mgr == 'systemd')"))
    (task "Install custom systemd unit files"
      (ansible.builtin.template 
        (src "etc/systemd/system/" (jinja "{{ item }}") ".j2")
        (dest "/etc/systemd/system/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (list
          "dhcp-probe@.service"
          "dhcp-probe.service"))
      (notify (list
          "Reload service manager"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Reload systemd configuration when needed"
      (ansible.builtin.meta "flush_handlers"))
    (task "Disable DHCP Probe instances if requested"
      (ansible.builtin.systemd 
        (name "dhcp-probe@" (jinja "{{ item.name }}") ".service")
        (state "stopped")
        (enabled "False"))
      (loop (jinja "{{ dhcp_probe__combined_interfaces | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') == 'absent'"))
    (task "Enable DHCP Probe instances if requested"
      (ansible.builtin.systemd 
        (name "dhcp-probe@" (jinja "{{ item.name }}") ".service")
        (enabled "True"))
      (loop (jinja "{{ dhcp_probe__combined_interfaces | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') != 'absent'")
      (notify (list
          "Restart dhcp-probe")))
    (task "Ensure that required directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (loop (list
          (jinja "{{ dhcp_probe__cache }}")
          (jinja "{{ dhcp_probe__lib }}"))))
    (task "Install custom notification scripts"
      (ansible.builtin.template 
        (src "usr/local/lib/dhcp-probe/" (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ dhcp_probe__lib + \"/\" + item }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (loop (list
          "dhcp_probe_notify2"
          "mail-throttled")))
    (task "Generate dhcp_probe.cf configuration file"
      (ansible.builtin.template 
        (src "etc/dhcp_probe.cf.j2")
        (dest "/etc/dhcp_probe.cf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart dhcp-probe")))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Setup DHCP Probe local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/dhcp_probe.fact.j2")
        (dest "/etc/ansible/facts.d/dhcp_probe.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
