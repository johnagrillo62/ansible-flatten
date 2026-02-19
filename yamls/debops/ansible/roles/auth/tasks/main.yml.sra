(playbook "debops/ansible/roles/auth/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "DebOps pre_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup('debops.debops.task_src', 'auth/pre_main.yml') }}")))
    (task "Install auth-related packages"
      (ansible.builtin.apt 
        (name (jinja "{{ auth_packages | flatten }}"))
        (state "present")
        (install_recommends "no"))
      (register "auth__register_packages")
      (until "auth__register_packages is succeeded"))
    (task "Configure pam_cracklib"
      (ansible.builtin.template 
        (src "usr/share/pam-configs/cracklib.j2")
        (dest "/usr/share/pam-configs/cracklib")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Update PAM common configuration"))
      (when "auth_cracklib | bool"))
    (task "Configure PAM password history module"
      (ansible.builtin.include_tasks "pam_pwhistory.yml")
      (when "auth_pwhistory_remember is defined and auth_pwhistory_remember"))
    (task "DebOps post_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup('debops.debops.task_src', 'auth/post_main.yml') }}")))))
