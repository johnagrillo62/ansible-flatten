(playbook "debops/ansible/roles/java/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install Java packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (java__base_packages
                              + java__jdk_packages
                              + java__packages
                              + java__group_packages
                              + java__host_packages
                              + java__dependent_packages)) }}"))
        (state "present"))
      (register "java__register_packages")
      (until "java__register_packages is succeeded"))
    (task "Update Java alternatives"
      (ansible.builtin.command "update-java-alternatives -s " (jinja "{{ java__alternatives }}"))
      (register "java__register_update_alternatives")
      (changed_when "java__register_update_alternatives.changed | bool")
      (when "java__alternatives | d()"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Java local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/java.fact.j2")
        (dest "/etc/ansible/facts.d/java.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Divert default Java security policy configuration file"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ java__security_policy_path }}"))
        (state "present")))
    (task "Generate default Java security policy configuration"
      (ansible.builtin.template 
        (src "etc/java-x-openjdk/security/java.policy.j2")
        (dest (jinja "{{ java__security_policy_path }}"))
        (mode "0644")))))
