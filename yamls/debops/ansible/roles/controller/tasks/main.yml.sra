(playbook "debops/ansible/roles/controller/tasks/main.yml"
  (tasks
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (controller__base_packages
                              + controller__packages)) }}"))
        (state "present"))
      (register "controller__register_packages")
      (until "controller__register_packages is succeeded"))
    (task "Install DebOps from PyPI"
      (ansible.builtin.pip 
        (name (jinja "{{ q(\"flattened\", controller__pip_packages) }}"))
        (state "present"))
      (register "controller__register_pip_install")
      (until "controller__register_pip_install is succeeded")
      (notify (jinja "{{ [\"Update DebOps in the background with \" + controller__update_method]
              if not controller__update_method == \"sync\" else omit }}")))
    (task "Configure system-wide DebOps scripts"
      (ansible.builtin.template 
        (src "etc/debops.cfg.j2")
        (dest "/etc/debops.cfg")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "controller__install_systemwide | bool"))
    (task "Update roles and playbooks"
      (ansible.builtin.command "debops-update")
      (become (jinja "{{ controller__install_systemwide | bool }}"))
      (register "controller__register_update")
      (changed_when "controller__register_update.changed | bool")
      (when "controller__update_method == 'sync'"))
    (task "Clone project repository"
      (ansible.builtin.git 
        (repo (jinja "{{ controller__project_git_repo }}"))
        (dest (jinja "{{ controller__project_name if controller__project_name else controller__project_git_repo | basename }}"))
        (version "master")
        (update "True"))
      (become (jinja "{{ controller__install_systemwide | bool }}"))
      (when "controller__project_git_repo | d()"))
    (task "Initialize new project"
      (ansible.builtin.command "debops-init '" (jinja "{{ controller__project_name }}") "'")
      (become (jinja "{{ controller__install_systemwide | bool }}"))
      (args 
        (creates (jinja "{{ controller__project_name }}") "/.debops.cfg"))
      (when "controller__project_name | d() and not controller__project_git_repo | d()"))))
