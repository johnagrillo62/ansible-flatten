(playbook "debops/ansible/roles/iscsi/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "DebOps pre_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup('debops.debops.task_src', 'iscsi/pre_main.yml') }}")))
    (task "Install required iSCSI packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", iscsi__packages) }}"))
        (state "present"))
      (register "iscsi__register_packages")
      (until "iscsi__register_packages is succeeded"))
    (task "Configure iSCSI Initiator IQN"
      (ansible.builtin.lineinfile 
        (dest "/etc/iscsi/initiatorname.iscsi")
        (regexp "^InitiatorName=iqn")
        (line "InitiatorName=" (jinja "{{ iscsi__initiator_name }}"))
        (state "present")
        (mode "0600"))
      (register "iscsi__register_initiatorname"))
    (task "Configure iSCSI discovery authentication"
      (ansible.builtin.lineinfile 
        (dest "/etc/iscsi/iscsid.conf")
        (regexp (jinja "{{ (item.key | replace(\".\", \"\\.\")) + \"\\s=\\s\" }}"))
        (line (jinja "{{ item.key + \" = \" + item.value }}"))
        (state "present")
        (mode "0600"))
      (with_dict (jinja "{{ iscsi__default_options }}"))
      (when "item | d(False) and item.value")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Restart iSCSI service if initial configuration changed"
      (ansible.builtin.service 
        (name "open-iscsi")
        (state "restarted"))
      (when "iscsi__enabled | d() and iscsi__register_initiatorname | d() and iscsi__register_initiatorname is changed"))
    (task "Generate iSCSI interface configuration"
      (ansible.builtin.shell "iscsiadm -m iface -I " (jinja "{{ item }}") " -o new ; iscsiadm -m iface -I " (jinja "{{ item }}") " --op=update -n iface.net_ifacename -v " (jinja "{{ item }}"))
      (args 
        (creates "/etc/iscsi/ifaces/" (jinja "{{ item }}")))
      (with_items (jinja "{{ iscsi__interfaces }}"))
      (when "(iscsi__interfaces | d(False) and item in ansible_interfaces)"))
    (task "Discover iSCSI targets on portals"
      (community.general.open_iscsi 
        (discover "True")
        (portal (jinja "{{ item }}")))
      (with_items (jinja "{{ iscsi__portals }}"))
      (register "iscsi__register_discover_targets")
      (when "iscsi__portals | d(False) and item not in ansible_local.iscsi.discovered_portals | d([])"))
    (task "Log in to specified iSCSI targets"
      (community.general.open_iscsi 
        (target (jinja "{{ item.target }}"))
        (login (jinja "{{ False if (not item.login | d(True)) else True }}"))
        (node_auth (jinja "{{ \"CHAP\" if (item.auth | d(False)) else omit }}"))
        (node_user (jinja "{{ item.auth_username if (item.auth | d(False)) else omit }}"))
        (node_pass (jinja "{{ item.auth_password if (item.auth | d(False)) else omit }}"))
        (auto_node_startup (jinja "{{ False if (not item.auto | d(True)) else True }}")))
      (with_items (jinja "{{ iscsi__targets }}"))
      (register "iscsi__register_targets")
      (when "iscsi__targets | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Make sure that local facts directory exists"
      (ansible.builtin.file 
        (dest "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save iSCSI facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/iscsi.fact.j2")
        (dest "/etc/ansible/facts.d/iscsi.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags (list
          "meta::facts")))
    (task "Manage LVM"
      (ansible.builtin.include_tasks "manage_lvm.yml")
      (when "(((ansible_system_capabilities_enforced | d()) | bool and \"cap_sys_admin\" in ansible_system_capabilities) or not (ansible_system_capabilities_enforced | d(True)) | bool)"))
    (task "DebOps post_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup('debops.debops.task_src', 'iscsi/post_main.yml') }}")))))
