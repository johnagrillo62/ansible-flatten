(playbook "debops/ansible/roles/x2go_server/docs/inventory/debops_service_x2go_server_global_role_vars.yml"
  (sshd__ciphers_additional (jinja "{{ [ \"aes256-ctr\" ] if (x2go_server__deploy_state | d(\"present\") == \"present\") else [] }}"))
  (sshd__kex_algorithms_additional (jinja "{{ [ \"curve25519-sha256@libssh.org\" ] if (x2go_server__deploy_state | d(\"present\") == \"present\") else [] }}"))
  (sshd__macs_additional (jinja "{{ [ \"hmac-sha1\" ] if (x2go_server__deploy_state | d(\"present\") == \"present\") else [] }}"))
  (sshd__x11_forwarding "yes"))
