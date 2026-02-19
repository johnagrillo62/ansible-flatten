(playbook "debops/ansible/roles/elastic_co/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Configure Elastic APT repository"
      (ansible.builtin.apt_repository 
        (update_cache "True")
        (repo (jinja "{{ item.repo }}"))
        (filename (jinja "{{ item.filename | d(omit) }}"))
        (state "present"))
      (with_items (jinja "{{ elastic_co__repositories }}"))
      (when "item.enabled | d(True)"))
    (task "Install Elastic packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (elastic_co__packages
                              + elastic_co__group_packages
                              + elastic_co__host_packages
                              + elastic_co__dependent_packages)) }}"))
        (state "present"))
      (notify (list
          "Refresh host facts"))
      (register "elastic_co__register_install")
      (until "elastic_co__register_install is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Elastic local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/elastic_co.fact.j2")
        (dest "/etc/ansible/facts.d/elastic_co.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
