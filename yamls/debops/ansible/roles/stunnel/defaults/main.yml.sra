(playbook "debops/ansible/roles/stunnel/defaults/main.yml"
  (stunnel_services (list))
  (stunnel_server (list))
  (stunnel_server_addresses (jinja "{{ [ansible_hostname, ansible_fqdn] +
                              ansible_all_ipv4_addresses | d([]) +
                              ansible_all_ipv6_addresses | d([]) +
                              stunnel_server }}"))
  (stunnel_ssl_ciphers "ALL:ECDHE:!SSLv3:!SSLv2:!kEDH:!aNULL:!ADH:!eNULL:!MEDIUM:!LOW:!EXP:!RC4:RSA:HIGH")
  (stunnel_ssl_curve "prime256v1")
  (stunnel_ssl_opts (list
      "NO_SSLv3"))
  (stunnel_ssl_verify "2")
  (stunnel_ssl_check_crl "False")
  (stunnel_pki (jinja "{{ ansible_local.pki.enabled | d() }}"))
  (stunnel_pki_path (jinja "{{ ansible_local.pki.base_path
                      if (ansible_local | d() and ansible_local.pki | d())
                      else \"/etc/pki\" }}"))
  (stunnel_pki_realm (jinja "{{ ansible_local.pki.realm
                       if (ansible_local | d() and ansible_local.pki | d())
                       else \"system\" }}"))
  (stunnel_pki_ca "CA.crt")
  (stunnel_pki_crl "default.crl")
  (stunnel_pki_crt "default.crt")
  (stunnel_pki_key "default.key")
  (stunnel_options "")
  (stunnel_debug "4"))
