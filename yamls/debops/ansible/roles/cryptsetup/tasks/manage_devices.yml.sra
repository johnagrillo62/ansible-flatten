(playbook "debops/ansible/roles/cryptsetup/tasks/manage_devices.yml"
  (tasks
    (task "Set device list to process to a single device"
      (ansible.builtin.set_fact 
        (cryptsetup__process_devices (jinja "{{ [cryptsetup__process_device] }}")))
      (when "cryptsetup__process_device is defined"))
    (task "Assert that device configuration is valid"
      (ansible.builtin.assert 
        (that (list
            "item.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present', 'absent']"
            "item.name is defined and item.name is string"
            "(item.state | d(cryptsetup__state) == 'ansible_controller_mounted' and 'remote_keyfile' not in item) or item.state | d(cryptsetup__state) != 'ansible_controller_mounted'"
            "item.keyfile_gen_type | d(cryptsetup__keyfile_gen_type) in ['binary', 'text']")))
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Create secrets directory on Ansible controller"
      (ansible.builtin.file 
        (path (jinja "{{ cryptsetup__secret_path + \"/\" + item.name }}"))
        (state "directory")
        (owner (jinja "{{ cryptsetup__secret_owner }}"))
        (group (jinja "{{ cryptsetup__secret_group }}"))
        (mode (jinja "{{ cryptsetup__secret_mode }}")))
      (become "False")
      (delegate_to "localhost")
      (when "(item.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and 'remote_keyfile' not in item)")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Generate binary keyfile on the Ansible controller"
      (ansible.builtin.shell "head -c " (jinja "{{ ((512 / 8) if (item.key_size | d(cryptsetup__key_size) == \"default\")
                             else ((item.key_size | d(cryptsetup__key_size)) / 8)) | int }}") " \\ " (jinja "{{ cryptsetup__keyfile_source_dev | quote }}") " > \\ " (jinja "{{ (item.keyfile | d(cryptsetup__secret_path + \"/\" + item.name + \"/keyfile.raw\")) | quote }}"))
      (args 
        (creates (jinja "{{ item.keyfile | d(cryptsetup__secret_path + \"/\" + item.name + \"/keyfile.raw\") }}")))
      (become "False")
      (delegate_to "localhost")
      (register "cryptsetup__register_keyfile_gen")
      (when "(item.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and ('remote_keyfile' not in item) and (item.keyfile_gen_type | d(cryptsetup__keyfile_gen_type) == 'binary'))")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Generate text/passphrase keyfile on the Ansible controller"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && " (jinja "{{ item.keyfile_gen_command | d(cryptsetup__keyfile_gen_command) }}") " \\ | tr -d \"\\n\" > " (jinja "{{ (item.keyfile | d(cryptsetup__secret_path + \"/\" + item.name + \"/keyfile.raw\")) | quote }}"))
      (args 
        (executable "bash")
        (creates (jinja "{{ item.keyfile | d(cryptsetup__secret_path + \"/\" + item.name + \"/keyfile.raw\") }}")))
      (become "False")
      (delegate_to "localhost")
      (register "cryptsetup__register_keyfile_gen")
      (when "(item.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and ('remote_keyfile' not in item) and (item.keyfile_gen_type | d(cryptsetup__keyfile_gen_type) == 'text'))")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Enforce permissions of the keyfile on the Ansible controller"
      (ansible.builtin.file 
        (path (jinja "{{ item.keyfile | d(cryptsetup__secret_path + \"/\" + item.name + \"/keyfile.raw\") }}"))
        (owner (jinja "{{ cryptsetup__secret_owner }}"))
        (group (jinja "{{ cryptsetup__secret_group }}"))
        (mode (jinja "{{ cryptsetup__secret_mode }}")))
      (tags (list
          "role::cryptsetup:backup"))
      (become "False")
      (delegate_to "localhost")
      (when "(item.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and not ansible_check_mode and 'remote_keyfile' not in item)")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Copy keyfiles to remote system"
      (ansible.builtin.copy 
        (dest (jinja "{{ (\"/dev/shm\"
              if (item.state | d(cryptsetup__state) == \"ansible_controller_mounted\")
              else cryptsetup__keyfile_remote_location)
              + \"/\" + item.name + \"_keyfile.raw\" }}"))
        (backup (jinja "{{ item.keyfile_backup | d(omit) }}"))
        (follow (jinja "{{ item.keyfile_follow | d(omit) }}"))
        (force (jinja "{{ item.keyfile_force | d(omit) }}"))
        (group (jinja "{{ item.keyfile_group | d(cryptsetup__keyfile_group) }}"))
        (mode (jinja "{{ item.keyfile_mode | d(cryptsetup__keyfile_mode) }}"))
        (owner (jinja "{{ item.keyfile_owner | d(cryptsetup__keyfile_owner) }}"))
        (selevel (jinja "{{ item.keyfile_selevel | d(omit) }}"))
        (serole (jinja "{{ item.keyfile_serole | d(omit) }}"))
        (setype (jinja "{{ item.keyfile_setype | d(omit) }}"))
        (seuser (jinja "{{ item.keyfile_seuser | d(omit) }}"))
        (src (jinja "{{ item.keyfile | d(cryptsetup__secret_path + \"/\" + item.name + \"/keyfile.raw\") }}"))
        (validate (jinja "{{ item.keyfile_validate | d(omit) }}")))
      (when "(item.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and not ansible_check_mode and 'remote_keyfile' not in item)")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Check if ciphertext block device exists"
      (ansible.builtin.stat 
        (path (jinja "{{ item.ciphertext_block_device }}"))
        (get_checksum "False"))
      (register "cryptsetup__register_ciphertext_device")
      (when "(item.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'])")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}"))
      (tags (list
          "role::cryptsetup:backup")))
    (task "Fail when ciphertext block device does not exist but the state requires for it to exist"
      (ansible.builtin.fail 
        (msg "Ciphertext block device " (jinja "{{ item.0.ciphertext_block_device }}") " does not
exist and state was requested to be " (jinja "{{ item.0.state | d(cryptsetup__state) }}") "!
"))
      (when "(item.0.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted'] and not item.1.stat.exists)")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_ciphertext_device.results | d([]) }}"))))
    (task "Fail when ciphertext block device does not exist but the keyfile has changed"
      (ansible.builtin.fail 
        (msg "Ciphertext block device " (jinja "{{ item.0.ciphertext_block_device }}") " does not
exist but the keyfile has just been generated. You will need to make the
block device available during a later Ansible run so that the encryption
and filesystem layer can be setup. You will not see this error on later
runs but that does not mean that the encryption and filesystem setup was
successfully until you make the block device available. See documentation
for details.
"))
      (when "(item.0.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and not item.1.stat.exists and item.2 is changed)")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_ciphertext_device.results | d([]) }}")
          (jinja "{{ cryptsetup__register_keyfile_gen.results | d([]) }}"))))
    (task "Create encryption layer"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && cryptsetup isLuks \"" (jinja "{{ item.0.ciphertext_block_device }}") "\" || cryptsetup luksFormat --batch-mode --verbose " (jinja "{{ \"\" if (item.0.hash | d(cryptsetup__hash) == \"default\")
               else (\"--hash=\" + item.0.hash | d(cryptsetup__hash)) }}") " " (jinja "{{ \"\" if (item.0.cipher | d(cryptsetup__cipher) == \"default\")
               else (\"--cipher=\" + item.0.cipher | d(cryptsetup__cipher)) }}") " " (jinja "{{ \"\" if (item.0.key_size | d(cryptsetup__key_size) == \"default\")
               else (\"--key-size=\" + item.0.key_size | d(cryptsetup__key_size) | string) }}") " " (jinja "{{ \"\" if (item.0.iter_time | d(cryptsetup__iter_time) == \"default\")
               else (\"--iter-time=\" + item.0.iter_time | d(cryptsetup__iter_time) | string) }}") " " (jinja "{% if cryptsetup__use_dev_random | d(\"default\") != \"default\" %}") " " (jinja "{{ \"--use-random\" if cryptsetup__use_dev_random else \"--use-urandom\" }}") " " (jinja "{% endif %}") " --key-file '" (jinja "{{ item.0.remote_keyfile | d((\"/dev/shm\"
                        if (item.0.state | d(cryptsetup__state) == \"ansible_controller_mounted\")
                        else cryptsetup__keyfile_remote_location)
                        + \"/\" + item.0.name + \"_keyfile.raw\") }}") "' '" (jinja "{{ item.0.ciphertext_block_device }}") "'")
      (args 
        (executable "bash"))
      (register "cryptsetup__register_cmd")
      (changed_when "(\"Command successful.\" == cryptsetup__register_cmd.stdout)")
      (when "(item.0.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and item.1.stat.exists and item.0.mode | d(\"luks\") == \"luks\")")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_ciphertext_device.results | d([]) }}"))))
    (task "Get UUID for ciphertext block device"
      (ansible.builtin.command "blkid -s UUID -o value \"" (jinja "{{ item.0.ciphertext_block_device }}") "\"")
      (register "cryptsetup__register_ciphertext_blkid")
      (changed_when "False")
      (failed_when "(cryptsetup__register_ciphertext_blkid.rc not in [0, 2])")
      (check_mode "False")
      (when "(item.0.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and item.1.stat.exists)")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_ciphertext_device.results | d([]) }}"))))
    (task "Ensure ciphertext block device is configured in crypttab"
      (community.general.crypttab 
        (backing_device (jinja "{{ (\"UUID=\" + item.1.stdout)
                        if (item.1.stdout | d() and item.0.use_uuid | d(cryptsetup__use_uuid) | bool)
                        else item.0.ciphertext_block_device }}"))
        (name (jinja "{{ item.0.name }}"))
        (opts (jinja "{{ (item.2.crypttab_options | d(cryptsetup__crypttab_options | d([])) | list | sort | unique | join(\",\"))
              if ((item.2.crypttab_options | d(cryptsetup__crypttab_options | d([])) | list | length) > 0)
              else \"none\" }}"))
        (password (jinja "{{ item.0.remote_keyfile | d((\"/dev/shm\"
                  if (item.0.state | d(cryptsetup__state) == \"ansible_controller_mounted\")
                  else cryptsetup__keyfile_remote_location)
                  + \"/\" + item.0.name + \"_keyfile.raw\") }}"))
        (path (jinja "{{ item.0.crypttab_path | d(omit) }}"))
        (state "present"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (when "(item.0.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'])")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_ciphertext_blkid.results | d([]) }}")
          (jinja "{{ lookup(\"template\", \"lookup/cryptsetup__devices_crypttab_options.j2\") | from_yaml }}"))))
    (task "Start plaintext device mapper target"
      (ansible.builtin.command "cryptdisks_start \"" (jinja "{{ item.0.name }}") "\"")
      (register "cryptsetup__register_cryptdisks_start")
      (changed_when "(\"(started)\" in cryptsetup__register_cryptdisks_start.stdout)")
      (when "(item.0.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and item.1.stat.exists)")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_ciphertext_device.results | d([]) }}"))))
    (task "Check if plaintext device mapper target exists"
      (ansible.builtin.stat 
        (path "/dev/mapper/" (jinja "{{ item.name }}")))
      (register "cryptsetup__register_plaintext_device")
      (when "(item.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and (item.manage_filesystem | d(True) | bool))")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Create filesystem on plaintext device mapper target"
      (community.general.filesystem 
        (dev "/dev/mapper/" (jinja "{{ item.0.name }}"))
        (force (jinja "{{ item.0.format_force | d(omit) }}"))
        (fstype (jinja "{{ item.0.fstype | d(cryptsetup__fstype) }}"))
        (opts (jinja "{{ item.0.format_options | d(omit) }}")))
      (when "(item.1 | d() and item.1.stat | d() and item.1.stat.exists | d() and (item.0.create_filesystem | d(item.0.manage_filesystem | d(True)) | bool) and not (item.0.swap | d(False) | bool))")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_plaintext_device.results | d([]) }}"))))
    (task "Ensure mount directories exist when manually mounted"
      (ansible.builtin.file 
        (path (jinja "{{ item.mount | d(cryptsetup__mountpoint_parent_directory + \"/\" + item.name) }}"))
        (state "directory")
        (mode "0755"))
      (when "(item.state | d(cryptsetup__state) in ['present'] and (item.manage_filesystem | d(True) | bool))")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Create LUKS header backup"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
rm -f " (jinja "{{ (cryptsetup__header_backup_remote_location + \"/\" + item.0.name + \"_header_backup.raw\") | quote }}") "
cryptsetup luksHeaderBackup " (jinja "{{ item.0.ciphertext_block_device | quote }}") " \\
  --header-backup-file " (jinja "{{ (cryptsetup__header_backup_remote_location + \"/\"
                           + item.0.name + \"_header_backup.raw\") | quote }}") "
")
      (tags (list
          "role::cryptsetup:backup"))
      (args 
        (executable "bash"))
      (changed_when "False")
      (when "((item.0.backup_header | d(cryptsetup__header_backup) | bool) and item.0.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and item.1.stat.exists and item.0.mode | d(\"luks\") == \"luks\")")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_ciphertext_device.results | d([]) }}"))))
    (task "Store the header backup in secret directory on to the Ansible controller"
      (ansible.builtin.fetch 
        (src (jinja "{{ cryptsetup__header_backup_remote_location + \"/\" + item.0.name + \"_header_backup.raw\" }}"))
        (dest (jinja "{{ cryptsetup__secret_path + \"/\" + item.0.name + \"/header_backup.raw\" }}"))
        (fail_on_missing "True")
        (flat "True"))
      (tags (list
          "role::cryptsetup:backup"))
      (when "((item.0.backup_header | d(cryptsetup__header_backup) | bool) and item.0.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and item.1.stat.exists and item.0.mode | d(\"luks\") == \"luks\")")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_ciphertext_device.results | d([]) }}"))))
    (task "Enforce permissions of the header backup on the Ansible controller"
      (ansible.builtin.file 
        (path (jinja "{{ cryptsetup__secret_path + \"/\" + item.0.name + \"/header_backup.raw\" }}"))
        (owner (jinja "{{ cryptsetup__secret_owner }}"))
        (group (jinja "{{ cryptsetup__secret_group }}"))
        (mode (jinja "{{ cryptsetup__secret_mode }}")))
      (tags (list
          "role::cryptsetup:backup"))
      (become "False")
      (delegate_to "localhost")
      (when "((item.0.backup_header | d(cryptsetup__header_backup) | bool) and item.0.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted', 'unmounted', 'present'] and item.1.stat.exists and item.0.mode | d(\"luks\") == \"luks\" and not ansible_check_mode)")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_ciphertext_device.results | d([]) }}"))))
    (task "Manage fstab and mount state of the plaintext device mapper targets"
      (ansible.posix.mount 
        (src "/dev/mapper/" (jinja "{{ item.name }}"))
        (fstype (jinja "{{ item.fstype | d(cryptsetup__fstype) }}"))
        (name (jinja "{{ item.mount | d(cryptsetup__mountpoint_parent_directory + \"/\" + item.name) }}"))
        (opts (jinja "{{ (item.mount_options | d(cryptsetup__mount_options | d([]))) | list | sort | unique | join(\",\") }}"))
        (dump (jinja "{{ item.mount_dump | d(omit) }}"))
        (passno (jinja "{{ item.mount_passno | d(omit) }}"))
        (fstab (jinja "{{ item.fstab_path | d(cryptsetup__fstab_file) }}"))
        (state (jinja "{{ \"mounted\"
                if (item.state | d(cryptsetup__state) == \"ansible_controller_mounted\")
                else item.state | d(cryptsetup__state) }}")))
      (when "((item.manage_filesystem | d(True) | bool) and not (item.swap | d(False) | bool))")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Disable swap devices when requested"
      (ansible.builtin.shell "if [ -e " (jinja "{{ (\"/dev/mapper/\" + item.name) | quote }}") " ]
then swapoff " (jinja "{{ (\"/dev/mapper/\" + item.name) | quote }}") "
else true
fi
")
      (changed_when "False")
      (when "((item.swap | d(False) | bool) and (item.state | d(cryptsetup__state) in [\"unmounted\", \"absent\"]))")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Manage swap devices in fstab"
      (ansible.posix.mount 
        (src (jinja "{{ \"/dev/mapper/\" + item.name }}"))
        (name "none")
        (fstype "swap")
        (opts (jinja "{{ ((item.swap_options | d([]) | list) +
                 ([\"pri=\" + (item.priority | d(cryptsetup__swap_priority) | string)]))
                | list | sort | unique | join(\",\") }}"))
        (dump "0")
        (passno "0")
        (fstab (jinja "{{ item.fstab_path | d(cryptsetup__fstab_file) }}"))
        (state (jinja "{{ (item.state | d(cryptsetup__state) == \"absent\") | ternary(\"absent\", \"present\") }}")))
      (register "cryptsetup__register_swap_fstab")
      (when "item.swap | d(False) | bool")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Enable swap devices"
      (ansible.builtin.command "swapon --priority " (jinja "{{ (item.item.priority | d(cryptsetup__swap_priority) | string) | quote }}") " " (jinja "{{ (\"/dev/mapper/\" + item.item.name) | quote }}"))
      (register "cryptsetup__register_swapon")
      (changed_when "cryptsetup__register_swapon.changed | bool")
      (when "(item is changed and (item.item.swap | d(False) | bool) and (item.item.state | d(cryptsetup__state) in ['mounted', 'ansible_controller_mounted']))")
      (with_items (jinja "{{ cryptsetup__register_swap_fstab.results | d([]) }}")))
    (task "Ensure mount directory is absent"
      (ansible.builtin.file 
        (path (jinja "{{ item.mount | d(cryptsetup__mountpoint_parent_directory + \"/\" + item.name) }}"))
        (state "absent"))
      (when "(item.state | d(cryptsetup__state) in ['absent'])")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Stop plaintext device mapper target"
      (ansible.builtin.command "cryptdisks_stop \"" (jinja "{{ item.0.name }}") "\"")
      (register "cryptsetup__register_cryptdisks_stop")
      (changed_when "(\"(stopping)\" in cryptsetup__register_cryptdisks_stop.stdout)")
      (failed_when "(cryptsetup__register_cryptdisks_stop.rc != 0 and not (('Stopping crypto disk...' == cryptsetup__register_cryptdisks_stop.stdout or 'failed, not found in crypttab' in cryptsetup__register_cryptdisks_stop.stdout) and cryptsetup__register_cryptdisks_stop.rc == 1))")
      (when "(item.0.state | d(cryptsetup__state) in ['unmounted', 'absent'] or (item.0.state | d(cryptsetup__state) in ['present'] and item.1 is changed))")
      (with_together (list
          (jinja "{{ cryptsetup__process_devices | d([]) }}")
          (jinja "{{ cryptsetup__register_cryptdisks_start.results | d([]) }}"))))
    (task "Ensure ciphertext block device is absent in crypttab"
      (community.general.crypttab 
        (name (jinja "{{ item.name }}"))
        (path (jinja "{{ item.crypttab_path | d(omit) }}"))
        (state "absent"))
      (when "(item.state | d(cryptsetup__state) in ['absent'])")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Check if remote keyfiles are regular files"
      (ansible.builtin.stat 
        (path (jinja "{{ (item.remote_keyfile | d((\"/dev/shm\"
               if (item.state | d(cryptsetup__state) == \"ansible_controller_mounted\")
               else cryptsetup__keyfile_remote_location)
               + \"/\" + item.name + \"_keyfile.raw\")) }}")))
      (register "cryptsetup__register_stat_remote_keyfile")
      (when "(item.state | d(cryptsetup__state) in ['ansible_controller_mounted', 'absent'])")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}")))
    (task "Ensure keyfile is unaccessible on the remote system"
      (ansible.builtin.command (jinja "{{ cryptsetup__keyfile_shred_command }}") " " (jinja "{{ item.stat.path | quote }}"))
      (args 
        (removes (jinja "{{ item.stat.path }}")))
      (when "(item.item.state | d(cryptsetup__state) in ['ansible_controller_mounted', 'absent'] and item.stat.exists and item.stat.isreg)")
      (with_items (jinja "{{ cryptsetup__register_stat_remote_keyfile.results | d([]) }}")))
    (task "Ensure header backup is unaccessible on the remote system"
      (ansible.builtin.command (jinja "{{ cryptsetup__header_backup_shred_command }}") " " (jinja "{{ cryptsetup__header_backup_remote_location + \"/\" + item.name + \"_header_backup.raw\" | quote }}"))
      (args 
        (removes (jinja "{{ cryptsetup__header_backup_remote_location + \"/\" + item.name + \"_header_backup.raw\" }}")))
      (when "((item.state | d(cryptsetup__state) == 'absent' or not (item.backup_header | d(cryptsetup__header_backup) | bool)) and 'remote_keyfile' not in item)")
      (with_items (jinja "{{ cryptsetup__process_devices | d([]) }}"))
      (tags (list
          "role::cryptsetup:backup")))))
