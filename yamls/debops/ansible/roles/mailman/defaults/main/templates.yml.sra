(playbook "debops/ansible/roles/mailman/defaults/main/templates.yml"
  (mailman__default_templates (list
      
      (name "site/en/list:member:generic:footer.txt")
      (content "")))
  (mailman__templates (list))
  (mailman__group_templates (list))
  (mailman__host_templates (list))
  (mailman__combined_templates (jinja "{{ mailman__default_templates
                                 + mailman__templates
                                 + mailman__group_templates
                                 + mailman__host_templates }}")))
