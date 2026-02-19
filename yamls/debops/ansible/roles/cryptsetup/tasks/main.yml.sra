(playbook "debops/ansible/roles/cryptsetup/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Check for Ansible version without known vulnerabilities"
      (ansible.builtin.assert 
        (that (list
            "ansible_version.full is version_compare(\"2.2.3.0\", \">=\")"))
        (msg "VULNERABLE or unsupported Ansible version DETECTED, please update to
Ansible >= v2.2.3 or a newer!
To skip, add \"--skip-tags play::security-assertions\" parameter. Refer to
the changelog of debops.cryptsetup for details. Exiting.
"))
      (run_once "True")
      (delegate_to "localhost")
      (tags (list
          "play::security-assertions"
          "role::cryptsetup:backup")))
    (task "Assert that combined device configuration is valid"
      (ansible.builtin.assert 
        (that (list
            "(cryptsetup__combined_devices | map(attribute=\"ciphertext_block_device\") | unique | length) == (cryptsetup__combined_devices | length)"
            "(cryptsetup__combined_devices | map(attribute=\"name\") | unique | length) == (cryptsetup__combined_devices | length)")))
      (run_once "True")
      (delegate_to "localhost"))
    (task "Assert that /dev/shm/ is stored in RAM (assumed to be non-persistent)"
      (ansible.builtin.command "df /dev/shm --type tmpfs")
      (changed_when "False"))
    (task "Ensure specified packages are in there desired state"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", cryptsetup__base_packages) }}"))
        (state "present"))
      (register "cryptsetup__register_packages")
      (until "cryptsetup__register_packages is succeeded"))
    (task "Create keyfile and backup directories on the remote system"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0700"))
      (when "item.condition")
      (loop (list
          
          (path (jinja "{{ cryptsetup__keyfile_remote_location }}"))
          (condition (jinja "{{ (cryptsetup__combined_devices
                      | selectattr(\"remote_keyfile\", \"undefined\") | list | length) > 0 }}"))
          
          (path (jinja "{{ cryptsetup__header_backup_remote_location }}"))
          (condition (jinja "{{ ((cryptsetup__combined_devices
                       | selectattr(\"backup_header\", \"defined\")
                       | selectattr(\"backup_header\") | list | length) > 0) or
                     (cryptsetup__header_backup | bool and ((cryptsetup__combined_devices
                                                           | selectattr(\"backup_header\", \"undefined\")
                                                           | list | length) > 0)) }}")))))
    (task "Manage Cryptsetup devices in parallel"
      (ansible.builtin.include_tasks "manage_devices.yml")
      (when "cryptsetup__devices_execution_strategy == 'parallel'")
      (vars 
        (cryptsetup__process_devices (jinja "{{ cryptsetup__combined_devices }}"))))
    (task "Manage Cryptsetup devices sequentially"
      (ansible.builtin.include_tasks "manage_devices.yml")
      (when "cryptsetup__devices_execution_strategy == 'serial'")
      (with_items (jinja "{{ cryptsetup__combined_devices }}"))
      (loop_control 
        (loop_var "cryptsetup__process_device")))))
