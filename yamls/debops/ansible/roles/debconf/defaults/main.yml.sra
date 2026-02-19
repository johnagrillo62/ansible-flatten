(playbook "debops/ansible/roles/debconf/defaults/main.yml"
  (debconf__entries (list))
  (debconf__group_entries (list))
  (debconf__host_entries (list))
  (debconf__combined_entries (jinja "{{ debconf__entries
                                  + debconf__group_entries
                                  + debconf__host_entries }}"))
  (debconf__filtered_entries (jinja "{{ lookup(\"template\",
                                     \"lookup/debconf__filtered_entries.j2\",
                                     convert_data=False) | from_yaml }}"))
  (debconf__cache_valid_time (jinja "{{ (60 * 60) }}"))
  (debconf__apt_state "present")
  (debconf__packages (list))
  (debconf__group_packages (list))
  (debconf__host_packages (list))
  (debconf__alternatives (list))
  (debconf__group_alternatives (list))
  (debconf__host_alternatives (list))
  (debconf__commands (list))
  (debconf__group_commands (list))
  (debconf__host_commands (list))
  (debconf__combined_commands (jinja "{{ debconf__commands
                                   + debconf__group_commands
                                   + debconf__host_commands }}")))
