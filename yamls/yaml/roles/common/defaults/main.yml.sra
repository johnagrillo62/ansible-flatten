(playbook "yaml/roles/common/defaults/main.yml"
  (common_timezone "Etc/UTC")
  (admin_email (jinja "{{ main_user_name }}") "@" (jinja "{{ domain }}"))
  (main_user_shell "/bin/bash")
  (friendly_networks (list
      ""))
  (secret_root (jinja "{{ inventory_dir | realpath }}"))
  (secret_name "secret")
  (secret (jinja "{{ secret_root + \"/\" + secret_name }}"))
  (encfs_password (jinja "{{ lookup('password', secret + '/' + 'encfs_password', length=32) }}"))
  (letsencrypt_server "https://acme-v02.api.letsencrypt.org/directory")
  (kex_algorithms "diffie-hellman-group-exchange-sha256")
  (ciphers "aes256-ctr,aes192-ctr,aes128-ctr")
  (macs "hmac-sha2-512,hmac-sha2-256,hmac-ripemd160")
  (ntp_servers (list
      "0.pool.ntp.org"
      "1.pool.ntp.org"
      "2.pool.ntp.org"
      "3.pool.ntp.org")))
