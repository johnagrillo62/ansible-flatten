(playbook "yaml/roles/xmpp/defaults/main.yml"
  (prosody_admin (jinja "{{ admin_email }}"))
  (prosody_virtual_domain (jinja "{{ domain }}"))
  (prosody_accounts (list)))
