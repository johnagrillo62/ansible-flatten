(playbook "debops/ansible/roles/pam_access/defaults/main.yml"
  (pam_access__enabled "True")
  (pam_access__default_rules (list
      
      (name "global")
      (filename "access.conf")
      (divert "True")
      (state "init")
      (options (list))))
  (pam_access__rules (list))
  (pam_access__group_rules (list))
  (pam_access__host_rules (list))
  (pam_access__dependent_rules (list))
  (pam_access__combined_rules (jinja "{{ q(\"flattened\", (pam_access__default_rules
                                                + pam_access__dependent_rules
                                                + pam_access__rules
                                                + pam_access__group_rules
                                                + pam_access__host_rules)) }}")))
