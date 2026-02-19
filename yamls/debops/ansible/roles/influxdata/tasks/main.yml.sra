(playbook "debops/ansible/roles/influxdata/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Configure InfluxData APT repository"
      (ansible.builtin.apt_repository 
        (repo (jinja "{{ influxdata__repository }}"))
        (state "present")
        (update_cache "True")))
    (task "Install InfluxData packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (influxdata__packages
                              + influxdata__group_packages
                              + influxdata__host_packages
                              + influxdata__dependent_packages)) }}"))
        (state "present"))
      (notify (list
          "Refresh host facts"))
      (register "influxdata__register_install")
      (until "influxdata__register_install is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save InfluxData local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/influxdata.fact.j2")
        (dest "/etc/ansible/facts.d/influxdata.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
