(playbook "debops/ansible/roles/ansible/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (ansible__base_packages
                              + ansible__packages)) }}"))
        (state "present"))
      (register "ansible__register_packages")
      (until "ansible__register_packages is succeeded"))
    (task "Bootstrap Ansible from source"
      (ansible.builtin.script "script/bootstrap-ansible \"" (jinja "{{ ansible__bootstrap_version }}") "\"")
      (when "(ansible__deploy_type == 'bootstrap' and (ansible_local is undefined or (ansible_local.ansible is undefined or not (ansible_local.ansible.installed | d()) | bool or (ansible_local.ansible.deploy_type | d(ansible__deploy_type) != 'bootstrap'))))"))
    (task "Make sure that Ansible local fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Ansible local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/ansible.fact.j2")
        (dest "/etc/ansible/facts.d/ansible.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
