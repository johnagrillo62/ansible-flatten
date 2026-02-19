(playbook "debops/ansible/roles/rspamd/tasks/main_dkim.yml"
  (tasks
    (task "Make sure the DKIM directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (mode "0750")
        (owner "_rspamd")
        (group "_rspamd"))
      (loop (list
          "/var/lib/rspamd"
          "/var/lib/rspamd/dkim"
          "/var/lib/rspamd/dkim-archive"
          (jinja "{{ rspamd__dkim_log_dir }}")))
      (when "rspamd__dkim_enabled | d(False)"))
    (task "Create DKIM key generation/update configuration"
      (ansible.builtin.template 
        (src "etc/rspamd/dkim-json.j2")
        (dest (jinja "{{ item.dest }}"))
        (mode "0644"))
      (loop (list
          
          (config (jinja "{{ rspamd__dkim_keygen_combined_configuration }}"))
          (dest "/etc/rspamd/dkim-keygen.json")
          
          (config (jinja "{{ rspamd__dkim_update_combined_configuration }}"))
          (dest "/etc/rspamd/dkim-update.json")))
      (loop_control 
        (label (jinja "{{ item.dest }}")))
      (when "rspamd__dkim_enabled | d(False)"))
    (task "Install DKIM scripts"
      (ansible.builtin.copy 
        (src (jinja "{{ lookup('debops.debops.file_src', item.src) }}"))
        (dest (jinja "{{ item.dest }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"root\") }}"))
        (mode (jinja "{{ item.mode | d(\"0755\") }}")))
      (with_items (list
          
          (src "usr/local/sbin/rspamd-dkim-keygen")
          (dest "/usr/local/sbin/rspamd-dkim-keygen")
          
          (src "usr/local/sbin/rspamd-dkim-update")
          (dest "/usr/local/sbin/rspamd-dkim-update")))
      (when "rspamd__dkim_enabled | d(False)"))
    (task "See if a nsupdate keyfile/keytab exists on the Ansible controller"
      (ansible.builtin.set_fact 
        (rspamd__dkim_local_keyfile (jinja "{{ lookup(\"debops.debops.file_src\", \"etc/rspamd/dkim_dns_key\", errors=\"ignore\") }}")))
      (when "rspamd__dkim_enabled | d(False) and rspamd__dkim_update_method in [\"nsupdate_tsig\", \"nsupdate_gsstsig\"]
"))
    (task "Copy nsupdate keyfile/keytab from controller to host"
      (ansible.builtin.copy 
        (src (jinja "{{ rspamd__dkim_local_keyfile }}"))
        (dest "/etc/rspamd/dkim_dns_key")
        (owner "root")
        (group "_rspamd")
        (mode "0640"))
      (when "rspamd__dkim_enabled | d(False) and rspamd__dkim_update_method in [\"nsupdate_tsig\", \"nsupdate_gsstsig\"] and rspamd__dkim_local_keyfile is defined and rspamd__dkim_local_keyfile | length > 0
"))
    (task "Create DKIM keys"
      (ansible.builtin.command "/usr/local/sbin/rspamd-dkim-keygen")
      (become "True")
      (become_user "_rspamd")
      (register "rspamd__dkim_tmp_output")
      (changed_when "rspamd__dkim_tmp_output.rc == 2")
      (failed_when "rspamd__dkim_tmp_output.rc not in [0, 2]")
      (when "rspamd__dkim_enabled | d(False)")
      (notify (list
          "Restart rspamd")))
    (task "Configure DKIM key generation/rollover cron job"
      (ansible.builtin.cron 
        (name "Generate/rollover DKIM keys for rspamd")
        (special_time "monthly")
        (cron_file "rspamd-dkim-keygen")
        (user "_rspamd")
        (state (jinja "{{ \"present\" if rspamd__dkim_enabled | d(False) else \"absent\" }}"))
        (job "/usr/local/sbin/rspamd-dkim-keygen")))
    (task "Purge DKIM configuration/scripts"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          "/etc/rspamd/dkim-keygen.json"
          "/etc/rspamd/dkim-update.json"
          "/usr/local/sbin/rspamd-dkim-keygen"
          "/usr/local/sbin/rspamd-dkim-update"))
      (when "not rspamd__dkim_enabled | d(False)"))))
