(playbook "debops/ansible/roles/snapshot_snapper/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Combine snapper inventory variables"
      (ansible.builtin.set_fact 
        (snapshot_snapper__templates_combined (jinja "{{
                snapshot_snapper__templates
      | combine(snapshot_snapper__host_group_templates, recursive=True)
      | combine(snapshot_snapper__host_templates, recursive=True) }}"))
        (snapshot_snapper__volumes_combined (jinja "{{
      (snapshot_snapper__volumes | list) +
      (snapshot_snapper__host_group_volumes | list) +
      (snapshot_snapper__host_volumes | list) }}"))
        (snapshot_snapper__combined_packages (jinja "{{
      (snapshot_snapper__base_packages | list) +
      (snapshot_snapper__packages | list) }}")))
      (tags (list
          "role::snapshot_snapper:reinit")))
    (task "Ensure specified packages are in there desired state"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", snapshot_snapper__combined_packages) }}"))
        (state "present"))
      (register "snapshot_snapper__register_packages")
      (until "snapshot_snapper__register_packages is succeeded"))
    (task "Divert original configuration under /etc"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ item }}")))
      (register "snapshot_snapper__updatedb_diverted_register")
      (when "ansible_os_family in [\"Debian\"]")
      (loop (jinja "{{ snapshot_snapper__divert_files | flatten }}")))
    (task "Copy diverted configuration file to original location"
      (ansible.builtin.copy 
        (src (jinja "{{ item }}") ".dpkg-divert")
        (dest (jinja "{{ item }}"))
        (remote_src "True")
        (force "False")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "snapshot_snapper__updatedb_diverted_register is changed")
      (loop (jinja "{{ q(\"flattened\", snapshot_snapper__divert_files) }}")))
    (task "Check if snapshots are already excluded from updatedb"
      (ansible.builtin.command "grep PRUNENAMES=.*" (jinja "{{ snapshot_snapper__directory }}") ".* /etc/updatedb.conf")
      (failed_when "False")
      (changed_when "False")
      (check_mode "False")
      (when "snapshot_snapper__directory | d() and \"mlocate\" in snapshot_snapper__combined_packages")
      (register "snapshot_snapper__register_updatedb_configured"))
    (task "Configure updatedb to exclude snapshots"
      (ansible.builtin.lineinfile 
        (dest "/etc/updatedb.conf")
        (backrefs "yes")
        (regexp "^(# )?PRUNENAMES=(\".*)\"$")
        (line "PRUNENAMES=\\2 " (jinja "{{ snapshot_snapper__directory }}") "\"")
        (mode "0644"))
      (when "snapshot_snapper__register_updatedb_configured.rc != 0"))
    (task "Check which snapper /etc/snapper/configs/ exist"
      (ansible.builtin.stat 
        (path "/etc/snapper/configs/" (jinja "{{ item.name }}")))
      (when "(snapshot_snapper__auto_reinit | bool and item.path | d() and item.name | d() and (item.state | d(\"present\") == \"present\"))")
      (register "snapshot_snapper__register_snapper_configs")
      (tags (list
          "role::snapshot_snapper:reinit"))
      (with_items (jinja "{{ snapshot_snapper__volumes_combined }}")))
    (task "Check which snapper snapshot directories exist"
      (ansible.builtin.stat 
        (path (jinja "{{ item.path + \"/\" + snapshot_snapper__directory }}")))
      (when "(snapshot_snapper__auto_reinit | bool and item.path | d() and item.name | d() and (item.state | d(\"present\") == \"present\"))")
      (tags (list
          "role::snapshot_snapper:reinit"))
      (register "snapshot_snapper__register_snapshot_directory")
      (with_items (jinja "{{ snapshot_snapper__volumes_combined }}")))
    (task "Delete snapper configuration to automatically reinit"
      (ansible.builtin.file 
        (path "/etc/snapper/configs/" (jinja "{{ item.0.item.name }}"))
        (state "absent"))
      (tags (list
          "role::snapshot_snapper:reinit"))
      (when "(item.0 is not skipped and item.1 is not skipped and item.0.stat.exists | d(item.0.stat.isreg) and not item.1.stat.exists)")
      (register "snapshot_snapper__register_snapper_configs_delete")
      (with_together (list
          (jinja "{{ snapshot_snapper__register_snapper_configs.results }}")
          (jinja "{{ snapshot_snapper__register_snapshot_directory.results }}"))))
    (task "Get list of active snapper volumes"
      (ansible.builtin.find 
        (file_type "file")
        (paths (list
            "/etc/snapper/configs/"))
        (hidden "False")
        (recurse "False"))
      (register "snapshot_snapper__register_snapper_configs_current")
      (when "(snapshot_snapper__auto_reinit | bool)")
      (tags (list
          "role::snapshot_snapper:reinit")))
    (task "Update active snapper volumes in /etc/default/snapper"
      (ansible.builtin.lineinfile 
        (dest "/etc/default/snapper")
        (state "present")
        (regexp "^SNAPPER_CONFIGS=\"[^\"]*\"$")
        (line "SNAPPER_CONFIGS=\"" (jinja "{{
           snapshot_snapper__register_snapper_configs_current.files
           | map(attribute=\"path\")
           | map(\"replace\", \"/etc/snapper/configs/\", \"\")
           | join(\" \") }}") "\"")
        (mode "0644"))
      (when "(snapshot_snapper__auto_reinit | bool)")
      (tags (list
          "role::snapshot_snapper:reinit")))
    (task "Configure snapper templates"
      (ansible.builtin.template 
        (src "etc/snapper/config-templates/item.j2")
        (dest "/etc/snapper/config-templates/" (jinja "{{ item.key }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_dict (jinja "{{ snapshot_snapper__templates_combined }}")))
    (task "Create initial configuration per volume"
      (ansible.builtin.command "snapper --config '" (jinja "{{ item.name | default(\"root\") }}") "' create-config " (jinja "{{ (\"'--template' '\" + item.template + \"'\") if (item.template | d()) else '' }}") " '" (jinja "{{ item.path }}") "'")
      (args 
        (creates "/etc/snapper/configs/" (jinja "{{ item.name }}")))
      (when "(item.path | d() and item.name | d() and (item.state | d(\"present\") == \"present\"))")
      (with_items (jinja "{{ snapshot_snapper__volumes_combined }}")))
    (task "Adjust configuration per volume"
      (ansible.builtin.include_tasks "configure_snapper_volume.yml")
      (loop_control 
        (loop_var "snapshot_snapper__volume"))
      (with_items (jinja "{{ snapshot_snapper__volumes_combined }}")))))
