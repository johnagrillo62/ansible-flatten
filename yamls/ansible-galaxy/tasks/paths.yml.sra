(playbook "ansible-galaxy/tasks/paths.yml"
  (tasks
    (task "Manage Paths"
      (block (list
          
          (name "Create galaxy_root")
          (file 
            (path (jinja "{{ galaxy_root }}"))
            (state "directory")
            (owner (jinja "{{ __galaxy_privsep_user_name }}"))
            (group (jinja "{{ __galaxy_privsep_user_group }}"))
            (mode (jinja "{{ __galaxy_dir_perms }}")))
          (when "galaxy_root is defined")
          
          (name "Create additional privilege separated directories")
          (file 
            (path (jinja "{{ item }}"))
            (state "directory")
            (owner (jinja "{{ __galaxy_privsep_user_name }}"))
            (group (jinja "{{ __galaxy_user_group }}"))
            (mode (jinja "{{ __galaxy_dir_perms }}")))
          (loop (jinja "{{ (galaxy_privsep_dirs + galaxy_extra_privsep_dirs) | select | list }}"))
          
          (name "Create additional directories")
          (file 
            (path (jinja "{{ item }}"))
            (state "directory")
            (owner (jinja "{{ __galaxy_user_name }}"))
            (group (jinja "{{ __galaxy_user_group }}"))
            (mode (jinja "{{ __galaxy_dir_perms }}")))
          (loop (jinja "{{ galaxy_dirs + galaxy_extra_dirs }}"))))
      (remote_user (jinja "{{ galaxy_remote_users.root | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.root is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.root | default(__galaxy_become_user) }}")))))
