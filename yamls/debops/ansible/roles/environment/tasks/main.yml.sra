(playbook "debops/ansible/roles/environment/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Configure /etc/environment"
      (ansible.builtin.blockinfile 
        (dest (jinja "{{ environment__file }}"))
        (state (jinja "{{ \"present\" if environment__enabled | bool else \"absent\" }}"))
        (block (jinja "{{ lookup(\"template\", \"lookup/environment__variables.j2\") }}"))
        (insertbefore (jinja "{{ \"BOF\" if environment__placement == \"before\" else omit }}"))
        (insertafter (jinja "{{ \"EOF\" if environment__placement == \"after\" else omit }}"))))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Update Ansible local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/environment.fact.j2")
        (dest "/etc/ansible/facts.d/environment.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
