(playbook "debops/ansible/roles/debops_fact/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Ensure that the private fact group exists"
      (ansible.builtin.group 
        (name (jinja "{{ debops_fact__private_group }}"))
        (system "True")
        (state "present"))
      (when "debops_fact__enabled | bool"))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "debops_fact__enabled | bool"))
    (task "Install local fact script"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/debops_fact.fact.j2")
        (dest "/etc/ansible/facts.d/debops_fact.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (when "debops_fact__enabled | bool"))
    (task "Initialize public DebOps fact file"
      (ansible.builtin.template 
        (src "etc/ansible/debops_fact.ini.j2")
        (dest (jinja "{{ debops_fact__public_path }}"))
        (owner "root")
        (group "root")
        (mode "0644")
        (force "False"))
      (when "debops_fact__enabled | bool"))
    (task "Initialize private DebOps fact file"
      (ansible.builtin.template 
        (src "etc/ansible/debops_fact_priv.ini.j2")
        (dest (jinja "{{ debops_fact__private_path }}"))
        (owner "root")
        (group (jinja "{{ debops_fact__private_group }}"))
        (mode (jinja "{{ debops_fact__private_mode }}"))
        (force "False"))
      (when "debops_fact__enabled | bool"))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
