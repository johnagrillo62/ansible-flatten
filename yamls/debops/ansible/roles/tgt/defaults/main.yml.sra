(playbook "debops/ansible/roles/tgt/defaults/main.yml"
  (tgt_packages (list
      "tgt"))
  (tgt_iqn_date (jinja "{{ ansible_date_time.year + \"-\" + ansible_date_time.month }}"))
  (tgt_iqn_authority (jinja "{{ ansible_domain }}"))
  (tgt_iqn_base (jinja "{{ (ansible_local.tgt.iqn_base
                   if (ansible_local.tgt.iqn_base | d())
                   else (\"iqn.\" + tgt_iqn_date + \".\" +
                         tgt_iqn_authority.split(\".\")[::-1] | join(\".\"))) }}"))
  (tgt_allow (list))
  (tgt_options "")
  (tgt_targets (list))
  (tgt__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "iscsi-target"))
      (saddr (jinja "{{ tgt_allow }}"))
      (accept_any "True")
      (filename "tgt_dependency_accept")
      (weight "50"))))
