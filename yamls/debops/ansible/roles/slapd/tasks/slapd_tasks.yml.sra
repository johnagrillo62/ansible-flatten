(playbook "debops/ansible/roles/slapd/tasks/slapd_tasks.yml"
  (tasks
    (task (jinja "{{ item.name }}")
      (community.general.ldap_entry 
        (dn (jinja "{{ item.dn if (item.dn is string) else item.dn | join(\",\") }}"))
        (objectClass (jinja "{{ item.objectClass | d(omit) }}"))
        (attributes (jinja "{{ item.attributes | d(omit) }}"))
        (state (jinja "{{ item.entry_state | d(item.state) }}")))
      (run_once (jinja "{{ item.run_once | d(False) }}"))
      (when "(item.objectClass | d() or item.entry_state | d()) and item.state not in ['init', 'ignore']")
      (tags (list
          "role::slapd:tasks"
          "role::slapd:slapacl"))
      (no_log (jinja "{{ debops__no_log | d(item.no_log)
              | d(True
                  if (\"userPassword\" in (item.attributes | d({})).keys() or
                      \"olcRootPW\" in (item.attributes | d({})).keys())
                  else False) }}")))
    (task (jinja "{{ item.name }}")
      (community.general.ldap_attrs 
        (dn (jinja "{{ item.dn if (item.dn is string) else item.dn | join(\",\") }}"))
        (attributes (jinja "{{ item.attributes | d({}) }}"))
        (ordered (jinja "{{ item.ordered | d(False) }}"))
        (state (jinja "{{ item.state }}")))
      (run_once (jinja "{{ item.run_once | d(False) }}"))
      (when "not item.objectClass | d() and not item.entry_state | d() and item.state not in ['init', 'ignore']")
      (tags (list
          "role::slapd:tasks"
          "role::slapd:slapacl"))
      (no_log (jinja "{{ debops__no_log | d(item.no_log)
              | d(True
                  if (\"userPassword\" in (item.attributes | d({})).keys() or
                      \"olcRootPW\" in (item.attributes | d({})).keys())
                  else False) }}")))))
