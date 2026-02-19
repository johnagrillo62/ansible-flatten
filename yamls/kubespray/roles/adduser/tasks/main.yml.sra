(playbook "kubespray/roles/adduser/tasks/main.yml"
  (tasks
    (task "User | Create User Group"
      (group 
        (name (jinja "{{ user.group | default(user.name) }}"))
        (system (jinja "{{ user.system | default(omit) }}"))))
    (task "User | Create User"
      (user 
        (comment (jinja "{{ user.comment | default(omit) }}"))
        (create_home (jinja "{{ user.create_home | default(omit) }}"))
        (group (jinja "{{ user.group | default(user.name) }}"))
        (home (jinja "{{ user.home | default(omit) }}"))
        (shell (jinja "{{ user.shell | default(omit) }}"))
        (name (jinja "{{ user.name }}"))
        (system (jinja "{{ user.system | default(omit) }}")))
      (when "user.name != \"root\""))))
