(playbook "yaml/roles/common/tasks/users.yml"
  (tasks
    (task "Create main user account"
      (user "name=" (jinja "{{ main_user_name }}") " state=present shell=" (jinja "{{ main_user_shell }}") " groups=sudo"))
    (task "Give main user account sudo power"
      (template "src=roles/common/templates/sudoers.j2 dest=/etc/sudoers.d/sudoers owner=root group=root mode=0440 validate='visudo -cf %s'"))))
