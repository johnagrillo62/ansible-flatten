(playbook "debops/ansible/roles/auth/defaults/main.yml"
  (auth_packages (list
      (jinja "{{ \"libpam-cracklib\"
        if (ansible_distribution_release in [\"stretch\", \"buster\", \"bullseye\"])
        else [] }}")))
  (auth_pwhistory_remember "5")
  (auth_cracklib (jinja "{{ True
                   if (ansible_distribution_release in [\"stretch\", \"buster\", \"bullseye\"])
                   else False }}")))
