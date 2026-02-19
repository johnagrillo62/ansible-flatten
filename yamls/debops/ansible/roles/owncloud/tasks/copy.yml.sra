(playbook "debops/ansible/roles/owncloud/tasks/copy.yml"
  (tasks
    (task "Ensure that parent directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ (owncloud__data_path + \"/\" + item.dest) | dirname }}"))
        (state "directory")
        (recurse (jinja "{{ item.parent_dirs_recurse | d(True) }}"))
        (owner (jinja "{{ item.parent_dirs_owner | d(owncloud__app_user) }}"))
        (group (jinja "{{ item.parent_dirs_group | d(owncloud__app_group) }}"))
        (mode (jinja "{{ item.parent_dirs_mode | d(\"0755\") }}")))
      (when "((item.parent_dirs_create | d(True) | bool) and item.dest | d() and item.state | d(\"present\") != 'absent')")
      (loop (jinja "{{ q(\"flattened\", owncloud__user_files
                           + owncloud__user_files_group
                           + owncloud__user_files_host) }}")))
    (task "Copy files to ownCloud user profiles"
      (ansible.builtin.copy 
        (dest (jinja "{{ owncloud__data_path + \"/\" + item.dest }}"))
        (src (jinja "{{ item.src | d(omit) }}"))
        (content (jinja "{{ item.content | d(omit) }}"))
        (owner (jinja "{{ item.owner | d(owncloud__app_user) }}"))
        (group (jinja "{{ item.group | d(owncloud__app_group) }}"))
        (mode (jinja "{{ item.mode | d(\"u=rwX,g=rX,o=rX\") }}"))
        (selevel (jinja "{{ item.selevel | d(omit) }}"))
        (serole (jinja "{{ item.serole | d(omit) }}"))
        (setype (jinja "{{ item.setype | d(omit) }}"))
        (seuser (jinja "{{ item.seuser | d(omit) }}"))
        (follow (jinja "{{ item.follow | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (backup (jinja "{{ item.backup | d(omit) }}"))
        (validate (jinja "{{ item.validate | d(omit) }}"))
        (remote_src (jinja "{{ item.remote_src | d(omit) }}"))
        (directory_mode (jinja "{{ item.directory_mode | d(omit) }}")))
      (register "owncloud__register_create_user_files")
      (loop (jinja "{{ q(\"flattened\", owncloud__user_files
                           + owncloud__user_files_group
                           + owncloud__user_files_host) }}"))
      (when "((item.src | d() or item.content | d()) and item.dest | d() and (item.state | d('present') != 'absent'))"))
    (task "Delete files on remote hosts"
      (ansible.builtin.file 
        (path (jinja "{{ owncloud__data_path + \"/\" + item.dest }}"))
        (state "absent"))
      (register "owncloud__register_delete_user_files")
      (loop (jinja "{{ q(\"flattened\", owncloud__user_files
                           + owncloud__user_files_group
                           + owncloud__user_files_host) }}"))
      (when "(item.dest | d() and (item.state | d('present') == 'absent'))"))
    (task "Run occ commands as specified in the inventory"
      (ansible.builtin.include_tasks "run_occ.yml")
      (loop_control 
        (loop_var "owncloud__files_scan_item"))
      (when "owncloud__files_scan_item is changed")
      (with_items (jinja "{{ (owncloud__register_create_user_files.results | d([])
                   + owncloud__register_delete_user_files.results | d([]))
                  if (owncloud__register_create_user_files is defined and
                      owncloud__register_create_user_files is not skipped)
                  else [] }}")))))
