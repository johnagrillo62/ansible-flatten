(playbook "debops/ansible/roles/monit/defaults/main.yml"
  (monit__base_packages (list
      "monit"))
  (monit__packages (list))
  (monit__fqdn (jinja "{{ ansible_fqdn }}"))
  (monit__domain (jinja "{{ ansible_domain }}"))
  (monit__check_interval "120")
  (monit__start_delay "240")
  (monit__alerts_to (list
      "root@" (jinja "{{ monit__domain }}")))
  (monit__httpd_port "2812")
  (monit__httpd_username "monit")
  (monit__httpd_password (jinja "{{ lookup(\"password\", secret + \"/credentials/\"
                           + inventory_hostname + \"/monit/httpd/password \"
                           + \"chars=ascii_letters,digits length=32\") }}"))
  (monit__default_config (list
      
      (name "daemon")
      (content "set daemon " (jinja "{{ monit__check_interval }}") "
    with start delay " (jinja "{{ monit__start_delay }}") "
")
      (weight "10")
      
      (name "logfile")
      (content "set logfile syslog facility log_daemon
")
      (weight "15")
      
      (name "http_server")
      (comment "HTTP server is used by the command line tool")
      (content "set httpd port " (jinja "{{ monit__httpd_port }}") " and
    use address localhost
    allow localhost
    allow " (jinja "{{ monit__httpd_username + ':' + monit__httpd_password }}") "
")
      (weight "20")
      (mode "0600")
      
      (name "mailserver")
      (content "set mailserver localhost
")
      (weight "25")
      
      (name "global_alerts")
      (content (jinja "{% for address in ([monit__alerts_to]
                   if monit__alerts_to is string
                   else monit__alerts_to) %}") "
set alert " (jinja "{{ address }}") " not on { instance, action }
" (jinja "{% endfor %}") "
")
      (weight "30")
      
      (name "check_system")
      (content "check system " (jinja "{{ monit__fqdn }}") "
  if loadavg (1min)     > " (jinja "{{ ansible_processor_vcpus * 2 }}") " for 5 cycles then alert
  if loadavg (5min)     > " (jinja "{{ ansible_processor_vcpus }}") " for 5 cycles then alert
  if memory usage       > 75% for 5 cycles then alert
  if swap usage         > 25% for 5 cycles then alert
  if cpu usage (user)   > 70% for 5 cycles then alert
  if cpu usage (system) > 30% for 5 cycles then alert
  if cpu usage (wait)   > 30% for 5 cycles then alert
")
      (weight "35")))
  (monit__service_config (list
      
      (name "apache2")
      (content "check process apache2 with pidfile /var/run/apache2/apache2.pid
  group www
  group apache2
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start apache2.service\"
  stop  program = \"/bin/systemctl stop  apache2.service\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/apache2 start\"
  stop  program = \"/etc/init.d/apache2 stop\"
" (jinja "{% endif %}") "
  if failed port 80 protocol http request \"/\" then restart
  if 5 restarts with 5 cycles then timeout
  depend apache2_bin
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  depend apache2_unit
" (jinja "{% else %}") "
  depend apache2_rc
" (jinja "{% endif %}") "

check file apache2_bin with path /usr/sbin/apache2
  group apache2
  include /etc/monit/templates/rootbin

" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
check file apache2_unit with path /lib/systemd/system/apache2.service
  group apache2
  include /etc/monit/templates/rootrc
" (jinja "{% else %}") "
check file apache2_rc with path /etc/init.d/apache2
  group apache2
  include /etc/monit/templates/rootbin
" (jinja "{% endif %}") "
")
      (state (jinja "{{ \"present\"
               if (ansible_local.apache.enabled | d() | bool)
               else \"init\" }}"))
      
      (name "atd")
      (content "check process atd with pidfile /var/run/atd.pid
  group system
  group atd
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start atd.service\"
  stop  program = \"/bin/systemctl stop  atd.service\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/atd start\"
  stop  program = \"/etc/init.d/atd stop\"
" (jinja "{% endif %}") "
  if 5 restarts within 5 cycles then timeout
  depends on atd_bin
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  depends on atd_unit
" (jinja "{% else %}") "
  depends on atd_rc
" (jinja "{% endif %}") "

check file atd_bin with path \"/usr/sbin/atd\"
  group atd
  include /etc/monit/templates/rootbin

" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
check file atd_unit with path \"/lib/systemd/system/atd.service\"
  group atd
  include /etc/monit/templates/rootrc
" (jinja "{% else %}") "
check file atd_rc with path \"/etc/init.d/atd\"
  group atd
  include /etc/monit/templates/rootbin
" (jinja "{% endif %}") "
")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.atd | d() and
                   (ansible_local.atd.enabled | d()) | bool)
               else \"init\" }}"))
      
      (name "cron")
      (content "check process crond with pidfile /var/run/crond.pid
  group system
  group crond
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start cron.service\"
  stop  program = \"/bin/systemctl stop  cron.service\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/cron start\"
  stop  program = \"/etc/init.d/cron stop\"
" (jinja "{% endif %}") "
  if 5 restarts with 5 cycles then timeout
  depend cron_bin
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  depend cron_unit
" (jinja "{% else %}") "
  depend cron_rc
" (jinja "{% endif %}") "
  depend cron_spool

check file cron_bin with path /usr/sbin/cron
  group crond
  include /etc/monit/templates/rootbin

" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
check file cron_unit with path \"/lib/systemd/system/cron.service\"
  group crond
  include /etc/monit/templates/rootrc
" (jinja "{% else %}") "
check file cron_rc with path \"/etc/init.d/cron\"
  group crond
  include /etc/monit/templates/rootbin
" (jinja "{% endif %}") "

check directory cron_spool with path /var/spool/cron/crontabs
  group crond
  if failed permission 1730 then unmonitor
  if failed uid root        then unmonitor
  if failed gid crontab     then unmonitor
")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.cron | d() and
                   (ansible_local.cron.enabled | d()) | bool)
               else \"init\" }}"))
      
      (name "memcached")
      (content "check process memcached matching \"^/usr/bin/memcached\"
  group cache
  group memcached
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start memcached.service\"
  stop  program = \"/bin/systemctl stop  memcached.service\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/memcached start\"
  stop  program = \"/etc/init.d/memcached stop\"
" (jinja "{% endif %}") "
  if failed host 127.0.0.1 port 11211 and protocol memcache then restart
  if cpu > 60% for 2 cycles then alert
  if cpu > 98% for 5 cycles then restart
  if 5 restarts within 20 cycles then timeout
  depend memcache_bin
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  depend memcache_unit
" (jinja "{% else %}") "
  depend memcache_rc
" (jinja "{% endif %}") "

check file memcache_bin with path /usr/bin/memcached
  group memcached
  include /etc/monit/templates/rootbin

" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
check file memcache_unit with path /lib/systemd/system/memcached.service
  group memcached
  include /etc/monit/templates/rootrc
" (jinja "{% else %}") "
check file memcache_rc with path /etc/init.d/memcached
  group memcached
  include /etc/monit/templates/rootbin
" (jinja "{% endif %}") "
")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.memcached | d() and
                   (ansible_local.memcached.installed | d()) | bool)
               else \"init\" }}"))
      
      (name "mysql")
      (content "check process mysqld with pidfile /var/run/mysqld/mysqld.pid
  group database
  group mysql
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start mysql.service\"
  stop  program = \"/bin/systemctl stop  mysql.service\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/mysql start\"
  stop  program = \"/etc/init.d/mysql stop\"
" (jinja "{% endif %}") "
  if failed host localhost port 3306 protocol mysql with timeout 15 seconds for 3 times within 4 cycles then restart
  if failed unixsocket /var/run/mysqld/mysqld.sock protocol mysql for 3 times within 4 cycles then restart
  if 5 restarts with 5 cycles then timeout
  depend mysql_bin
  depend mysql_rc

check file mysql_bin with path /usr/sbin/mysqld
  group mysql
  include /etc/monit/templates/rootbin

check file mysql_rc with path /etc/init.d/mysql
  group mysql
  include /etc/monit/templates/rootbin
")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.mariadb | d() and
                   ansible_local.mariadb.server | d(\"\") == \"localhost\")
               else \"init\" }}"))
      
      (name "nginx")
      (content "check process nginx with pidfile /var/run/nginx.pid
  group www
  group nginx
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start nginx.service\"
  stop  program = \"/bin/systemctl stop  nginx.service\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/nginx start\"
  stop  program = \"/etc/init.d/nginx stop\"
" (jinja "{% endif %}") "
  if failed port 80 protocol http request \"/\" then restart
  if 5 restarts with 5 cycles then timeout
  depend nginx_bin
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  depend nginx_unit
" (jinja "{% else %}") "
  depend nginx_rc
" (jinja "{% endif %}") "

check file nginx_bin with path /usr/sbin/nginx
  group nginx
  include /etc/monit/templates/rootbin

" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
check file nginx_unit with path /lib/systemd/system/nginx.service
  group nginx
  include /etc/monit/templates/rootrc
" (jinja "{% else %}") "
check file nginx_rc with path /etc/init.d/nginx
  group nginx
  include /etc/monit/templates/rootbin
" (jinja "{% endif %}") "
")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.nginx | d() and
                   (ansible_local.nginx.enabled | d()) | bool)
               else \"init\" }}"))
      
      (name "openntpd")
      (content "check process ntpd matching \"^/usr/sbin/ntpd -f /etc/openntpd/ntpd.conf\"
  group system
  group ntpd
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start openntpd.service\"
  stop  program = \"/bin/systemctl stop  openntpd.service\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/openntpd start\"
  stop  program = \"/etc/init.d/openntpd stop\"
" (jinja "{% endif %}") "
  if 4 restarts within 12 cycles then timeout
  depend ntpd_bin
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  depend ntpd_unit
" (jinja "{% else %}") "
  depend ntpd_rc
" (jinja "{% endif %}") "

check file ntpd_bin with path /usr/sbin/ntpd
  group ntpd
  include /etc/monit/templates/rootbin

" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
check file ntpd_unit with path /lib/systemd/system/openntpd.service
  group ntpd
  include /etc/monit/templates/rootrc
" (jinja "{% else %}") "
check file ntpd_rc with path /etc/init.d/openntpd
  group ntpd
  include /etc/monit/templates/rootbin
" (jinja "{% endif %}") "
")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.ntp | d() and
                   (ansible_local.ntp.configured | d()) | bool and
                   ansible_local.ntp.daemon | d(\"\") == \"openntpd\")
               else \"init\" }}"))
      
      (name "postfix")
      (content "check process postfix with pidfile /var/spool/postfix/pid/master.pid
  group system
  group mail
  group postfix
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start postfix.service\"
  stop  program = \"/bin/systemctl stop  postfix.service\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/postfix start\"
  stop  program = \"/etc/init.d/postfix stop\"
" (jinja "{% endif %}") "
  if failed host localhost port 25 with protocol smtp for 2 times within 3 cycles then restart
  if 5 restarts with 5 cycles then timeout
  depend master_bin
" (jinja "{% if ansible_distribution_release in ['trusty', 'xenial'] %}") "
  depend postfix_rc
" (jinja "{% else %}") "
  depend postfix_unit
" (jinja "{% endif %}") "
  depend postdrop_bin
  depend postqueue_bin
  depend master_cf
  depend main_cf

" (jinja "{% if ansible_distribution_release in ['trusty', 'xenial'] %}") "
check file master_bin with path /usr/lib/postfix/master
" (jinja "{% else %}") "
check file master_bin with path /usr/lib/postfix/sbin/master
" (jinja "{% endif %}") "
  group postfix
  include /etc/monit/templates/rootbin

check file postdrop_bin with path /usr/sbin/postdrop
  group postfix
  if failed checksum        then unmonitor
  if failed permission 2555 then unmonitor
  if failed uid root        then unmonitor
  if failed gid postdrop    then unmonitor

check file postqueue_bin with path /usr/sbin/postqueue
  group postfix
  if failed checksum        then unmonitor
  if failed permission 2555 then unmonitor
  if failed uid root        then unmonitor
  if failed gid postdrop    then unmonitor

check file master_cf with path /etc/postfix/master.cf
  group postfix
  include /etc/monit/templates/rootrc

check file main_cf with path /etc/postfix/main.cf
  group postfix
  include /etc/monit/templates/rootrc

" (jinja "{% if ansible_distribution_release in ['trusty', 'xenial'] %}") "
check file postfix_rc with path /etc/init.d/postfix
  group postfix
  include /etc/monit/templates/rootbin
" (jinja "{% else %}") "
check file postfix_unit with path /lib/systemd/system/postfix.service
  group postfix
  include /etc/monit/templates/rootrc
" (jinja "{% endif %}") "
")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.postfix | d() and
                   (ansible_local.postfix.installed | d()) | bool)
               else \"init\" }}"))
      
      (name "rsyslog")
      (content "check process rsyslogd with pidfile /var/run/rsyslogd.pid
  group system
  group rsyslogd
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start rsyslog.service\"
  stop  program = \"/bin/systemctl stop  rsyslog.service\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/rsyslog start\"
  stop  program = \"/etc/init.d/rsyslog stop\"
" (jinja "{% endif %}") "
  if 5 restarts with 5 cycles then timeout
  depend on rsyslogd_bin
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  depend on rsyslogd_unit
" (jinja "{% else %}") "
  depend on rsyslogd_rc
" (jinja "{% endif %}") "
  depend on rsyslog_file

check file rsyslogd_bin with path /usr/sbin/rsyslogd
  group rsyslogd
  include /etc/monit/templates/rootbin

" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
check file rsyslogd_unit with path \"/lib/systemd/system/rsyslog.service\"
  group rsyslogd
  include /etc/monit/templates/rootrc
" (jinja "{% else %}") "
check file rsyslogd_rc with path \"/etc/init.d/rsyslog\"
  group rsyslogd
  include /etc/monit/templates/rootbin
" (jinja "{% endif %}") "

check file rsyslog_file with path /var/log/messages
  group rsyslogd
  if timestamp > 65 minutes then alert
  if failed permission 640  then unmonitor
  if failed uid root        then unmonitor
  if failed gid adm         then unmonitor
")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.rsyslog | d() and
                   (ansible_local.rsyslog.enabled | d()) | bool)
               else \"init\" }}"))
      
      (name "snmpd")
      (content "check process snmpd with pidfile /var/run/snmpd.pid
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start snmpd\"
  stop  program = \"/bin/systemctl stop  snmpd\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/snmpd start\"
  stop  program = \"/etc/init.d/snmpd stop\"
" (jinja "{% endif %}") "
  if failed host localhost port 161 type udp then restart
  if 5 restarts within 5 cycles then timeout
")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.snmpd | d() and
                   (ansible_local.snmpd.installed | d()) | bool)
               else \"init\" }}"))
      
      (name "sshd")
      (content "check process sshd with pidfile /var/run/sshd.pid
  group system
  group sshd
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  start program = \"/bin/systemctl start ssh.service\"
  stop  program = \"/bin/systemctl stop  ssh.service\"
" (jinja "{% else %}") "
  start program = \"/etc/init.d/ssh start\"
  stop  program = \"/etc/init.d/ssh stop\"
" (jinja "{% endif %}") "
  if failed host localhost port 22 with proto ssh then restart
  if 5 restarts with 5 cycles then timeout
  depend on sshd_bin
  depend on sftp_bin
" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
  depend on sshd_unit
" (jinja "{% else %}") "
  depend on sshd_rc
" (jinja "{% endif %}") "
  depend on sshd_rsa_key
  depend on sshd_ecdsa_key
  depend on sshd_ed25519_key

check file sshd_bin with path /usr/sbin/sshd
  group sshd
  include /etc/monit/templates/rootbin

check file sftp_bin with path /usr/lib/openssh/sftp-server
  group sshd
  include /etc/monit/templates/rootbin

" (jinja "{% if ansible_service_mgr == 'systemd' %}") "
check file sshd_unit with path /lib/systemd/system/ssh.service
  group sshd
  include /etc/monit/templates/rootrc
" (jinja "{% else %}") "
check file sshd_rc with path /etc/init.d/ssh
  group sshd
  include /etc/monit/templates/rootbin
" (jinja "{% endif %}") "

check file sshd_rsa_key with path /etc/ssh/ssh_host_rsa_key
  group sshd
  include /etc/monit/templates/rootstrict

check file sshd_ecdsa_key with path /etc/ssh/ssh_host_ecdsa_key
  group sshd
  include /etc/monit/templates/rootstrict

check file sshd_ed25519_key with path /etc/ssh/ssh_host_ed25519_key
  group sshd
  include /etc/monit/templates/rootstrict
")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.sshd | d() and
                   (ansible_local.sshd.configured | d()) | bool)
               else \"init\" }}"))))
  (monit__config (list))
  (monit__group_config (list))
  (monit__host_config (list))
  (monit__dependent_config (list))
  (monit__combined_config (jinja "{{ monit__default_config
                            + monit__service_config
                            + monit__dependent_config
                            + monit__config
                            + monit__group_config
                            + monit__host_config }}"))
  (monit__etc_services__dependent_list (list
      
      (name "monit")
      (port (jinja "{{ monit__httpd_port }}")))))
