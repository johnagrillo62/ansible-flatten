(playbook "debops/ansible/roles/apt_proxy/defaults/main.yml"
  (apt_proxy__base_packages (list
      (jinja "{{ [\"python3-apt\"]
        if (apt_proxy__temporally_avoid_unreachable | bool)
        else [] }}")))
  (apt_proxy__deploy_state (jinja "{{ \"present\"
                             if (apt_proxy__http_url or
                                 apt_proxy__https_url or
                                 apt_proxy__ftp_url)
                             else \"absent\" }}"))
  (apt_proxy__filename "00apt_proxy")
  (apt_proxy__http_url (jinja "{{ ansible_env.http_proxy | d() }}"))
  (apt_proxy__http_direct (list))
  (apt_proxy__http_options )
  (apt_proxy__https_url (jinja "{{ ansible_env.https_proxy | d() }}"))
  (apt_proxy__https_direct (list))
  (apt_proxy__https_options )
  (apt_proxy__ftp_url (jinja "{{ ansible_env.ftp_proxy | d() }}"))
  (apt_proxy__ftp_direct (list))
  (apt_proxy__ftp_login (list
      "USER $(PROXY_USER)"
      "PASS $(PROXY_PASS)"
      "USER $(SITE_USER)@$(SITE):$(SITE_PORT)"
      "PASS $(SITE_PASS)"))
  (apt_proxy__ftp_options )
  (apt_proxy__temporally_avoid_unreachable "False")
  (apt_proxy__proxy_auto_detect (jinja "{{ \"/usr/local/lib/get-reachable-apt-proxy\"
                                  if (apt_proxy__temporally_avoid_unreachable | bool)
                                  else omit }}")))
