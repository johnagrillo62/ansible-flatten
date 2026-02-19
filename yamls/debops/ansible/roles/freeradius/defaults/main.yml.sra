(playbook "debops/ansible/roles/freeradius/defaults/main.yml"
  (freeradius__base_packages (list
      "freeradius"
      "freeradius-utils"))
  (freeradius__packages (list))
  (freeradius__version (jinja "{{ ansible_local.freeradius.version | d(\"0.0.0\") }}"))
  (freeradius__user "freerad")
  (freeradius__group "freerad")
  (freeradius__conf_base_path "/etc/freeradius/3.0")
  (freeradius__default_ports (list
      "radius"
      "radius-acct"))
  (freeradius__ports (list))
  (freeradius__group_ports (list))
  (freeradius__host_ports (list))
  (freeradius__accept_any "False")
  (freeradius__allow (list))
  (freeradius__group_allow (list))
  (freeradius__host_allow (list))
  (freeradius__public_ports (list))
  (freeradius__public_group_ports (list))
  (freeradius__public_host_ports (list))
  (freeradius__public_accept_any "True")
  (freeradius__public_allow (list))
  (freeradius__public_group_allow (list))
  (freeradius__public_host_allow (list))
  (freeradius__default_configuration (list
      
      (name "sites-enabled/control-socket")
      (link_src "../sites-available/control-socket")))
  (freeradius__configuration (list))
  (freeradius__group_configuration (list))
  (freeradius__host_configuration (list))
  (freeradius__combined_configuration (jinja "{{ freeradius__default_configuration
                                        + freeradius__configuration
                                        + freeradius__group_configuration
                                        + freeradius__host_configuration }}"))
  (freeradius__ferm__dependent_rules (list
      
      (type "accept")
      (dport (jinja "{{ freeradius__default_ports
               + freeradius__ports
               + freeradius__group_ports
               + freeradius__host_ports }}"))
      (saddr (jinja "{{ freeradius__allow
               + freeradius__group_allow
               + freeradius__host_allow }}"))
      (protocols (list
          "tcp"
          "udp"))
      (accept_any (jinja "{{ freeradius__accept_any }}"))
      (weight "50")
      (by_role "debops.freeradius")
      (name "radius_internal")
      (multiport "True")
      
      (type "accept")
      (dport (jinja "{{ freeradius__public_ports
               + freeradius__public_group_ports
               + freeradius__public_host_ports }}"))
      (saddr (jinja "{{ freeradius__public_allow
               + freeradius__public_group_allow
               + freeradius__public_host_allow }}"))
      (protocols (list
          "tcp"
          "udp"))
      (accept_any (jinja "{{ freeradius__public_accept_any }}"))
      (weight "50")
      (by_role "debops.freeradius")
      (name "radius_public")
      (multiport "True")
      (rule_state (jinja "{{ \"present\"
                    if (freeradius__public_ports
                        + freeradius__public_group_ports
                        + freeradius__public_host_ports)
                    else \"absent\" }}"))))
  (freeradius__logrotate__dependent_config (list
      
      (filename "freeradius")
      (divert "True")
      (log "/var/log/freeradius/radius.log")
      (comment "The main server log")
      (options "daily
rotate 52
missingok
compress
delaycompress
notifempty
copytruncate
")
      (state "present")
      
      (filename "freeradius-monitor")
      (logs (list
          "/var/log/freeradius/checkrad.log"
          "/var/log/freeradius/radwatch.log"))
      (comment "Session monitoring utilities")
      (options "daily
rotate 52
missingok
compress
delaycompress
notifempty
nocreate
")
      (state "present")
      
      (filename "freeradius-session")
      (logs (list
          "/var/log/freeradius/radutmp"
          "/var/log/freeradius/radwtmp"))
      (comment "Session database modules")
      (options "daily
rotate 52
missingok
compress
delaycompress
notifempty
nocreate
")
      (state "present")
      
      (filename "freeradius-sql")
      (log "/var/log/freeradius/sqllog.sql")
      (comment "SQL log files")
      (options "daily
rotate 52
missingok
compress
delaycompress
notifempty
nocreate
")
      (state "present")
      
      (filename "freeradius-detail")
      (log "/var/log/freeradius/radacct/*/detail")
      (comment "There are different detail-rotating strategies you can use.  One is
to write to a single detail file per IP and use the rotate config
below.  Another is to write to a daily detail file per IP with:
    detailfile = ${radacctdir}/%{Client-IP-Address}/%Y%m%d-detail
(or similar) in radiusd.conf, without rotation.  If you go with the
second technique, you will need another cron job that removes old
detail files.  You do not need to comment out the below for method #2.
")
      (options "weekly
rotate 260
missingok
compress
delaycompress
notifempty
nocreate
")
      (state "present"))))
