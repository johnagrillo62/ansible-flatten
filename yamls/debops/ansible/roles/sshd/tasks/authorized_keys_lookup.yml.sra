(playbook "debops/ansible/roles/sshd/tasks/authorized_keys_lookup.yml"
  (tasks
    (task "Create OpenSSH LDAP bind password file"
      (ansible.builtin.template 
        (src "etc/ssh/ldap_authorized_keys_bindpw.j2")
        (dest "/etc/ssh/ldap_authorized_keys_bindpw")
        (owner (jinja "{{ sshd__authorized_keys_lookup_user }}"))
        (group "root")
        (mode "0600"))
      (when "\"ldap\" in sshd__authorized_keys_lookup_type | d([])")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove OpenSSH LDAP bind password file"
      (ansible.builtin.file 
        (path "/etc/ssh/ldap_authorized_keys_bindpw")
        (state "absent"))
      (when "\"ldap\" not in sshd__authorized_keys_lookup_type | d([])"))
    (task "Create /etc/ssh/authorized_keys_lookup.d directory"
      (ansible.builtin.file 
        (path "/etc/ssh/authorized_keys_lookup.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Generate authorized keys lookup scripts"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/ssh/authorized_keys_lookup.d/\" + item + \".j2\") }}"))
        (dest "/etc/ssh/authorized_keys_lookup.d/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (with_items (jinja "{{ sshd__authorized_keys_lookup_type }}"))
      (when "sshd__authorized_keys_lookup_type | d()"))
    (task "Generate authorized keys lookup hook"
      (ansible.builtin.template 
        (src "etc/ssh/authorized_keys_lookup.j2")
        (dest "/etc/ssh/authorized_keys_lookup")
        (owner "root")
        (group "root")
        (mode "0755")))))
