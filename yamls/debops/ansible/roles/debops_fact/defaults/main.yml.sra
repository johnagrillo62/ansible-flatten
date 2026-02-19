(playbook "debops/ansible/roles/debops_fact/defaults/main.yml"
  (debops_fact__enabled "True")
  (debops_fact__public_path "/etc/ansible/debops_fact.ini")
  (debops_fact__private_path "/etc/ansible/debops_fact_priv.ini")
  (debops_fact__private_group "root")
  (debops_fact__private_mode "0640")
  (debops_fact__config_files (list
      (jinja "{{ debops_fact__public_path }}")
      (jinja "{{ debops_fact__private_path }}")))
  (debops_fact__default_section "default")
  (debops_fact__public_section "global")
  (debops_fact__private_section "secret"))
