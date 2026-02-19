(playbook "debops/ansible/roles/apache/tasks/apache_module_state.yml"
  (tasks
    (task "Enable/disable Apache modules"
      (debops.debops.apache2_module 
        (name (jinja "{{ item.key }}"))
        (state (jinja "{{ (item.value.enabled
                if (item.value is mapping)
                else item.value) | bool | ternary(\"present\", \"absent\") }}"))
        (force (jinja "{{ item.value.force | d(False) | bool }}")))
      (notify (list
          "Test apache and reload"))
      (when "(item.key in apache__tpl_available_modules and item.value.enabled | d(True) != omit and apache__deploy_state == \"present\")")
      (with_dict (jinja "{{ apache__combined_modules }}"))
      (tags (list
          "role::apache:modules")))))
