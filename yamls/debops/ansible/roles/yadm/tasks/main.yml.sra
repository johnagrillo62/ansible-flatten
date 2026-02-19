(playbook "debops/ansible/roles/yadm/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", yadm__base_packages
                             + yadm__packages
                             + yadm__group_packages
                             + yadm__host_packages) }}"))
        (state "present"))
      (register "yadm__register_packages")
      (until "yadm__register_packages is succeeded")
      (when "yadm__enabled | bool"))
    (task "Install yadm from upstream"
      (ansible.builtin.include_tasks "upstream_yadm.yml")
      (when "yadm__enabled | bool and yadm__upstream_enabled | bool"))
    (task "Ensure that the /root/.gnupg directory exists"
      (ansible.builtin.file 
        (path "~/.gnupg")
        (state "directory")
        (mode "0700"))
      (when "yadm__enabled | bool and yadm__dotfiles_enabled | bool"))
    (task "Download custom dotfile repositories"
      (ansible.builtin.include_tasks "manage_dotfiles.yml")
      (loop (jinja "{{ q(\"flattened\", yadm__combined_dotfiles) | debops.debops.parse_kv_items }}"))
      (loop_control 
        (loop_var "dotfile")
        (label (jinja "{{ dotfile.name }}")))
      (when "yadm__enabled | bool and yadm__dotfiles_enabled | bool and dotfile.name | d()"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save yadm local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/yadm.fact.j2")
        (dest "/etc/ansible/facts.d/yadm.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
