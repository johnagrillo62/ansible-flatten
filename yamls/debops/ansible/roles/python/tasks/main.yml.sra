(playbook "debops/ansible/roles/python/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Make sure that Ansible local fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Python local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/python.fact.j2")
        (dest "/etc/ansible/facts.d/python.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Install requested packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", python__combined_packages) }}"))
        (state "present"))
      (register "python__register_packages")
      (until "python__register_packages is succeeded")
      (when "python__enabled | bool"))
    (task "Generate pip configuration"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/pip.conf.j2\") }}"))
        (dest "/etc/pip.conf")
        (mode "0644")))
    (task "Update the role status in local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/python.fact.j2")
        (dest "/etc/ansible/facts.d/python.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (when "(python__enabled | bool and ansible_local | d() and ansible_local.python | d() and not ansible_local.python.configured | bool)"))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
