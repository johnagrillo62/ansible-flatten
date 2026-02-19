(playbook "yaml/roles/webmail/defaults/main.yml"
  (webmail_version "1.2.1")
  (webmail_domain "mail." (jinja "{{ domain }}")))
