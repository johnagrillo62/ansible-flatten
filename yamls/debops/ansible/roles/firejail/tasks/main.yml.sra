(playbook "debops/ansible/roles/firejail/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Ensure specified packages are present"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (firejail__base_packages
                              + firejail__packages
                              + firejail__group_packages
                              + firejail__host_packages)) }}"))
        (state "present"))
      (when "firejail__deploy_state in [\"present\"]")
      (register "firejail__register_packages")
      (until "firejail__register_packages is succeeded")
      (tags (list
          "role::firejail:pkgs")))
    (task "Get program file path of firejail"
      (ansible.builtin.command "which -a firejail")
      (register "firejail__register_program_file_path")
      (check_mode "False")
      (changed_when "False")
      (failed_when "firejail__register_program_file_path.rc not in [0, 1]")
      (when "(firejail__program_file_path == \"auto\")"))
    (task "Set program file path of firejail for later use in the role"
      (ansible.builtin.set_fact 
        (firejail__program_file_path (jinja "{{ (firejail__register_program_file_path.stdout_lines
                                      + [\"/usr/bin/firejail\"]) | first }}")))
      (when "(firejail__program_file_path == \"auto\")"))
    (task "Get list of system wide profiles"
      (ansible.builtin.find 
        (file_type "file")
        (paths (list
            (jinja "{{ firejail__config_path }}")))
        (patterns "*.profile")
        (use_regex "False")
        (hidden "False")
        (recurse "False"))
      (register "firejail__register_find_system_wide_profiles"))
    (task "Set list of system wide profiles"
      (ansible.builtin.set_fact 
        (firejail__fact_system_wide_profiles (jinja "{{
      firejail__register_find_system_wide_profiles.files
        | map(attribute=\"path\")
        | map(\"basename\")
        | map(\"regex_replace\", \"\\.profile$\", \"\") | list }}"))))
    (task "Check if programs which should be sandboxed are installed"
      (ansible.builtin.command "which -a " (jinja "{{ item | quote }}"))
      (check_mode "False")
      (changed_when "False")
      (failed_when "firejail__register_cmd_which_programs.rc not in [0, 1]")
      (register "firejail__register_cmd_which_programs")
      (when "(item in (firejail__combined_program_sandboxes.keys() | list + (firejail__fact_system_wide_profiles if (firejail__global_profiles_system_wide_sandboxed == \"if_installed\") else [])))")
      (with_items (jinja "{{ firejail__combined_program_sandboxes.keys() | list | union(firejail__fact_system_wide_profiles) }}")))
    (task "Set list of installed programs"
      (ansible.builtin.set_fact 
        (firejail__fact_installed_programs (jinja "{{
      firejail__register_cmd_which_programs.results
      | selectattr(\"rc\", \"defined\")
      | selectattr(\"rc\", \"equalto\", 0)
      | map(attribute=\"stdout_lines\")
      | map(\"first\") | map(\"basename\") | list }}"))))
    (task "Ensure that the local bin path exists"
      (ansible.builtin.file 
        (path (jinja "{{ firejail__system_local_bin_path }}"))
        (state "directory")
        (mode "0755")))
    (task "Create/remove symlinks for sandboxed programs"
      (ansible.builtin.file 
        (path (jinja "{{ firejail__system_local_bin_path + \"/\" + item }}"))
        (src (jinja "{{ firejail__program_file_path }}"))
        (state (jinja "{{ \"link\"
               if (firejail__deploy_state in [\"present\"] and
                   ((item in firejail__combined_program_sandboxes and
                    ((firejail__combined_program_sandboxes[item].system_wide_sandboxed
                      | d(firejail__program_sandboxes_system_wide_sandboxed) == \"present\") or
                     ((firejail__combined_program_sandboxes[item].system_wide_sandboxed
                       | d(firejail__program_sandboxes_system_wide_sandboxed) == \"if_installed\") and
                       item in firejail__fact_installed_programs))) or
                    (item not in firejail__combined_program_sandboxes and
                     ((firejail__global_profiles_system_wide_sandboxed == \"present\") or
                     (firejail__global_profiles_system_wide_sandboxed == \"if_installed\" and
                      item in firejail__fact_installed_programs)))))
               else \"absent\" }}"))
        (owner "root")
        (group "root")
        (mode "0755")
        (force (jinja "{{ ansible_check_mode | d(omit) }}")))
      (when "not (item in firejail__combined_program_sandboxes and firejail__combined_program_sandboxes[item].system_wide_sandboxed | d(\"present\") in [\"ignored\"])")
      (with_items (jinja "{{ firejail__combined_program_sandboxes.keys() | list | union(firejail__fact_system_wide_profiles) }}")))
    (task "Provide (additional) profiles"
      (ansible.builtin.copy 
        (dest (jinja "{{ item.value.profile.dest | d(firejail__config_path + \"/\" + item.key + \".profile\") }}"))
        (backup (jinja "{{ item.value.profile.backup | d(omit) }}"))
        (content (jinja "{{ item.value.profile.content | d(omit) }}"))
        (directory_mode (jinja "{{ item.value.profile.directory_mode | d(omit) }}"))
        (follow (jinja "{{ item.value.profile.follow | d(omit) }}"))
        (force (jinja "{{ item.value.profile.force | d(omit) }}"))
        (owner (jinja "{{ item.value.profile.owner | d(\"root\") }}"))
        (group (jinja "{{ item.value.profile.group | d(\"root\") }}"))
        (mode (jinja "{{ item.value.profile.mode | d(\"0644\") }}"))
        (selevel (jinja "{{ item.value.profile.selevel | d(omit) }}"))
        (serole (jinja "{{ item.value.profile.serole | d(omit) }}"))
        (setype (jinja "{{ item.value.profile.setype | d(omit) }}"))
        (seuser (jinja "{{ item.value.profile.seuser | d(omit) }}"))
        (src (jinja "{{ item.value.profile.src | d(omit) }}"))
        (validate (jinja "{{ item.value.profile.validate | d(omit) }}")))
      (when "(firejail__deploy_state in [\"present\"] and \"profile\" in item.value and item.value.profile.state | d(\"present\") == \"present\")")
      (with_dict (jinja "{{ firejail__combined_program_sandboxes }}"))
      (tags (list
          "role::firejail:profile")))
    (task "Delete profiles"
      (ansible.builtin.file 
        (path (jinja "{{ item.value.profile.dest | d(firejail__config_path + \"/\" + item.key + \".profile\") }}"))
        (state "absent"))
      (when "(\"profile\" in item.value and (item.value.profile.state | d(\"present\") == \"absent\" or firejail__deploy_state in [\"absent\"]))")
      (with_dict (jinja "{{ firejail__combined_program_sandboxes }}"))
      (tags (list
          "role::firejail:profile")))
    (task "Get list of files in local bin path"
      (ansible.builtin.find 
        (file_type "file")
        (paths (list
            (jinja "{{ firejail__system_local_bin_path }}")))
        (hidden "False")
        (recurse "False"))
      (register "firejail__register_profile_program_symlinks_find")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Workaround to get the realpath"
      (ansible.builtin.stat 
        (path (jinja "{{ item.path }}")))
      (register "firejail__register_profile_program_symlinks_stat")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (with_items (jinja "{{ firejail__register_profile_program_symlinks_find.files }}")))
    (task "Remove program symlink when profiles is is not defined in any variable"
      (ansible.builtin.file 
        (path (jinja "{{ item.stat.path }}"))
        (state "absent"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (when "(item.stat.islnk and ((item.stat.lnk_source | basename == \"firejail\" and (item.stat.lnk_source != firejail__program_file_path or firejail__deploy_state not in [\"present\"])) or (item.stat.lnk_source == firejail__program_file_path and (item.stat.path | basename not in (firejail__combined_program_sandboxes.keys() | list | union(firejail__fact_system_wide_profiles))))))")
      (with_items (jinja "{{ firejail__register_profile_program_symlinks_stat.results }}")))
    (task "Ensure ~/.local/share/applications exists"
      (ansible.builtin.file 
        (path "~/.local/share/applications")
        (state "directory")
        (mode "0755"))
      (become "True")
      (become_user (jinja "{{ item.name }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (when "firejail__deploy_state in [\"present\"] and item != \"root\" and item.state | d(\"present\") == \"present\"")
      (loop (jinja "{{ q(\"flattened\", firejail__combined_fix_for_users) }}")))
    (task "Apply workaround for desktop files"
      (ansible.builtin.command "firecfg --fix")
      (register "firejail__register_cmd_firecfg_fix")
      (changed_when "(\"created\" in firejail__register_cmd_firecfg_fix.stdout)")
      (become "True")
      (become_user (jinja "{{ item.name }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (when "firejail__deploy_state in [\"present\"] and item != \"root\" and item.state | d(\"present\") == \"present\"")
      (loop (jinja "{{ q(\"flattened\", firejail__combined_fix_for_users) }}")))
    (task "Ensure specified packages are absent"
      (ansible.builtin.package 
        (name (jinja "{{ item }}"))
        (state "absent"))
      (when "firejail__deploy_state in [\"absent\"]")
      (loop (jinja "{{ q(\"flattened\", firejail__base_packages
                           + firejail__packages
                           + firejail__group_packages
                           + firejail__host_packages) }}"))
      (tags (list
          "role::firejail:pkgs")))))
