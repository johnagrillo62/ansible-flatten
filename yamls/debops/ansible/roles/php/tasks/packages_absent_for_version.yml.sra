(playbook "debops/ansible/roles/php/tasks/packages_absent_for_version.yml"
  (tasks
    (task "Ensure older PHP packages are absent on reset for given PHP version"
      (ansible.builtin.apt 
        (name (jinja "{{ item is search(\"php.*-\") | ternary(item, php__version_absent + \"-\" + item) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", php__server_api_packages
                           + php__base_packages
                           + php__packages
                           + php__group_packages
                           + php__host_packages
                           + php__dependent_packages) }}")))))
