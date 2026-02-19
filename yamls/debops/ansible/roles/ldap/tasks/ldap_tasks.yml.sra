(playbook "debops/ansible/roles/ldap/tasks/ldap_tasks.yml"
  (tasks
    (task (jinja "{{ item.name }}")
      (community.general.ldap_entry 
        (dn (jinja "{{ item.dn if (item.dn is string) else item.dn | join(\",\") }}"))
        (objectClass (jinja "{{ item.objectClass | d(omit) }}"))
        (attributes (jinja "{{ item.attributes | d(omit) }}"))
        (state (jinja "{{ item.entry_state | d(item.state) }}"))
        (server_uri (jinja "{{ ldap__admin_server_uri }}"))
        (start_tls (jinja "{{ ldap__start_tls }}"))
        (bind_dn (jinja "{{ ldap__admin_binddn }}"))
        (bind_pw (jinja "{{ ldap__fact_admin_bindpw }}")))
      (become (jinja "{{ ldap__admin_become }}"))
      (become_user (jinja "{{ ldap__admin_become_user if ldap__admin_become_user | d() else omit }}"))
      (delegate_to (jinja "{{ ldap__admin_delegate_to if ldap__admin_delegate_to | d() else omit }}"))
      (run_once (jinja "{{ item.run_once | d(False) }}"))
      (when "(item.objectClass | d() or item.entry_state | d()) and item.state not in ['init', 'ignore']")
      (tags (list
          "role::ldap:tasks"
          "skip::ldap:tasks"))
      (no_log (jinja "{{ debops__no_log | d(item.no_log | d(True
                                 if (\"userPassword\" in (item.attributes | d({})).keys() or
                                     \"olcRootPW\" in (item.attributes | d({})).keys())
                                 else False)) }}")))
    (task (jinja "{{ item.name }}")
      (debops.debops.ldap_attrs 
        (dn (jinja "{{ item.dn if (item.dn is string) else item.dn | join(\",\") }}"))
        (attributes (jinja "{{ item.attributes | d({}) }}"))
        (ordered (jinja "{{ item.ordered | d(False) }}"))
        (state (jinja "{{ item.state }}"))
        (server_uri (jinja "{{ ldap__admin_server_uri }}"))
        (start_tls (jinja "{{ ldap__start_tls }}"))
        (bind_dn (jinja "{{ ldap__admin_binddn }}"))
        (bind_pw (jinja "{{ ldap__fact_admin_bindpw }}")))
      (become (jinja "{{ ldap__admin_become }}"))
      (become_user (jinja "{{ ldap__admin_become_user if ldap__admin_become_user | d() else omit }}"))
      (delegate_to (jinja "{{ ldap__admin_delegate_to if ldap__admin_delegate_to | d() else omit }}"))
      (run_once (jinja "{{ item.run_once | d(False) }}"))
      (when "not item.objectClass | d() and not item.entry_state | d() and item.state not in ['init', 'ignore']")
      (tags (list
          "role::ldap:tasks"
          "skip::ldap:tasks"))
      (no_log (jinja "{{ debops__no_log | d(item.no_log | d(True
                                 if (\"userPassword\" in (item.attributes | d({})).keys() or
                                     \"olcRootPW\" in (item.attributes | d({})).keys())
                                 else False)) }}")))))
