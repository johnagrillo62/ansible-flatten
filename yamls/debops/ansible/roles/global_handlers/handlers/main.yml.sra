(playbook "debops/ansible/roles/global_handlers/handlers/main.yml"
  (tasks
    (task "Import meta handlers"
      (ansible.builtin.import_tasks "meta.yml"))
    (task "Import systemd handlers"
      (ansible.builtin.import_tasks "systemd.yml"))
    (task "Import resolved handlers"
      (ansible.builtin.import_tasks "resolved.yml"))
    (task "Import timesyncd handlers"
      (ansible.builtin.import_tasks "timesyncd.yml"))
    (task "Import apparmor handlers"
      (ansible.builtin.import_tasks "apparmor.yml"))
    (task "Import apt_cacher_ng handlers"
      (ansible.builtin.import_tasks "apt_cacher_ng.yml"))
    (task "Import atd handlers"
      (ansible.builtin.import_tasks "atd.yml"))
    (task "Import avahi handlers"
      (ansible.builtin.import_tasks "avahi.yml"))
    (task "Import bind handlers"
      (ansible.builtin.import_tasks "bind.yml"))
    (task "Import dhcp_probe handlers"
      (ansible.builtin.import_tasks "dhcp_probe.yml"))
    (task "Import dhcpd handlers"
      (ansible.builtin.import_tasks "dhcpd.yml"))
    (task "Import dhcrelay handlers"
      (ansible.builtin.import_tasks "dhcrelay.yml"))
    (task "Import dnsmasq handlers"
      (ansible.builtin.import_tasks "dnsmasq.yml"))
    (task "Import docker_gen handlers"
      (ansible.builtin.import_tasks "docker_gen.yml"))
    (task "Import docker_registry handlers"
      (ansible.builtin.import_tasks "docker_registry.yml"))
    (task "Import docker_server handlers"
      (ansible.builtin.import_tasks "docker_server.yml"))
    (task "Import dovecot handlers"
      (ansible.builtin.import_tasks "dovecot.yml"))
    (task "Import elasticsearch handlers"
      (ansible.builtin.import_tasks "elasticsearch.yml"))
    (task "Import etc_aliases handlers"
      (ansible.builtin.import_tasks "etc_aliases.yml"))
    (task "Import etherpad handlers"
      (ansible.builtin.import_tasks "etherpad.yml"))
    (task "Import fail2ban handlers"
      (ansible.builtin.import_tasks "fail2ban.yml"))
    (task "Import ferm handlers"
      (ansible.builtin.import_tasks "ferm.yml"))
    (task "Import filebeat handlers"
      (ansible.builtin.import_tasks "filebeat.yml"))
    (task "Import freeradius handlers"
      (ansible.builtin.import_tasks "freeradius.yml"))
    (task "Import gitlab handlers"
      (ansible.builtin.import_tasks "gitlab.yml"))
    (task "Import grub handlers"
      (ansible.builtin.import_tasks "grub.yml"))
    (task "Import icinga handlers"
      (ansible.builtin.import_tasks "icinga.yml"))
    (task "Import imapproxy handlers"
      (ansible.builtin.import_tasks "imapproxy.yml"))
    (task "Import influxdb2 handlers"
      (ansible.builtin.import_tasks "influxdb2.yml"))
    (task "Import influxdb_server handlers"
      (ansible.builtin.import_tasks "influxdb_server.yml"))
    (task "Import iscsi handlers"
      (ansible.builtin.import_tasks "iscsi.yml"))
    (task "Import keepalived handlers"
      (ansible.builtin.import_tasks "keepalived.yml"))
    (task "Import kibana handlers"
      (ansible.builtin.import_tasks "kibana.yml"))
    (task "Import mailman handlers"
      (ansible.builtin.import_tasks "mailman.yml"))
    (task "Import metricbeat handlers"
      (ansible.builtin.import_tasks "metricbeat.yml"))
    (task "Import memcached handlers"
      (ansible.builtin.import_tasks "memcached.yml"))
    (task "Import miniflux handlers"
      (ansible.builtin.import_tasks "miniflux.yml"))
    (task "Import minio handlers"
      (ansible.builtin.import_tasks "minio.yml"))
    (task "Import monit handlers"
      (ansible.builtin.import_tasks "monit.yml"))
    (task "Import mosquitto handlers"
      (ansible.builtin.import_tasks "mosquitto.yml"))
    (task "Import nfs_server handlers"
      (ansible.builtin.import_tasks "nfs_server.yml"))
    (task "Import nginx handlers"
      (ansible.builtin.import_tasks "nginx.yml"))
    (task "Import ntp handlers"
      (ansible.builtin.import_tasks "ntp.yml"))
    (task "Import nullmailer handlers"
      (ansible.builtin.import_tasks "nullmailer.yml"))
    (task "Import opendkim handlers"
      (ansible.builtin.import_tasks "opendkim.yml"))
    (task "Import opensearch handlers"
      (ansible.builtin.import_tasks "opensearch.yml"))
    (task "Import pdns handlers"
      (ansible.builtin.import_tasks "pdns.yml"))
    (task "Import pki handlers"
      (ansible.builtin.import_tasks "pki.yml"))
    (task "Import postfix handlers"
      (ansible.builtin.import_tasks "postfix.yml"))
    (task "Import prosody handlers"
      (ansible.builtin.import_tasks "prosody.yml"))
    (task "Import rabbitmq_server handlers"
      (ansible.builtin.import_tasks "rabbitmq_server.yml"))
    (task "Import radvd handlers"
      (ansible.builtin.import_tasks "radvd.yml"))
    (task "Import reprepro handlers"
      (ansible.builtin.import_tasks "reprepro.yml"))
    (task "Import resolvconf handlers"
      (ansible.builtin.import_tasks "resolvconf.yml"))
    (task "Import rspamd handlers"
      (ansible.builtin.import_tasks "rspamd.yml"))
    (task "Import rstudio_server handlers"
      (ansible.builtin.import_tasks "rstudio_server.yml"))
    (task "Import rsyslog handlers"
      (ansible.builtin.import_tasks "rsyslog.yml"))
    (task "Import salt handlers"
      (ansible.builtin.import_tasks "salt.yml"))
    (task "Import samba handlers"
      (ansible.builtin.import_tasks "samba.yml"))
    (task "Import saslauthd handlers"
      (ansible.builtin.import_tasks "saslauthd.yml"))
    (task "Import sks handlers"
      (ansible.builtin.import_tasks "sks.yml"))
    (task "Import slapd handlers"
      (ansible.builtin.import_tasks "slapd.yml"))
    (task "Import smstools handlers"
      (ansible.builtin.import_tasks "smstools.yml"))
    (task "Import snmpd handlers"
      (ansible.builtin.import_tasks "snmpd.yml"))
    (task "Import lldpd handlers"
      (ansible.builtin.import_tasks "lldpd.yml"))
    (task "Import sshd handlers"
      (ansible.builtin.import_tasks "sshd.yml"))
    (task "Import stunnel handlers"
      (ansible.builtin.import_tasks "stunnel.yml"))
    (task "Import sysfs handlers"
      (ansible.builtin.import_tasks "sysfs.yml"))
    (task "Import libvirtd handlers"
      (ansible.builtin.import_tasks "libvirtd.yml"))
    (task "Import tcpwrappers handlers"
      (ansible.builtin.import_tasks "tcpwrappers.yml"))
    (task "Import tftpd handlers"
      (ansible.builtin.import_tasks "tftpd.yml"))
    (task "Import tgt handlers"
      (ansible.builtin.import_tasks "tgt.yml"))
    (task "Import tinc handlers"
      (ansible.builtin.import_tasks "tinc.yml"))
    (task "Import tinyproxy handlers"
      (ansible.builtin.import_tasks "tinyproxy.yml"))
    (task "Import unbound handlers"
      (ansible.builtin.import_tasks "unbound.yml"))
    (task "Import telegraf handlers"
      (ansible.builtin.import_tasks "telegraf.yml"))
    (task "Import zabbix_agent handlers"
      (ansible.builtin.import_tasks "zabbix_agent.yml"))
    (task "Import etckeeper handlers"
      (ansible.builtin.import_tasks "etckeeper.yml"))))
