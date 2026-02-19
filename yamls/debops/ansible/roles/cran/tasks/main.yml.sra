(playbook "debops/ansible/roles/cran/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Install system packages required for R support"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (cran__base_packages
                              + cran__packages
                              + cran__group_packages
                              + cran__host_packages
                              + cran__dependent_packages)) }}"))
        (state "present"))
      (register "cran__register_packages")
      (until "cran__register_packages is succeeded"))
    (task "Configure Java environment in R"
      (ansible.builtin.command "R CMD javareconf")
      (register "cran__register_java_reconf")
      (changed_when "cran__register_java_reconf.changed | bool")
      (when "(cran__java_integration | bool and (ansible_local | d() and ansible_local.cran is undefined))"))
    (task "Manage R packages"
      (cran 
        (name (jinja "{{ item.name | d(item) }}"))
        (repo (jinja "{{ item.repo | d(cran__upstream_mirror) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (loop (jinja "{{ q(\"flattened\", cran__r_packages
                           + cran__group_r_packages
                           + cran__host_r_packages
                           + cran__dependent_r_packages) }}")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save CRAN local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/cran.fact.j2")
        (dest "/etc/ansible/facts.d/cran.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
