(playbook "debops/ansible/roles/dhparam/handlers/main.yml"
  (tasks
    (task "Execute DH parameter hooks"
      (ansible.builtin.command "run-parts " (jinja "{{ dhparam__hook_path }}"))
      (register "dhparam__register_hooks")
      (changed_when "dhparam__register_hooks.changed | bool"))
    (task "Regenerate DH parameters on first install"
      (ansible.posix.at 
        (command "test -x " (jinja "{{ dhparam__generate_params }}") " \\
&& (echo 'nice " (jinja "{{ dhparam__generate_params }}") " run' | batch > /dev/null 2>&1) || true
")
        (count (jinja "{{ dhparam__generate_init_count }}"))
        (units (jinja "{{ dhparam__generate_init_units }}"))
        (unique "True"))
      (when "(dhparam__generate_init | bool and (ansible_local | d() and ansible_local.atd | d() and ansible_local.atd.enabled | bool))"))))
