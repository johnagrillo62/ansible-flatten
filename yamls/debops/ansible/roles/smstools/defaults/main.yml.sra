(playbook "debops/ansible/roles/smstools/defaults/main.yml"
  (smstools_service_allow (list))
  (smstools_mail_transport_subdomain "sms")
  (smstools_mail_alias_subdomain "gsm")
  (smstools_mail_domain (jinja "{{ ansible_domain }}"))
  (smstools_mail_transport_domain (jinja "{{ smstools_mail_transport_subdomain }}") "." (jinja "{{ smstools_mail_domain }}"))
  (smstools_mail_alias_domain (jinja "{{ smstools_mail_alias_subdomain }}") "." (jinja "{{ smstools_mail_domain }}"))
  (smstools_default_country_prefix "")
  (smstools_default_senders (list
      
      (name "root@" (jinja "{{ smstools_mail_domain }}"))))
  (smstools_senders (list))
  (smstools_mail_recipients )
  (smstools_mail_aliases )
  (smstools_mail_msgdel_list (list))
  (smstools_sms_log "/var/log/sms.log")
  (smstools_sms_log_rotation "monthly")
  (smstools_sms_log_rotation_interval (jinja "{{ (12 * 2) }}"))
  (smstools_test_recipients (list))
  (smstools_test_message "This is a test of the SMS gateway on " (jinja "{{ ansible_fqdn }}") " sent at $(date)")
  (smstools_sleep "1")
  (smstools_stats_interval (jinja "{{ (60 * 60 * 24) | round | int }}"))
  (smstools_global_options 
    (delaytime (jinja "{{ smstools_sleep }}"))
    (delaytime_mainprocess (jinja "{{ smstools_sleep }}"))
    (receive_before_send "no")
    (autosplit "3")
    (loglevel "5"))
  (smstools_devices (list
      
      (name "GSM1")
      (device "/dev/ttyS0")
      (options 
        (baudrate "115200")
        (incoming "yes"))))
  (smstools__etc_services__dependent_list (list
      
      (name (jinja "{{ smstools_service_name }}"))
      (port (jinja "{{ smstools_service_port }}"))
      (comment "SMS service")))
  (smstools__tcpwrappers__dependent_allow (list
      
      (daemon (jinja "{{ smstools_service_name }}"))
      (client (jinja "{{ smstools_service_allow }}"))
      (weight "50")
      (filename "smstools_dependency_allow")
      (comment "Allow connections to SMS service")))
  (smstools__ferm__dependent_rules (list
      
      (name "smstools_accept")
      (type "accept")
      (dport (list
          (jinja "{{ smstools_service_name }}")))
      (saddr (jinja "{{ smstools_service_allow }}"))))
  (smstools__postfix__dependent_maincf (list
      
      (name "recipient_canonical_maps")
      (value (list
          "texthash:/usr/local/lib/smstools/postfix_recipient_canonical_map"))
      
      (name "transport_maps")
      (value (list
          "texthash:/usr/local/lib/smstools/postfix_transport"))
      
      (name "relay_domains")
      (value (list
          (jinja "{{ smstools_mail_transport_domain }}")))
      
      (name "relay_recipient_maps")
      (value (list
          "regexp:/usr/local/lib/smstools/postfix_relay_recipient_map"))
      
      (name "virtual_alias_domains")
      (value (list
          (jinja "{{ smstools_mail_alias_domain }}")))
      
      (name "virtual_alias_maps")
      (value (list
          "texthash:/usr/local/lib/smstools/postfix_virtual_alias_map"))
      
      (name "sms_destination_recipient_limit")
      (value "1")))
  (smstools__postfix__dependent_mastercf (list
      
      (name "sms")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      (maxproc "1")
      (args "flags=hqu user=smsd argv=/usr/local/lib/smstools/sms-transport
${sender} ${mailbox}
")
      (command "pipe"))))
