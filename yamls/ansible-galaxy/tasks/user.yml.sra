(playbook "ansible-galaxy/tasks/user.yml"
  (tasks
    (task "Create users"
      (block (list
          
          (name "Create Galaxy group")
          (group 
            (name (jinja "{{ galaxy_group.name | default(galaxy_group) }}"))
            (gid (jinja "{{ galaxy_group.gid | default(omit) }}"))
            (system (jinja "{{ galaxy_group.system | default(galaxy_user.system) | default('true') }}"))
            (local (jinja "{{ galaxy_group.local | default(galaxy_user.local) | default(omit) }}")))
          (when "galaxy_group is defined")
          
          (name "Create Galaxy user")
          (user 
            (name (jinja "{{ galaxy_user.name | default(galaxy_user) }}"))
            (uid (jinja "{{ galaxy_user.uid | default(omit) }}"))
            (group (jinja "{{ (galaxy_group | default({})).name | default(galaxy_group) | default(omit) }}"))
            (comment (jinja "{{ galaxy_user.comment | default('Galaxy server') }}"))
            (create_home (jinja "{{ galaxy_user.create_home | default('true') }}"))
            (home (jinja "{{ galaxy_user.home | default(omit) }}"))
            (shell (jinja "{{ galaxy_user.shell | default(omit) }}"))
            (system (jinja "{{ galaxy_user.system | default('true') }}"))
            (local (jinja "{{ galaxy_user.local | default(omit) }}")))
          (when "galaxy_create_user")
          
          (name "Create Galaxy privilege separation user")
          (user 
            (name (jinja "{{ galaxy_privsep_user.name | default(galaxy_privsep_user) }}"))
            (uid (jinja "{{ galaxy_privsep_user.uid | default(omit) }}"))
            (group (jinja "{{ (galaxy_group | default({})).name | default(galaxy_group) | default(omit) }}"))
            (comment (jinja "{{ galaxy_privsep_user.comment | default('Galaxy server privilege separation') }}"))
            (create_home (jinja "{{ galaxy_privsep_user.create_home | default('true') }}"))
            (home (jinja "{{ galaxy_privsep_user.home | default(omit) }}"))
            (shell (jinja "{{ galaxy_privsep_user.shell | default(omit) }}"))
            (system (jinja "{{ galaxy_privsep_user.system | default('true') }}"))
            (local (jinja "{{ galaxy_privsep_user.local | default(omit) }}")))
          (when "galaxy_create_privsep_user")))
      (remote_user (jinja "{{ galaxy_remote_users.root | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.root is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.root | default(__galaxy_become_user) }}")))))
