(playbook "yaml/roles/owncloud/defaults/main.yml"
  (secret_root (jinja "{{ inventory_dir | realpath }}"))
  (secret_name "secret")
  (secret (jinja "{{ secret_root + \"/\" + secret_name }}"))
  (owncloud_domain "cloud." (jinja "{{ domain }}"))
  (owncloud_db_username "owncloud")
  (owncloud_db_password (jinja "{{ lookup('password', secret + '/' + 'owncloud_db_password', length=32) }}"))
  (owncloud_db_database "owncloud"))
