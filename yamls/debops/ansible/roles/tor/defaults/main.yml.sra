(playbook "debops/ansible/roles/tor/defaults/main.yml"
  (tor__deploy_state "present")
  (tor__ferm__dependent_rules (list
      
      (type "accept")
      (dport (jinja "{{ ((tor_ports | map(attribute=\"orport\") | list) + (tor_ports | map(attribute=\"dirport\") | list)) | unique | sort }}"))
      (accept_any "True")
      (weight "40")
      (by_role "debops-contrib.tor")
      (name "tor")
      (rule_state (jinja "{{ \"present\" if (tor__deploy_state != \"purged\") else \"absent\" }}"))))
  (tor__unattended_upgrades__dependent_origins (list
      
      (origin "origin=TorProject")
      (by_role "debops-contrib.tor")
      (state (jinja "{{ \"present\"
               if (tor__deploy_state == \"present\")
               else \"absent\" }}")))))
