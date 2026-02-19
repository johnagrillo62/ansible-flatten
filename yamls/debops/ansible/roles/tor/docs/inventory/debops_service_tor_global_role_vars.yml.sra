(playbook "debops/ansible/roles/tor/docs/inventory/debops_service_tor_global_role_vars.yml"
  (tor_offline_masterkey_dir (jinja "{{ secret + \"/tor\" }}"))
  (tor_backup_torrc "False"))
