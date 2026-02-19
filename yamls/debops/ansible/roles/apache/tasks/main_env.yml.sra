(playbook "debops/ansible/roles/apache/tasks/main_env.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Ensure base packages are in there desired state"
      (ansible.builtin.package 
        (name (jinja "{{ item }}"))
        (state (jinja "{{ \"present\" if (apache__deploy_state == \"present\") else \"absent\" }}")))
      (loop (jinja "{{ q(\"flattened\", apache__base_packages) }}"))
      (register "apache__register_base_packages")
      (until "apache__register_base_packages is succeeded")
      (tags (list
          "role::apache:pkgs")))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Create local facts of Apache"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/apache.fact.j2")
        (dest "/etc/ansible/facts.d/apache.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
