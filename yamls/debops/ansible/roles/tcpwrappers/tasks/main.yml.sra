(playbook "debops/ansible/roles/tcpwrappers/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (tcpwrappers__base_packages
                              + tcpwrappers__packages)) }}"))
        (state "present"))
      (register "tcpwrappers__register_packages")
      (until "tcpwrappers__register_packages is succeeded")
      (when "tcpwrappers__enabled | bool"))
    (task "Make sure /etc/hosts.allow.d directory exists"
      (ansible.builtin.file 
        (path "/etc/hosts.allow.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Create /etc/hosts.allow.d/00_ansible"
      (ansible.builtin.template 
        (src "etc/hosts.allow.d/00_ansible.j2")
        (dest "/etc/hosts.allow.d/00_ansible")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Add/remove diversion of /etc/hosts.allow"
      (debops.debops.dpkg_divert 
        (path "/etc/hosts.allow")
        (divert (jinja "{{ tcpwrappers__divert_hosts_allow }}"))
        (state (jinja "{{ \"present\" if tcpwrappers__enabled | bool else \"absent\" }}"))
        (delete "True"))
      (when "not ansible_check_mode | bool"))
    (task "Allow access from Ansible Controller to sshd"
      (ansible.builtin.template 
        (src "etc/hosts.allow.d/ansible_controller.j2")
        (dest "/etc/hosts.allow.d/10_ansible_controller")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Remove hosts.allow entries if requested"
      (ansible.builtin.file 
        (path "/etc/hosts.allow.d/" (jinja "{{ item.weight | default(\"50\") }}") "_" (jinja "{{ item.filename
            | d((item.daemon if item.daemon is string else item.daemon[0]) + \"_allow\") }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", tcpwrappers__allow
                           + tcpwrappers__group_allow
                           + tcpwrappers__host_allow
                           + tcpwrappers__dependent_allow
                           + tcpwrappers__localhost_allow
                           + tcpwrappers_allow | d([])
                           + tcpwrappers_group_allow | d([])
                           + tcpwrappers_host_allow | d([])
                           + tcpwrappers_dependent_allow | d([])) }}"))
      (when "((item.daemon | d() or item.daemons | d()) and item.state | d() and item.state == 'absent')"))
    (task "Generate hosts.allow entries"
      (ansible.builtin.template 
        (src "etc/hosts.allow.d/allow.j2")
        (dest "/etc/hosts.allow.d/" (jinja "{{ item.weight | default(\"50\") }}") "_" (jinja "{{ item.filename
            | d((item.daemon if item.daemon is string else item.daemon[0]) + \"_allow\") }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", tcpwrappers__allow
                           + tcpwrappers__group_allow
                           + tcpwrappers__host_allow
                           + tcpwrappers__dependent_allow
                           + tcpwrappers__localhost_allow
                           + tcpwrappers_allow | d([])
                           + tcpwrappers_group_allow | d([])
                           + tcpwrappers_host_allow | d([])
                           + tcpwrappers_dependent_allow | d([])) }}"))
      (when "((item.daemon | d() or item.daemons | d()) and (item.state is undefined or item.state != 'absent'))"))
    (task "Assemble hosts.allow.d"
      (ansible.builtin.assemble 
        (src "/etc/hosts.allow.d")
        (dest "/etc/hosts.allow")
        (backup "False")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "tcpwrappers__enabled | bool"))
    (task "Make sure that Ansible local fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save tcpwrappers local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/tcpwrappers.fact.j2")
        (dest "/etc/ansible/facts.d/tcpwrappers.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags (list
          "meta::facts")))
    (task "Configure access in /etc/hosts.deny"
      (ansible.builtin.lineinfile 
        (dest "/etc/hosts.deny")
        (regexp "^ALL: ALL")
        (line "ALL: ALL")
        (create "True")
        (owner "root")
        (group "root")
        (mode "0644")
        (state (jinja "{{ \"present\"
               if (tcpwrappers__enabled | bool and
                   tcpwrappers__deny_all | bool)
               else \"absent\" }}"))))))
