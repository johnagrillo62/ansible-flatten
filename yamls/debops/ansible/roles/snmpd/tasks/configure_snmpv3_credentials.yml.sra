(playbook "debops/ansible/roles/snmpd/tasks/configure_snmpv3_credentials.yml"
  (tasks
    (task "Stop snmpd before admin account initialization"
      (ansible.builtin.service 
        (name "snmpd")
        (state "stopped")))
    (task "Prepare admin account"
      (ansible.builtin.lineinfile 
        (dest "/var/lib/snmp/snmpd.conf")
        (regexp "^createUser " (jinja "{{ snmpd_fact_account_admin_username }}"))
        (line "createUser " (jinja "{{ snmpd_fact_account_admin_username }}") " SHA \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" AES")
        (state "present")
        (mode "0600"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Start snmpd to initialize admin account"
      (ansible.builtin.service 
        (name "snmpd")
        (state "started")))
    (task "Create read-only agent account"
      (ansible.builtin.command "snmpusm -u " (jinja "{{ snmpd_fact_account_admin_username }}") " -l authPriv -a SHA -x AES -A \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" -X \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" localhost create " (jinja "{{ snmpd_fact_account_agent_username }}") " " (jinja "{{ snmpd_fact_account_admin_username }}"))
      (changed_when "False")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Change agent account password"
      (ansible.builtin.command "snmpusm -u " (jinja "{{ snmpd_fact_account_admin_username }}") " -l authPriv -a SHA -x AES -A \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" -X \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" localhost passwd \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" \"" (jinja "{{ snmpd_fact_account_agent_password }}") "\" " (jinja "{{ snmpd_fact_account_agent_username }}"))
      (changed_when "False")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Create read-only local account"
      (ansible.builtin.command "snmpusm -u " (jinja "{{ snmpd_fact_account_admin_username }}") " -l authPriv -a SHA -x AES -A \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" -X \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" localhost create " (jinja "{{ snmpd_account_local_username }}") " " (jinja "{{ snmpd_fact_account_admin_username }}"))
      (changed_when "False")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Change local account password"
      (ansible.builtin.command "snmpusm -u " (jinja "{{ snmpd_fact_account_admin_username }}") " -l authPriv -a SHA -x AES -A \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" -X \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" localhost passwd \"" (jinja "{{ snmpd_fact_account_admin_password }}") "\" \"" (jinja "{{ snmpd_account_local_password }}") "\" " (jinja "{{ snmpd_account_local_username }}"))
      (changed_when "False")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove admin account from snmpd.conf"
      (ansible.builtin.lineinfile 
        (dest "/etc/snmp/snmpd.conf")
        (regexp "^rwuser\\s+" (jinja "{{ snmpd_fact_account_admin_username }}") "\\s+priv")
        (state "absent"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
