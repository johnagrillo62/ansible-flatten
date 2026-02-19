(playbook "debops/ansible/roles/bind/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers"))
      (tags (list
          "role::bind:config")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret"))
      (tags (list
          "role::bind:keys")))
    (task "Install packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", bind__base_packages + bind__packages) }}"))
        (state "present"))
      (register "bind__register_packages")
      (until "bind__register_packages is succeeded")
      (tags (list
          "role::bind:packages")))
    (task "Make sure that the Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755"))
      (tags (list
          "role::bind:config")))
    (task "Save local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/bind.fact.j2")
        (dest "/etc/ansible/facts.d/bind.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts"
          "role::bind:config")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers")
      (tags (list
          "role::bind:config")))
    (task "Enable/disable resolvconf integration"
      (ansible.builtin.service 
        (name "named-resolvconf")
        (enabled (jinja "{{ ansible_local.resolvconf.installed | d(False) | bool }}")))
      (when "ansible_service_mgr == \"systemd\"")
      (tags (list
          "role::bind:config")))
    (task "Allow access to additional UNIX groups"
      (ansible.builtin.user 
        (name (jinja "{{ bind__user }}"))
        (groups (jinja "{{ bind__additional_groups }}"))
        (append "True")
        (state "present"))
      (register "bind__register_unix_groups")
      (notify (list
          "Test named configuration and restart")))
    (task "Create base directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (state "directory")
        (owner "root")
        (group "bind")
        (mode (jinja "{{ item.mode | d(\"0775\") }}")))
      (loop (list
          
          (path "/etc/bind")
          (mode "02755")
          
          (path "/etc/bind/keys")
          (mode "02750")
          
          (path "/var/cache/bind")
          
          (path "/var/lib/bind")
          
          (path "/var/lib/bind/views")
          
          (path "/var/lib/bind/dnssec-keys")
          (mode "02770")
          
          (path "/var/log/named")))
      (notify (list
          "Test named configuration and restart"))
      (tags (list
          "role::bind:config")))
    (task "Create keys"
      (ansible.builtin.include_tasks "main_keys.yml")
      (tags (list
          "role::bind:config"
          "role::bind:keys")))
    (task "Generate list of toplevel views"
      (ansible.builtin.set_fact 
        (bind__tmp_top_views (jinja "{{ bind__combined_zones
                             | debops.debops.parse_kv_items(name=\"view\")
                             | selectattr(\"state\", \"eq\", \"present\") }}")))
      (tags (list
          "role::bind:config")))
    (task "Generate list of toplevel zones"
      (ansible.builtin.set_fact 
        (bind__tmp_top_zones (jinja "{{ bind__combined_zones
                             | debops.debops.parse_kv_items(name=\"name\")
                             | selectattr(\"state\", \"eq\", \"present\") }}")))
      (tags (list
          "role::bind:config")))
    (task "Make sure either zones or views are defined"
      (ansible.builtin.assert 
        (that "bind__tmp_top_views | length == 0 or bind__tmp_top_zones | length == 0"))
      (tags (list
          "role::bind:config")))
    (task "Assign zones to the default view"
      (ansible.builtin.set_fact 
        (bind__tmp_top_views (list
            
            (view "_default")
            (zones (jinja "{{ bind__tmp_top_zones }}")))))
      (when "bind__tmp_top_views | length == 0")
      (tags (list
          "role::bind:config")))
    (task "Create list of generic zones"
      (ansible.builtin.set_fact 
        (bind__tmp_generic_zones (jinja "{{ bind__combined_generic_zones
                                 | debops.debops.parse_kv_items(name=\"name\")
                                 | selectattr(\"state\", \"eq\", \"present\") }}")))
      (tags (list
          "role::bind:config")))
    (task "Add generic zones to each view"
      (ansible.builtin.set_fact 
        (bind__tmp_full_views (jinja "{{ bind__tmp_full_views | d([])
                              + [item | combine({\"zones\": item[\"zones\"]
                                                          + bind__tmp_generic_zones})] }}")))
      (loop (jinja "{{ bind__tmp_top_views }}"))
      (loop_control 
        (label (jinja "{{ item.view }}")))
      (tags (list
          "role::bind:config")))
    (task "Register the view in each zone"
      (ansible.builtin.set_fact 
        (bind__views (jinja "{{ bind__views | d([])
                     + [item | combine({\"zones\": (item[\"zones\"]
                                                  | map(\"combine\", {\"view\": item[\"view\"]}))})] }}")))
      (loop (jinja "{{ bind__tmp_full_views }}"))
      (loop_control 
        (label (jinja "{{ item.view }}")))
      (tags (list
          "role::bind:config")))
    (task "Create zone directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.dir | d(\"/var/lib/bind/views/\" + item.view + \"/\" + item.name) }}"))
        (state "directory")
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"bind\") }}"))
        (mode (jinja "{{ item.mode | d(\"0775\") }}")))
      (loop (jinja "{{ bind__views | map(attribute=\"zones\") | flatten }}"))
      (when (list
          "item.content is defined"
          "item.state | d(\"present\") == \"present\""))
      (loop_control 
        (label (jinja "{{ item.dir | d(\"/var/lib/bind/views/\" + item.view + \"/\" + item.name) }}")))
      (notify (list
          "Test named configuration and restart"))
      (tags (list
          "role::bind:config")))
    (task "Suspend dynamic updates"
      (ansible.builtin.shell "if pidof -q named > /dev/null 2>&1; then
  rndc freeze && exit 222
else true; fi
")
      (environment 
        (LC_ALL "C"))
      (register "bind__register_freeze")
      (changed_when "False")
      (failed_when "(bind__register_freeze.rc not in [ 0, 222 ]) and (\"already frozen\" not in bind__register_freeze.stderr | lower)
")
      (tags (list
          "role::bind:config")))
    (task "Register the fact that this role suspended dynamic updates"
      (ansible.builtin.file 
        (path "/var/lib/bind/.debops.frozen")
        (state "touch")
        (mode "0644"))
      (changed_when "False")
      (when "bind__register_freeze.rc == 222")
      (tags (list
          "role::bind:config")))
    (task "Generate zone files"
      (ansible.builtin.template 
        (src "var/lib/bind/views/view/zone/db.zone.j2")
        (dest (jinja "{{ (item.dir | d(\"/var/lib/bind/views/\" + item.view + \"/\" + item.name)) + \"/db.zone\" }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"bind\") }}"))
        (mode (jinja "{{ item.mode | d(\"0644\") }}"))
        (force (jinja "{{ item.force | d(False) }}")))
      (loop (jinja "{{ bind__views | map(attribute=\"zones\") | flatten }}"))
      (when (list
          "item.content is defined"
          "item.state | d(\"present\") == \"present\""))
      (loop_control 
        (label (jinja "{{ (item.dir | d(\"/var/lib/bind/views/\" + item.view + \"/\" + item.name)) + \"/db.zone\" }}")))
      (notify (list
          "Test named configuration and restart"))
      (tags (list
          "role::bind:config")))
    (task "Divert the BIND configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/bind/named.conf"))
      (tags (list
          "role::bind:config")))
    (task "Generate BIND configuration"
      (ansible.builtin.template 
        (src "etc/bind/named.conf.j2")
        (dest "/etc/bind/named.conf")
        (owner "root")
        (group "bind")
        (mode "0644"))
      (notify (list
          "Test named configuration and restart"))
      (tags (list
          "role::bind:config")))
    (task "Make sure named is restarted, if necessary"
      (ansible.builtin.meta "flush_handlers")
      (tags (list
          "role::bind:config")))
    (task "Check if dynamic updates should be resumed"
      (ansible.builtin.stat 
        (path "/var/lib/bind/.debops.frozen"))
      (changed_when "False")
      (register "bind__register_should_thaw")
      (tags (list
          "role::bind:config")))
    (task "Resume dynamic updates"
      (ansible.builtin.command "rndc thaw")
      (when "bind__register_should_thaw.stat.exists | d(False)")
      (register "bind__register_thaw")
      (until "bind__register_thaw is succeeded")
      (changed_when "False")
      (tags (list
          "role::bind:config")))
    (task "Remove dynamic update flag file"
      (ansible.builtin.file 
        (path "/var/lib/bind/.debops.frozen")
        (state "absent"))
      (changed_when "False")
      (tags (list
          "role::bind:config")))
    (task "Install backup snapshot script"
      (ansible.builtin.copy 
        (src "usr/local/sbin/debops-bind-snapshot")
        (dest "/usr/local/sbin/debops-bind-snapshot")
        (owner "root")
        (group "root")
        (mode "0755"))
      (tags (list
          "role::bind:backup")))
    (task "Configure backup snapshots as cron jobs"
      (ansible.builtin.cron 
        (name "Create " (jinja "{{ item }}") " backup snapshots of BIND configuration and zones")
        (special_time (jinja "{{ item }}"))
        (cron_file "debops-bind-snapshot")
        (user "root")
        (state (jinja "{{ \"present\"
               if (bind__snapshot_enabled | d(False) | bool
                   and item in bind__snapshot_cron_jobs)
               else \"absent\" }}"))
        (job "/usr/local/sbin/debops-bind-snapshot " (jinja "{{ item }}")))
      (loop (list
          "daily"
          "weekly"
          "monthly"))
      (loop_control 
        (label (jinja "{{ {\"state\": (\"present\"
                          if (bind__snapshot_enabled | d(False) | bool
                              and item in bind__snapshot_cron_jobs)
                          else \"absent\"),
                \"cron_job\": item} }}")))
      (tags (list
          "role::bind:backup")))
    (task "Make sure that the PKI hook directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ bind__pki_hook_path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "\"dot\" in bind__features or \"doh_https\" in bind__features")
      (tags (list
          "role::bind:pki")))
    (task "Install the BIND PKI hook"
      (ansible.builtin.template 
        (src "etc/pki/hooks/bind.j2")
        (dest (jinja "{{ bind__pki_hook_path + \"/\" + bind__pki_hook_name }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "\"dot\" in bind__features or \"doh_https\" in bind__features")
      (tags (list
          "role::bind:pki")))
    (task "Remove the BIND PKI hook"
      (ansible.builtin.file 
        (dest (jinja "{{ bind__pki_hook_path + \"/\" + bind__pki_hook_name }}"))
        (state "absent"))
      (when "\"dot\" not in bind__features and \"doh_https\" not in bind__features")
      (tags (list
          "role::bind:pki")))
    (task "Install DNSSEC rollover configuration"
      (ansible.builtin.template 
        (src "etc/bind/debops-bind-rollkey.json.j2")
        (dest "/etc/bind/debops-bind-rollkey.json")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "\"dnssec\" in bind__features and bind__dnssec_script_enabled | d(False)")
      (tags (list
          "role::bind:dnssec")))
    (task "Install DNSSEC rollover script"
      (ansible.builtin.copy 
        (src "usr/local/sbin/debops-bind-rollkey")
        (dest "/usr/local/sbin/debops-bind-rollkey")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "\"dnssec\" in bind__features and bind__dnssec_script_enabled | d(False)")
      (tags (list
          "role::bind:dnssec")))
    (task "Install DNSSEC rollover external script"
      (ansible.builtin.copy 
        (src (jinja "{{ lookup(\"debops.debops.file_src\",
                    \"usr/local/sbin/debops-bind-rollkey-action\") }}"))
        (dest "/usr/local/sbin/debops-bind-rollkey-action")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when (list
          "\"dnssec\" in bind__features"
          "bind__dnssec_script_enabled | d(False)"
          "bind__dnssec_script_method | d(\"\") == 'external'"))
      (tags (list
          "role::bind:dnssec")))
    (task "Enable DNSSEC rollover cron job"
      (ansible.builtin.cron 
        (name "Rollover DNSSEC keys for BIND")
        (special_time "weekly")
        (cron_file "debops-bind-rollkey")
        (user "root")
        (job "/usr/local/sbin/debops-bind-rollkey")
        (state (jinja "{{ \"present\"
                if (\"dnssec\" in bind__features and
                    bind__dnssec_script_enabled | d(False))
                else \"absent\" }}")))
      (tags (list
          "role::bind:dnssec")))
    (task "Remove DNSSEC rollover script"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          "/usr/local/sbin/debops-bind-rollkey"
          "/usr/local/sbin/debops-bind-rollkey-action"
          "/etc/bind/debops-bind-rollkey.json"))
      (when "\"dnssec\" not in bind__features or not bind__dnssec_script_enabled | d(False)")
      (tags (list
          "role::bind:dnssec")))))
