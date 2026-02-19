(playbook "debops/ansible/roles/rspamd/tasks/main_cfgdir.yml"
  (tasks
    (task "Create directory " (jinja "{{ cfgdir.path }}")
      (ansible.builtin.file 
        (path (jinja "{{ cfgdir.path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Create configuration snippets in " (jinja "{{ cfgdir.path }}")
      (ansible.builtin.template 
        (src "etc/rspamd/snippet.j2")
        (dest (jinja "{{ cfgdir.path + \"/\" + item.file }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"_rspamd\") }}"))
        (mode (jinja "{{ item.mode | d(\"0640\") }}")))
      (loop (jinja "{{ cfgdir.config
             | rejectattr(\"state\", \"in\", [\"absent\", \"init\", \"ignore\"]) }}"))
      (loop_control 
        (label (jinja "{{ item.file }}")))
      (notify (list
          "Restart rspamd")))
    (task "Generate a list of created configuration snippets in " (jinja "{{ cfgdir.path }}")
      (ansible.builtin.set_fact 
        (rspamd__created_snippets (jinja "{{
      cfgdir.config
       | rejectattr(\"state\", \"in\", [\"absent\", \"init\"])
       | map(attribute=\"file\")
       | map(\"regex_replace\", \"^\", cfgdir.path + \"/\") }}"))))
    (task "Find all configuration snippets in " (jinja "{{ cfgdir.path }}")
      (ansible.builtin.find 
        (paths (jinja "{{ cfgdir.path }}"))
        (recurse "no")
        (file_type "file"))
      (register "rspamd__found_snippets"))
    (task "Remove superfluous configuration snippets from " (jinja "{{ cfgdir.path }}")
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (loop (jinja "{{ rspamd__found_snippets.files
             | map(attribute=\"path\")
             | list
             | difference(rspamd__created_snippets) }}"))
      (notify (list
          "Restart rspamd")))))
