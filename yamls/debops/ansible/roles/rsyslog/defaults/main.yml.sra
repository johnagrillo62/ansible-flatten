(playbook "debops/ansible/roles/rsyslog/defaults/main.yml"
  (rsyslog__enabled "True")
  (rsyslog__deploy_state "present")
  (rsyslog__unprivileged (jinja "{{ \"True\"
                           if (ansible_distribution in [\"Ubuntu\"])
                           else \"False\" }}"))
  (rsyslog__remote_enabled (jinja "{{ True
                             if (rsyslog__allow
                                 + rsyslog__group_allow
                                 + rsyslog__host_allow)
                             else False }}"))
  (rsyslog__forward_enabled (jinja "{{ True
                              if q(\"flattened\", (rsyslog__default_forward
                                                 + rsyslog__forward
                                                 + rsyslog__group_forward
                                                 + rsyslog__host_forward))
                              else False }}"))
  (rsyslog__base_packages (list
      "rsyslog"))
  (rsyslog__tls_packages (list
      "rsyslog-gnutls"))
  (rsyslog__packages (list))
  (rsyslog__user (jinja "{{ \"syslog\" if rsyslog__unprivileged | bool else \"root\" }}"))
  (rsyslog__group (jinja "{{ \"syslog\" if rsyslog__unprivileged | bool else \"root\" }}"))
  (rsyslog__append_groups (jinja "{{ [\"ssl-cert\"] if (rsyslog__unprivileged | bool
				and rsyslog__pki | bool) else [] }}"))
  (rsyslog__home (jinja "{{ \"/home/syslog\"
                   if (ansible_distribution in [\"Ubuntu\"])
                   else \"/var/log\" }}"))
  (rsyslog__file_owner (jinja "{{ rsyslog__user }}"))
  (rsyslog__file_group "adm")
  (rsyslog__default_logfiles (list
      "/var/log/syslog"
      "/var/log/kern.log"
      "/var/log/auth.log"
      "/var/log/user.log"
      "/var/log/daemon.log"
      "/var/log/messages"
      "/var/log/mail.log"
      "/var/log/mail.info"
      "/var/log/mail.warn"
      "/var/log/mail.err"
      "/var/log/cron.log"
      "/var/log/lpr.log"
      "/var/log/debug"))
  (rsyslog__logfiles (list))
  (rsyslog__pki (jinja "{{ ansible_local.pki.enabled | d() | bool }}"))
  (rsyslog__pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki\") }}"))
  (rsyslog__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (rsyslog__pki_ca (jinja "{{ ansible_local.pki.ca | d(\"CA.crt\") }}"))
  (rsyslog__pki_crt (jinja "{{ ansible_local.pki.crt | d(\"default.crt\") }}"))
  (rsyslog__pki_key (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (rsyslog__default_netstream_driver (jinja "{{ \"gtls\"
                                       if rsyslog__pki | bool
                                       else \"ptcp\" }}"))
  (rsyslog__default_driver_mode (jinja "{{ \"1\"
                                  if rsyslog__default_netstream_driver == \"gtls\"
                                  else \"0\" }}"))
  (rsyslog__default_driver_authmode (jinja "{{ \"x509/name\"
                                      if rsyslog__default_netstream_driver == \"gtls\" and
                                         rsyslog__default_driver_mode == \"1\"
                                      else \"anon\" }}"))
  (rsyslog__domain (jinja "{{ ansible_domain }}"))
  (rsyslog__permitted_peers (list
      "*." (jinja "{{ rsyslog__domain }}")))
  (rsyslog__send_permitted_peers (jinja "{{ rsyslog__permitted_peers | first }}"))
  (rsyslog__allow (list))
  (rsyslog__group_allow (list))
  (rsyslog__host_allow (list))
  (rsyslog__syslog_srv_rr (jinja "{{ q(\"debops.debops.dig_srv\", \"_syslog._tcp.\" + rsyslog__domain,
                              \"syslog.\" + rsyslog__domain, 6514) }}"))
  (rsyslog__default_forward (jinja "{{ rsyslog__syslog_srv_rr
                              if (rsyslog__syslog_srv_rr[0][\"dig_srv_src\"] | d(\"\") != \"fallback\" and
                                  not rsyslog__remote_enabled | bool and
                                  rsyslog__pki | bool)
                              else [] }}"))
  (rsyslog__forward (list))
  (rsyslog__group_forward (list))
  (rsyslog__host_forward (list))
  (rsyslog__original_configuration (list
      
      (name "module_imuxsock")
      (comment "Provides support for local system logging")
      (raw "module(load=\"imuxsock\")
")
      (state "present")
      (section "modules")
      
      (name "module_imklog")
      (comment "Provides kernel logging support")
      (raw "module(load=\"imklog\")
")
      (state "present")
      (section "modules")
      
      (name "module_immark")
      (comment "Provides --MARK-- message capability")
      (raw "module(load=\"immark\")
")
      (state "comment")
      (section "modules")
      
      (name "module_imudp")
      (comment "Provides UDP syslog reception")
      (raw "module(load=\"imudp\")
input(type=\"imudp\" port=\"514\")
")
      (state "comment")
      (section "modules")
      
      (name "module_imtcp")
      (comment "Provides TCP syslog reception")
      (raw "module(load=\"imtcp\")
input(type=\"imtcp\" port=\"514\")
")
      (state "comment")
      (section "modules")
      
      (name "default_template")
      (comment "Use traditional timestamp format.
To enable high precision timestamps, comment out the following line.
")
      (raw "$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
")
      (state "present")
      (section "global")
      
      (name "default_permissions")
      (comment "Set the default permissions for all log files.")
      (raw "$FileOwner root
$FileGroup adm
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022
")
      (state "present")
      (section "global")
      
      (name "spool_state")
      (comment "Where to place spool and state files")
      (raw "$WorkDirectory /var/spool/rsyslog
")
      (state "present")
      (section "global")
      
      (name "include_config")
      (comment "Include all config files in /etc/rsyslog.d/")
      (raw "$IncludeConfig /etc/rsyslog.d/*.conf
")
      (state "present")
      (section "global")
      
      (name "auth_facility")
      (comment "First some standard log files.  Log by facility.")
      (raw "auth,authpriv.*			/var/log/auth.log
*.*;auth,authpriv.none		-/var/log/syslog
")
      (state "present")
      (section "rules")
      
      (name "cron_facility")
      (raw "cron.*				/var/log/cron.log
")
      (state "comment")
      (section "rules")
      
      (name "daemon_facility")
      (raw "daemon.*			-/var/log/daemon.log
")
      (state "present")
      (section "rules")
      
      (name "kern_facility")
      (raw "kern.*				-/var/log/kern.log
")
      (state "present")
      (section "rules")
      
      (name "lpr_facility")
      (raw "lpr.*				-/var/log/lpr.log
")
      (state "present")
      (section "rules")
      
      (name "mail_facility")
      (raw "mail.*				-/var/log/mail.log
")
      (state "present")
      (section "rules")
      
      (name "user_facility")
      (raw "user.*				-/var/log/user.log
")
      (state "present")
      (section "rules")
      
      (name "mail_log")
      (comment "Logging for the mail system.  Split it up so that
it is easy to write scripts to parse these files.
")
      (raw "mail.info			-/var/log/mail.info
mail.warn			-/var/log/mail.warn
mail.err			/var/log/mail.err
")
      (state "present")
      (section "rules")
      
      (name "debug_log")
      (comment "Some \"catch-all\" log files.")
      (raw "*.=debug;\\
	auth,authpriv.none;\\
	news.none;mail.none	-/var/log/debug
")
      (state "present")
      (section "rules")
      
      (name "messages")
      (raw "*.=info;*.=notice;*.=warn;\\
	auth,authpriv.none;\\
	cron,daemon.none;\\
	mail,news.none		-/var/log/messages
")
      (state "present")
      (section "rules")
      
      (name "emergencies")
      (comment "Emergencies are sent to everybody logged in.")
      (raw "*.emerg				:omusrmsg:*
")
      (state "present")
      (section "rules")))
  (rsyslog__default_configuration (list
      
      (name "module_imklog")
      (state (jinja "{{ \"comment\"
               if (ansible_virtualization_type in [\"lxc\", \"docker\", \"openvz\"])
               else \"ignore\" }}"))
      
      (name "module_imudp")
      (raw "module(load=\"imudp\")
input(type=\"imudp\" port=\"514\" ruleset=\"remote\")
")
      (state (jinja "{{ \"present\" if rsyslog__remote_enabled | bool else \"comment\" }}"))
      
      (name "include_modules")
      (comment "Include *.input files in /etc/rsyslog.d/")
      (raw "$IncludeConfig /etc/rsyslog.d/*.input
")
      (state "present")
      (section "modules")
      
      (name "default_permissions")
      (raw "$FileOwner " (jinja "{{ rsyslog__file_owner }}") "
$FileGroup " (jinja "{{ rsyslog__file_group }}") "
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022
" (jinja "{% if rsyslog__unprivileged | bool %}") "
$PrivDropToUser " (jinja "{{ rsyslog__user }}") "
$PrivDropToGroup " (jinja "{{ rsyslog__group }}") "
" (jinja "{% endif %}") "
")
      (state "present")
      
      (name "cron_facility")
      (state "present")
      
      (name "include_templates")
      (comment "Include *.template files in /etc/rsyslog.d/")
      (raw "$IncludeConfig /etc/rsyslog.d/*.template
")
      (state "present")
      (section "global")
      (copy_id_from "default_template")
      
      (name "include_outputs")
      (comment "Include *.output files in /etc/rsyslog.d/")
      (raw "$IncludeConfig /etc/rsyslog.d/*.output
")
      (state "present")
      (section "global")
      
      (name "include_rules")
      (comment "Include *.ruleset files in /etc/rsyslog.d/")
      (raw "$IncludeConfig /etc/rsyslog.d/*.ruleset
")
      (state "present")
      (section "rules")
      
      (name "include_remote_rules")
      (comment "Include *.remote files in /etc/rsyslog.d/")
      (raw "ruleset(name=\"remote\") {
  $IncludeConfig /etc/rsyslog.d/*.remote
}
")
      (section "rules")
      (state (jinja "{{ \"present\" if rsyslog__remote_enabled | bool else \"absent\" }}"))))
  (rsyslog__configuration (list))
  (rsyslog__group_configuration (list))
  (rsyslog__host_configuration (list))
  (rsyslog__combined_configuration (jinja "{{ rsyslog__original_configuration
                                     + rsyslog__default_configuration
                                     + rsyslog__configuration
                                     + rsyslog__group_configuration
                                     + rsyslog__host_configuration }}"))
  (rsyslog__default_configuration_sections (list
      
      (name "modules")
      
      (name "global")
      (title "Global directives")
      
      (name "templates")
      (state "hidden")
      
      (name "output")
      (title "Output channels")
      (state "hidden")
      
      (name "rules")
      
      (name "unknown")
      (title "Other options")))
  (rsyslog__configuration_sections (list))
  (rsyslog__combined_configuration_sections (jinja "{{ rsyslog__default_configuration_sections
                                              + rsyslog__configuration_sections }}"))
  (rsyslog__default_rules (list
      
      (name "00forward-logs.conf")
      (state (jinja "{{ \"present\"
               if (rsyslog__forward_enabled | bool and
                   rsyslog__pki | bool)
               else \"absent\" }}"))
      (options (list
          
          (name "forward_logs_to_hosts")
          (comment "Forward logs to specified hosts")
          (raw (jinja "{% for element in q(\"flattened\", (rsyslog__default_forward
                                  + rsyslog__forward
                                  + rsyslog__group_forward
                                  + rsyslog__host_forward)) %}") "
" (jinja "{{ element.selector | d(\"*.*\") }}") " action(
      type=\"omfwd\"
      target=\"" (jinja "{{ (element.target | d(element)) | regex_replace(\"\\.$\", \"\") }}") "\"
      port=\"" (jinja "{{ element.port | d('6514') }}") "\"
      protocol=\"" (jinja "{{ element.protocol | d('tcp') }}") "\"
      queue.type=\"" (jinja "{{ element.queue_type | d('linkedList') }}") "\"
      queue.size=\"" (jinja "{{ element.queue_size | d('10000') }}") "\"
      action.resumeRetryCount=\"" (jinja "{{ element.resume_retry_count | d('100') }}") "\"
      streamDriver=\"" (jinja "{{ element.netstream_driver | d(rsyslog__default_netstream_driver) }}") "\"
      streamDriverMode=\"" (jinja "{{ element.driver_mode | d(rsyslog__default_driver_mode) }}") "\"
      streamDriverAuthMode=\"" (jinja "{{ element.driver_authmode | d(rsyslog__default_driver_authmode) }}") "\"
" (jinja "{% if element.driver_authmode | d(rsyslog__default_driver_authmode) != \"anon\" %}") "
" (jinja "{% if rsyslog__send_permitted_peers is string %}") "
      streamDriverPermittedPeers=\"" (jinja "{{ rsyslog__send_permitted_peers }}") "\"
" (jinja "{% else %}") "
      streamDriverPermittedPeers=\"" (jinja "{{ rsyslog__send_permitted_peers | first }}") "\"
" (jinja "{% endif %}") "
" (jinja "{% endif %}") "
    )
" (jinja "{% endfor %}"))
          (state "present")))
      
      (name "cron-session.conf")
      (comment "Redirect PAM session information for 'cron' entries to the cron log file,
to avoid filling up auth.log
")
      (raw "if ($msg contains \"pam_unix(cron:session): session opened for user\") then {
  action(
    type=\"omfile\"
    file=\"/var/log/cron.log\"
    fileOwner=\"" (jinja "{{ rsyslog__file_owner }}") "\"
    fileGroup=\"" (jinja "{{ rsyslog__file_group }}") "\"
    fileCreateMode=\"0640\"
    dirCreateMode=\"0755\"
  )
" (jinja "{% if rsyslog__remote_enabled | bool %}") "
  action(
    type=\"omfile\"
    dynaFile=\"RemoteHostCronLog\"
    fileOwner=\"" (jinja "{{ rsyslog__file_owner }}") "\"
    fileGroup=\"" (jinja "{{ rsyslog__file_group }}") "\"
    fileCreateMode=\"0640\"
    dirCreateMode=\"0755\"
  )
  action(
    type=\"omfile\"
    dynaFile=\"RemoteServiceCronLog\"
    fileOwner=\"" (jinja "{{ rsyslog__file_owner }}") "\"
    fileGroup=\"" (jinja "{{ rsyslog__file_group }}") "\"
    fileCreateMode=\"0640\"
    dirCreateMode=\"0755\"
  )
" (jinja "{% endif %}") "
  stop
} else if ($msg contains \"pam_unix(cron:session): session closed for user\") then {
  action(
    type=\"omfile\"
    file=\"/var/log/cron.log\"
    fileOwner=\"" (jinja "{{ rsyslog__file_owner }}") "\"
    fileGroup=\"" (jinja "{{ rsyslog__file_group }}") "\"
    fileCreateMode=\"0640\"
    dirCreateMode=\"0755\"
  )
" (jinja "{% if rsyslog__remote_enabled | bool %}") "
  action(
    type=\"omfile\"
    dynaFile=\"RemoteHostCronLog\"
    fileOwner=\"" (jinja "{{ rsyslog__file_owner }}") "\"
    fileGroup=\"" (jinja "{{ rsyslog__file_group }}") "\"
    fileCreateMode=\"0640\"
    dirCreateMode=\"0755\"
  )
  action(
    type=\"omfile\"
    dynaFile=\"RemoteServiceCronLog\"
    fileOwner=\"" (jinja "{{ rsyslog__file_owner }}") "\"
    fileGroup=\"" (jinja "{{ rsyslog__file_group }}") "\"
    fileCreateMode=\"0640\"
    dirCreateMode=\"0755\"
  )
" (jinja "{% endif %}") "
  stop
}
")
      (state "present")
      
      (name "network.conf")
      (comment "Network and TLS configuration options")
      (raw "global(
  defaultNetstreamDriver=\"" (jinja "{{ rsyslog__default_netstream_driver }}") "\"
" (jinja "{% if rsyslog__pki | bool %}") "
  defaultNetstreamDriverCAFile=\"" (jinja "{{ rsyslog__pki_path + '/' + rsyslog__pki_realm + '/' + rsyslog__pki_ca }}") "\"
  defaultNetstreamDriverCertFile=\"" (jinja "{{ rsyslog__pki_path + '/' + rsyslog__pki_realm + '/' + rsyslog__pki_crt }}") "\"
  defaultNetstreamDriverKeyFile=\"" (jinja "{{ rsyslog__pki_path + '/' + rsyslog__pki_realm + '/' + rsyslog__pki_key }}") "\"
" (jinja "{% endif %}") "
)")
      (state (jinja "{{ \"present\"
               if (rsyslog__remote_enabled | bool or
                   rsyslog__forward_enabled | bool)
               else \"absent\" }}"))
      
      (name "remote.input")
      (state (jinja "{{ \"present\"
               if rsyslog__remote_enabled | bool
               else \"absent\" }}"))
      (options (list
          
          (name "tcp_plain_module")
          (comment "Enable plain TCP support")
          (raw "module(
  load=\"imptcp\"
)")
          (state "present")
          
          (name "tcp_tls_module")
          (comment "Enable GnuTLS TCP support")
          (raw "module(
  load=\"imtcp\"
  streamDriver.name=\"gtls\"
  streamDriver.mode=\"1\"
  streamDriver.authMode=\"" (jinja "{{ rsyslog__default_driver_authmode }}") "\"
" (jinja "{% if rsyslog__default_driver_authmode != \"anon\" %}") "
" (jinja "{% if rsyslog__permitted_peers is string %}") "
  permittedPeer=\"" (jinja "{{ rsyslog__permitted_peers }}") "\"
" (jinja "{% else %}") "
  permittedPeer=[\"" (jinja "{{ rsyslog__permitted_peers | join('\",\"') }}") "\"]
" (jinja "{% endif %}") "
" (jinja "{% endif %}") "
)")
          (state (jinja "{{ \"present\" if rsyslog__pki | bool else \"absent\" }}"))
          
          (name "tcp_plain_input")
          (comment "Enable plain TCP input")
          (raw "input(
    type=\"imptcp\"
    port=\"514\"
    ruleset=\"remote\"
)")
          (state "present")
          
          (name "tcp_tls_input")
          (comment "Enable GnuTLS TCP input")
          (raw "input(
  type=\"imtcp\"
  port=\"6514\"
  ruleset=\"remote\"
)")
          (state (jinja "{{ \"present\" if rsyslog__pki | bool else \"absent\" }}"))))
      
      (name "20-ufw.conf")
      (divert "True")
      (divert_to "65-ufw.conf")
      (state (jinja "{{ rsyslog__deploy_state
               if (ansible_distribution in [\"Ubuntu\"])
               else \"ignore\" }}"))
      
      (name "50-default.conf")
      (divert "True")
      (state (jinja "{{ \"present\"
               if (ansible_distribution in [\"Ubuntu\"])
               else \"absent\" }}"))
      
      (name "remote.template")
      (state (jinja "{{ \"present\" if rsyslog__remote_enabled | bool else \"absent\" }}"))
      (options (list
          
          (name "remote_host_syslog")
          (comment "Remote host system logs")
          (raw "template(
  name=\"RemoteHostSyslog\"
  type=\"string\"
  string=\"/var/log/remote/hosts/%HOSTNAME%/syslog\"
)")
          (state "present")
          
          (name "remote_host_auth_log")
          (comment "Remote host auth logs")
          (raw "template(
  name=\"RemoteHostAuthLog\"
  type=\"string\"
  string=\"/var/log/remote/hosts/%HOSTNAME%/auth.log\"
)")
          (state "present")
          
          (name "remote_host_cron_log")
          (comment "Remote host cron logs")
          (raw "template(
  name=\"RemoteHostCronLog\"
  type=\"string\"
  string=\"/var/log/remote/hosts/%HOSTNAME%/cron.log\"
)")
          (state "present")
          
          (name "remote_service_auth_log")
          (comment "Remote service auth logs")
          (raw "template(
  name=\"RemoteServiceAuthLog\"
  type=\"string\"
  string=\"/var/log/remote/services/auth/auth.log\"
)")
          (state "present")
          
          (name "remote_service_cron_log")
          (comment "Remote service cron logs")
          (raw "template(
  name=\"RemoteServiceCronLog\"
  type=\"string\"
  string=\"/var/log/remote/services/cron/cron.log\"
)")
          (state "present")
          
          (name "remote_service_mail_log")
          (comment "Remote service mail logs")
          (raw "template(
  name=\"RemoteServiceMailLog\"
  type=\"string\"
  string=\"/var/log/remote/services/mail/mail.log\"
)")
          (state "present")))
      
      (name "local-as-remote.ruleset")
      (state (jinja "{{ \"present\" if rsyslog__remote_enabled | bool else \"absent\" }}"))
      (options (list
          
          (name "remote_log_copy")
          (comment "Copy of the local log files to complete remote logs")
          (raw "auth,authpriv.*                ?RemoteHostAuthLog
auth,authpriv.*                ?RemoteServiceAuthLog
*.*;cron,auth,authpriv.none    -?RemoteHostSyslog
cron.*                         -?RemoteHostCronLog
cron.*                         -?RemoteServiceCronLog
mail.*                         -?RemoteServiceMailLog")
          (state "present")))
      
      (name "cron-session.remote")
      (raw "if ($msg contains \"pam_unix(cron:session): session opened for user\") then {
  action(
    type=\"omfile\"
    dynaFile=\"RemoteHostCronLog\"
    fileOwner=\"" (jinja "{{ rsyslog__file_owner }}") "\"
    fileGroup=\"" (jinja "{{ rsyslog__file_group }}") "\"
    fileCreateMode=\"0640\"
    dirCreateMode=\"0755\"
  )
  action(
    type=\"omfile\"
    dynaFile=\"RemoteServiceCronLog\"
    fileOwner=\"" (jinja "{{ rsyslog__file_owner }}") "\"
    fileGroup=\"" (jinja "{{ rsyslog__file_group }}") "\"
    fileCreateMode=\"0640\"
    dirCreateMode=\"0755\"
  )
  stop
} else if ($msg contains \"pam_unix(cron:session): session closed for user\") then {
  action(
    type=\"omfile\"
    dynaFile=\"RemoteHostCronLog\"
    fileOwner=\"" (jinja "{{ rsyslog__file_owner }}") "\"
    fileGroup=\"" (jinja "{{ rsyslog__file_group }}") "\"
    fileCreateMode=\"0640\"
    dirCreateMode=\"0755\"
  )
  action(
    type=\"omfile\"
    dynaFile=\"RemoteServiceCronLog\"
    fileOwner=\"" (jinja "{{ rsyslog__file_owner }}") "\"
    fileGroup=\"" (jinja "{{ rsyslog__file_group }}") "\"
    fileCreateMode=\"0640\"
    dirCreateMode=\"0755\"
  )
  stop
}
")
      (state (jinja "{{ \"present\" if rsyslog__remote_enabled | bool else \"absent\" }}"))
      
      (name "50-dynamic-logs.remote")
      (state "absent")
      
      (name "ruleset.remote")
      (comment "Store remote logs in separate logfiles")
      (raw "auth,authpriv.*                     ?RemoteHostAuthLog
auth,authpriv.*                     ?RemoteServiceAuthLog
*.*;cron,auth,authpriv.none         -?RemoteHostSyslog
cron.*                              -?RemoteHostCronLog
cron.*                              -?RemoteServiceCronLog
mail.*                              -?RemoteServiceMailLog")
      (state (jinja "{{ \"present\" if rsyslog__remote_enabled | bool else \"absent\" }}"))
      
      (name "zz-stop.remote")
      (comment "This is a workaround to support empty \"remote\" ruleset on
older versions of rsyslog package.
http://comments.gmane.org/gmane.comp.sysutils.rsyslog/15616")
      (raw "stop")
      (state (jinja "{{ \"present\" if rsyslog__remote_enabled | bool else \"absent\" }}"))))
  (rsyslog__legacy_rules (list
      
      (name "00-global.conf")
      (state "absent")
      
      (name "05-common-defaults.conf")
      (state "absent")
      
      (name "10-local-modules.conf")
      (state "absent")
      
      (name "20-templates.conf")
      (state "absent")
      
      (name "40-cron.system")
      (state "absent")
      
      (name "50-default-rulesets.conf")
      (state "absent")
      
      (name "50-default.system")
      (state "absent")))
  (rsyslog__rules (list))
  (rsyslog__group_rules (list))
  (rsyslog__host_rules (list))
  (rsyslog__dependent_rules (list))
  (rsyslog__combined_rules (jinja "{{ rsyslog__default_rules
                             + rsyslog__legacy_rules
                             + rsyslog__rules
                             + rsyslog__group_rules
                             + rsyslog__host_rules
                             + rsyslog__dependent_rules }}"))
  (rsyslog__rotation_period_system "weekly")
  (rsyslog__rotation_count_system "8")
  (rsyslog__rotation_period_remote "weekly")
  (rsyslog__rotation_count_remote "52")
  (rsyslog__ferm__dependent_rules (list
      
      (name "syslog_udp_tcp")
      (type "accept")
      (dport (list
          "514"))
      (protocols (list
          "udp"
          "tcp"))
      (saddr (jinja "{{ rsyslog__allow + rsyslog__group_allow + rsyslog__host_allow }}"))
      (role "rsyslog")
      (accept_any "False")
      (rule_state (jinja "{{ \"present\"
                    if (rsyslog__enabled | bool and rsyslog__deploy_state != \"absent\" and
                        rsyslog__remote_enabled | bool)
                    else \"absent\" }}"))
      
      (name "syslog-tls")
      (type "accept")
      (dport (list
          "syslog-tls"))
      (saddr (jinja "{{ rsyslog__allow + rsyslog__group_allow + rsyslog__host_allow }}"))
      (role "rsyslog")
      (accept_any "False")
      (rule_state (jinja "{{ \"present\"
                    if (rsyslog__enabled | bool and rsyslog__deploy_state != \"absent\" and
                        rsyslog__remote_enabled | bool)
                    else \"absent\" }}"))))
  (rsyslog__logrotate__dependent_config (list
      
      (filename "000rsyslog-unprivileged")
      (comment "The rsyslog daemon is run unprivileged")
      (options "su root " (jinja "{{ rsyslog__group }}") "
")
      (state (jinja "{{ \"present\"
                if (rsyslog__enabled | bool and rsyslog__deploy_state != \"absent\" and
                    rsyslog__unprivileged | bool)
                else \"absent\" }}"))
      
      (filename "rsyslog")
      (divert "True")
      (sections (list
          
          (logs "/var/log/syslog")
          (options "rotate " (jinja "{{ rsyslog__rotation_count_system }}") "
" (jinja "{{ rsyslog__rotation_period_system }}") "
maxsize 1G
missingok
notifempty
delaycompress
compress
")
          (postrotate (jinja "{{ \"invoke-rc.d rsyslog rotate > /dev/null\"
  if (ansible_distribution_release in
       ([\"stretch\", \"trusty\"]))
  else \"/usr/lib/rsyslog/rsyslog-rotate\" }}") "
")
          
          (logs (jinja "{{ (rsyslog__default_logfiles
                   + rsyslog__logfiles)
                  | difference([\"/var/log/syslog\"]) | sort }}"))
          (options "rotate " (jinja "{{ rsyslog__rotation_count_system }}") "
" (jinja "{{ rsyslog__rotation_period_system }}") "
maxsize 1G
missingok
notifempty
compress
delaycompress
sharedscripts
")
          (postrotate (jinja "{{ \"invoke-rc.d rsyslog rotate > /dev/null\"
  if (ansible_distribution_release in
       ([\"stretch\", \"trusty\"]))
  else \"/usr/lib/rsyslog/rsyslog-rotate\" }}") "
")))
      (state (jinja "{{ \"present\"
                if (rsyslog__enabled | bool and rsyslog__deploy_state != \"absent\")
                else \"absent\" }}"))
      
      (filename "rsyslog-remote")
      (logs (list
          "/var/log/remote/*/*/syslog"
          "/var/log/remote/*/*/*.log"))
      (options "rotate " (jinja "{{ rsyslog__rotation_count_remote }}") "
" (jinja "{{ rsyslog__rotation_period_remote }}") "
maxsize 1G
missingok
notifempty
compress
delaycompress
sharedscripts
")
      (postrotate (jinja "{{ \"invoke-rc.d rsyslog rotate > /dev/null\"
  if (ansible_distribution_release in
       ([\"stretch\", \"trusty\"]))
  else \"/usr/lib/rsyslog/rsyslog-rotate\" }}") "
")
      (state (jinja "{{ \"present\"
                if (rsyslog__enabled | bool and rsyslog__deploy_state != \"absent\" and
                    rsyslog__remote_enabled | bool)
                else \"absent\" }}"))))
  (rsyslog__dpkg_cleanup__dependent_packages (list
      
      (name "rsyslog")
      (revert_files (list
          "/etc/rsyslog.conf"
          "/etc/logrotate.d/rsyslog"
          (jinja "{{ rsyslog__combined_rules | flatten | debops.debops.parse_kv_items
            | selectattr(\"divert\", \"defined\") | list
            | selectattr(\"divert\", \"equalto\", True) | list
            | map(attribute=\"name\") | list
            | map(\"regex_replace\", \"^(.*)$\", \"/etc/rsyslog.d/\\1\") | list }}")))
      (remove_files (list
          "/etc/logrotate.d/rsyslog-remote"
          (jinja "{{ rsyslog__combined_rules | flatten | debops.debops.parse_kv_items
            | selectattr(\"divert\", \"undefined\") | list
            | map(attribute=\"name\") | list
            | map(\"regex_replace\", \"^(.*)$\", \"/etc/rsyslog.d/\\1\") | list }}"))))))
