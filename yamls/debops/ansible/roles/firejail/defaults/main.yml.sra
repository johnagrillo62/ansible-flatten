(playbook "debops/ansible/roles/firejail/defaults/main.yml"
  (firejail__base_packages (list
      "firejail"))
  (firejail__packages (list))
  (firejail__group_packages (list))
  (firejail__host_packages (list))
  (firejail__deploy_state "present")
  (firejail__config_path "/etc/firejail")
  (firejail__program_file_path "auto")
  (firejail__system_local_bin_path (jinja "{{ ansible_local.fhs.bin | d(\"/usr/local/bin\") }}"))
  (firejail__program_sandboxes )
  (firejail__group_program_sandboxes )
  (firejail__host_program_sandboxes )
  (firejail__role_program_sandboxes 
    (default 
      (system_wide_sandboxed "absent"))
    (ssh 
      (system_wide_sandboxed "absent"))
    (tar 
      (system_wide_sandboxed "absent"))
    (unrar 
      (system_wide_sandboxed "absent"))
    (git 
      (system_wide_sandboxed "absent")))
  (firejail__combined_program_sandboxes (jinja "{{
  firejail__role_program_sandboxes
  | combine(firejail__program_sandboxes)
  | combine(firejail__group_program_sandboxes)
  | combine(firejail__host_program_sandboxes) }}"))
  (firejail__global_profiles_system_wide_sandboxed "if_installed")
  (firejail__program_sandboxes_system_wide_sandboxed "if_installed")
  (firejail__fix_for_users (list))
  (firejail__group_fix_for_users (list))
  (firejail__host_fix_for_users (list))
  (firejail__combined_fix_for_users (jinja "{{ (firejail__fix_for_users | list)
                                      + (firejail__group_fix_for_users | list)
                                      + (firejail__host_fix_for_users | list) }}")))
