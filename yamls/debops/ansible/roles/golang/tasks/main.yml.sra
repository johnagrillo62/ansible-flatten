(playbook "debops/ansible/roles/golang/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Build and install Go packages"
      (ansible.builtin.include_tasks "golang_build_install.yml")
      (loop_control 
        (loop_var "build"))
      (loop (jinja "{{ q(\"flattened\", golang__combined_packages) | debops.debops.parse_kv_items }}"))
      (when "build.name | d() and build.state | d('present') not in [ 'absent', 'ignore' ]"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Go local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/golang.fact.j2")
        (dest "/etc/ansible/facts.d/golang.fact")
        (mode "0755"))
      (register "golang__register_facts")
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.setup null)
      (when "golang__register_facts is changed"))))
