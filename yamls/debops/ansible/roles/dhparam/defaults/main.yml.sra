(playbook "debops/ansible/roles/dhparam/defaults/main.yml"
  (dhparam__deploy_state "present")
  (dhparam__base_packages (list
      (list
        (jinja "{{ \"gnutls-bin\" if (dhparam__library == \"gnutls\") else [] }}"))
      (list
        (jinja "{{ \"openssl\" if (dhparam__library == \"openssl\") else [] }}"))))
  (dhparam__packages (list))
  (dhparam__source_library "openssl")
  (dhparam__library (jinja "{{ dhparam__source_library }}"))
  (dhparam__default_length (jinja "{{ dhparam__bits[0] }}"))
  (dhparam__bits (list
      "3072"
      "2048"))
  (dhparam__sets "1")
  (dhparam__default_set (jinja "{{ dhparam__set_prefix + \"0\" }}"))
  (dhparam__set_prefix "set")
  (dhparam__source_path (jinja "{{ secret + \"/dhparam/params\" }}"))
  (dhparam__path "/etc/pki/dhparam")
  (dhparam__prefix "dh")
  (dhparam__suffix ".pem")
  (dhparam__generate_params (jinja "{{ (ansible_local.fhs.lib | d(\"/usr/local/lib\"))
                              + \"/dhparam-generate-params\" }}"))
  (dhparam__generate_log "True")
  (dhparam__hook_path (jinja "{{ dhparam__path + \"/hooks.d\" }}"))
  (dhparam__openssl_options "")
  (dhparam__generate_init "True")
  (dhparam__generate_init_units "minutes")
  (dhparam__generate_init_count "20")
  (dhparam__generate_cron "True")
  (dhparam__generate_cron_period "monthly"))
