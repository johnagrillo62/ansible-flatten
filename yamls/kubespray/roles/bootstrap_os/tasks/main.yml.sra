(playbook "kubespray/roles/bootstrap_os/tasks/main.yml"
  (tasks
    (task "Fetch /etc/os-release"
      (raw "cat /etc/os-release")
      (register "os_release")
      (changed_when "false")
      (check_mode "false"))
    (task "Include distro specifics vars and tasks"
      (block (list
          
          (name "Include vars")
          (include_vars (jinja "{{ item }}"))
          (tags (list
              "facts"))
          (with_first_found (list
              
              (files (list
                  (jinja "{{ os_release_dict['ID'] }}") "-" (jinja "{{ os_release_dict['VARIANT_ID'] }}") ".yml"
                  (jinja "{{ os_release_dict['ID'] }}") ".yml"))
              (paths (list
                  "vars/"))
              (skip "true")))
          
          (name "Include tasks")
          (include_tasks (jinja "{{ included_tasks_file }}"))
          (with_first_found (list
              
              (files (list
                  (jinja "{{ os_release_dict['ID'] }}") "-" (jinja "{{ os_release_dict['VARIANT_ID'] }}") ".yml"
                  (jinja "{{ os_release_dict['ID'] }}") ".yml"))
              (skip "true")))
          (loop_control 
            (loop_var "included_tasks_file"))))
      (vars 
        (os_release_dict (jinja "{{ os_release.stdout_lines | select('regex', '^.+=.*$') | map('regex_replace', '\\\"', '') |
                         map('split', '=') | community.general.dict }}"))))
    (task "Install system packages"
      (import_role 
        (name "system_packages"))
      (tags (list
          "system-packages")))
    (task "Create remote_tmp for it is used by another module"
      (file 
        (path (jinja "{{ ansible_remote_tmp | default('~/.ansible/tmp') }}"))
        (state "directory")
        (mode "0700")))
    (task "Gather facts"
      (setup 
        (gather_subset "!all")
        (filter "ansible_*")))
    (task "Assign inventory name to unconfigured hostnames (non-CoreOS, non-Flatcar, Suse and ClearLinux, non-Fedora)"
      (hostname 
        (name (jinja "{{ inventory_hostname }}")))
      (when "override_system_hostname"))
    (task "Ensure bash_completion.d folder exists"
      (file 
        (name "/etc/bash_completion.d/")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))))
