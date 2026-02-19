(playbook "debops/ansible/roles/rsnapshot/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (rsnapshot__base_packages
                              + rsnapshot__packages)) }}"))
        (state "present"))
      (register "rsnapshot__register_packages")
      (until "rsnapshot__register_packages is succeeded"))
    (task "Install custom backup scripts"
      (ansible.builtin.copy 
        (src "usr/local/sbin/")
        (dest (jinja "{{ (ansible_local.fhs.sbin | d(\"/usr/local/sbin\")) + \"/\" }}"))
        (mode "0755")))
    (task "Create required directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (mode (jinja "{{ item.mode }}"))
        (state "directory"))
      (loop (list
          
          (path (jinja "{{ rsnapshot__config_dir }}"))
          (mode "0755")
          
          (path (jinja "{{ rsnapshot__snapshot_root }}"))
          (mode "0700"))))
    (task "Configure rsnapshot-scheduler"
      (ansible.builtin.template 
        (src "etc/rsnapshot-scheduler.conf.j2")
        (dest "/etc/rsnapshot-scheduler.conf")
        (mode "0644")))
    (task "Configure rsnapshot backup scripts in cron"
      (ansible.builtin.template 
        (src "etc/cron/rsnapshot-wrapper.j2")
        (dest "/etc/cron." (jinja "{{ item }}") "/rsnapshot-wrapper")
        (mode "0755"))
      (loop (list
          "hourly"
          "daily"
          "weekly"
          "monthly")))
    (task "Ensure that rsnapshot SSH identities are present"
      (ansible.builtin.user 
        (name "root")
        (generate_ssh_key "True")
        (ssh_key_file ".ssh/" (jinja "{{ item.name }}"))
        (ssh_key_type (jinja "{{ item.type | d(rsnapshot__ssh_key_type) }}"))
        (ssh_key_bits (jinja "{{ item.bits | d(rsnapshot__ssh_key_bits) }}"))
        (ssh_key_comment (jinja "{{ item.comment | d(rsnapshot__ssh_key_comment) }}")))
      (loop (jinja "{{ q(\"flattened\", (rsnapshot__ssh_default_identities + rsnapshot__ssh_identities)) | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Refresh host facts"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore']"))
    (task "Make sure /root/.ssh/known_hosts file exists"
      (ansible.builtin.command "touch /root/.ssh/known_hosts")
      (args 
        (creates "/root/.ssh/known_hosts")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save rsnapshot local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/rsnapshot.fact.j2")
        (dest "/etc/ansible/facts.d/rsnapshot.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Gather facts from configured hosts"
      (ansible.builtin.setup 
        (gather_subset "!all")
        (fact_path "/dev/null"))
      (delegate_facts "True")
      (delegate_to (jinja "{{ item.name }}"))
      (loop (jinja "{{ rsnapshot__combined_hosts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and not item.fqdn | d() and hostvars[item.name] | d() and hostvars[item.name]['ansible_fqdn'] is not defined and (not rsnapshot__limit | d() or (item.name in rsnapshot__limit)))"))
    (task "Install required packages on hosts"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", rsnapshot__host_packages) }}"))
        (state "present"))
      (register "rsnapshot__register_host_packages")
      (until "rsnapshot__register_host_packages is succeeded")
      (delegate_to (jinja "{{ item.name }}"))
      (loop (jinja "{{ rsnapshot__combined_hosts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\"),
                \"packages\": q(\"flattened\", rsnapshot__host_packages)} }}")))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and (item.rsync | d(True)) | bool and hostvars[item.name] | d() and (not rsnapshot__limit | d() or (item.name in rsnapshot__limit)))"))
    (task "Install restricted rsync script used for backups"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit
if [ -r \"${rrsync_source}.gz\" ] ; then
    gzip -d -c \"${rrsync_source}.gz\" > \"${rrsync_binary}\"
elif [ -r \"${rrsync_source}\" ] ; then
    cp \"${rrsync_source}\" \"${rrsync_binary}\"
fi
chmod 0755 \"${rrsync_binary}\"
")
      (environment 
        (rrsync_source (jinja "{{ item.rrsync_source | d(rsnapshot__rrsync_source) }}"))
        (rrsync_binary (jinja "{{ item.rrsync_binary | d(rsnapshot__rrsync_binary) }}")))
      (args 
        (executable "bash")
        (creates (jinja "{{ item.rrsync_binary | d(rsnapshot__rrsync_binary) }}")))
      (delegate_to (jinja "{{ item.name }}"))
      (loop (jinja "{{ rsnapshot__combined_hosts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\"),
                \"packages\": q(\"flattened\", rsnapshot__host_packages)} }}")))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and (item.rsync | d(True)) | bool and hostvars[item.name] | d() and (not rsnapshot__limit | d() or (item.name in rsnapshot__limit)))"))
    (task "Deploy root ssh public key on configured hosts"
      (ansible.posix.authorized_key 
        (user (jinja "{{ item.ssh_user | d(\"root\") }}"))
        (key (jinja "{{ ansible_local.rsnapshot.ssh_identities[item.ssh_identity | d(rsnapshot__ssh_main_identity)]
             if (ansible_local.rsnapshot.ssh_identities | d() and
                 ansible_local.rsnapshot.ssh_identities[item.ssh_identity | d(rsnapshot__ssh_main_identity)] | d())
             else \"\" }}"))
        (key_options (jinja "{{ item.ssh_options | d(rsnapshot__ssh_options) }}") ",command=\"" (jinja "{{ item.ssh_command | d(rsnapshot__ssh_command) }}") "\"")
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (delegate_to (jinja "{{ item.fqdn | d(item.name) }}"))
      (loop (jinja "{{ rsnapshot__combined_hosts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (register "rsnapshot__register_ssh_keys")
      (when "(item.name | d() and item.state | d('present') not in ['ignore'] and not (item.local | d()) | bool and (item.ssh_key | d(True)) | bool and (not rsnapshot__limit | d() or (item.name in rsnapshot__limit)))"))
    (task "Remove old SSH host fingerprints if keys were modified"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit
if type dig > /dev/null ; then
    host_names=(
        \"${item_fqdn}\"
        $(dig +short A \"${item_fqdn}\")
        $(dig +short AAAA \"${item_fqdn}\")
        $(dig +search +short \"${item_fqdn}\")
    )
    for address in ${host_names[@]} ; do
        ssh-keygen -R ${address}
    done
else
    ssh-keygen -R \"${item_fqdn}\"
fi
")
      (environment 
        (item_fqdn (jinja "{{ item.item.fqdn | d(hostvars[item.item.name].ansible_fqdn if hostvars[item.item.name] | d() else item.item.name) }}")))
      (args 
        (executable "bash"))
      (loop (jinja "{{ rsnapshot__register_ssh_keys.results }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.item.name, \"state\": item.item.state | d(\"present\")} }}")))
      (register "rsnapshot__register_keygen_remove")
      (changed_when "rsnapshot__register_keygen_remove.changed | bool")
      (when "(item.item.name | d() and item.item.state | d('present') not in ['absent', 'ignore'] and not (item.item.local | d()) | bool and (item.item.ssh_scan | d(True)) | bool and item is changed and (not rsnapshot__limit | d() or (item.item.name in rsnapshot__limit)))"))
    (task "Get list of already scanned host fingerprints"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && ssh-keygen -f /root/.ssh/known_hosts -F " (jinja "{{ item.fqdn | d(hostvars[item.name].ansible_fqdn if hostvars[item.name] | d() else item.name) }}") " | grep -q '^# Host " (jinja "{{ item.fqdn | d(hostvars[item.name].ansible_fqdn if hostvars[item.name] | d() else item.name) }}") " found'")
      (args 
        (executable "bash"))
      (loop (jinja "{{ rsnapshot__combined_hosts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and not (item.local | d()) | bool and (item.ssh_scan | d(True)) | bool and (not rsnapshot__limit | d() or (item.name in rsnapshot__limit)))")
      (register "rsnapshot__register_known_hosts")
      (changed_when "False")
      (failed_when "False")
      (check_mode "False"))
    (task "Scan SSH fingerprints of the configured hosts"
      (ansible.builtin.shell "ssh-keyscan -H -T 10 -p " (jinja "{{ item.item.ssh_port | d(\"22\") }}") " " (jinja "{{ item.item.fqdn | d(hostvars[item.item.name].ansible_fqdn if hostvars[item.item.name] | d() else item.item.name) }}") " >> /root/.ssh/known_hosts")
      (loop (jinja "{{ rsnapshot__register_known_hosts.results }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.item.name, \"state\": item.item.state | d(\"present\")} }}")))
      (register "rsnapshot__register_ssh_keyscan")
      (changed_when "rsnapshot__register_ssh_keyscan.changed | bool")
      (when "(item.item.name | d() and item.item.state | d('present') not in ['absent', 'ignore'] and not (item.item.local | d()) | bool and (item.item.ssh_scan | d(True)) | bool and item.rc | d() > 0 and (not rsnapshot__limit | d() or (item.item.name in rsnapshot__limit)))"))
    (task "Remove host configuration directories if requested"
      (ansible.builtin.file 
        (path (jinja "{{ rsnapshot__config_dir + \"/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ rsnapshot__combined_hosts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "(item.name | d() and item.state | d('present') == 'absent' and (not rsnapshot__limit | d() or (item.name in rsnapshot__limit)))"))
    (task "Create host configuration directories"
      (ansible.builtin.file 
        (path (jinja "{{ rsnapshot__config_dir + \"/\" + item.name }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ rsnapshot__combined_hosts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "(item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and (not rsnapshot__limit | d() or (item.name in rsnapshot__limit)))"))
    (task "Generate host configuration files"
      (ansible.builtin.template 
        (src "etc/rsnapshot/hosts/" (jinja "{{ item.1 }}") ".j2")
        (dest (jinja "{{ rsnapshot__config_dir + \"/\" + item.0.name + \"/\" + item.1 }}"))
        (mode "0644"))
      (loop (jinja "{{ (rsnapshot__combined_hosts | debops.debops.parse_kv_items(defaults={\"options\": (rsnapshot__combined_configuration | debops.debops.parse_kv_config),
                                                                                \"excludes\": (rsnapshot__combined_excludes | debops.debops.parse_kv_items),
                                                                                \"includes\": (rsnapshot__combined_includes | debops.debops.parse_kv_items)},
                                                                      merge_keys=[\"excludes\", \"includes\"]))
            | product([\"include.txt\", \"exclude.txt\", \"rsnapshot.conf\"]) | list }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.0.name, \"state\": item.0.state | d(\"present\"), \"file\": item.1} }}")))
      (when "(item.0.name | d() and item.0.state | d('present') not in ['absent', 'ignore'] and (not rsnapshot__limit | d() or (item.0.name in rsnapshot__limit)))"))))
