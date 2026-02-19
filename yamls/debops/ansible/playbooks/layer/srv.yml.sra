(playbook "debops/ansible/playbooks/layer/srv.yml"
  (tasks
    (task "Configure /etc/aliases database"
      (import_playbook "../service/etc_aliases.yml"))
    (task "Configure etesync service"
      (import_playbook "../service/etesync.yml"))
    (task "Install HashiCorp applications"
      (import_playbook "../service/hashicorp.yml"))
    (task "Configure APT-Cacher-NG service"
      (import_playbook "../service/apt_cacher_ng.yml"))
    (task "Configure APT mirror service"
      (import_playbook "../service/apt_mirror.yml"))
    (task "Configure docker-gen service"
      (import_playbook "../service/docker_gen.yml"))
    (task "Configure gunicorn service"
      (import_playbook "../service/gunicorn.yml"))
    (task "Configure Postfix SMTP server"
      (import_playbook "../service/postfix.yml"))
    (task "Configure saslauthd service"
      (import_playbook "../service/saslauthd.yml"))
    (task "Configure Dovecot IMAP/POP3 server"
      (import_playbook "../service/dovecot.yml"))
    (task "Configure postscreen Postfix service"
      (import_playbook "../service/postscreen.yml"))
    (task "Configure Postwhite Postfix service"
      (import_playbook "../service/postwhite.yml"))
    (task "Manage Postfix service configuration"
      (import_playbook "../service/postconf.yml"))
    (task "Configure Postfix LDAP support"
      (import_playbook "../service/postldap.yml"))
    (task "Configure OpenDKIM service"
      (import_playbook "../service/opendkim.yml"))
    (task "Configure Apache webserver"
      (import_playbook "../service/apache.yml"))
    (task "Configure nginx webserver"
      (import_playbook "../service/nginx.yml"))
    (task "Configure Mosquitto service"
      (import_playbook "../service/mosquitto.yml"))
    (task "Configure SNMP daemon"
      (import_playbook "../service/snmpd.yml"))
    (task "Configure Monit service"
      (import_playbook "../service/monit.yml"))
    (task "Configure TFTP daemon"
      (import_playbook "../service/tftpd.yml"))
    (task "Configure Samba service"
      (import_playbook "../service/samba.yml"))
    (task "Configure TGT, userspace iSCSI client"
      (import_playbook "../service/tgt.yml"))
    (task "Configure MariaDB/MySQL database"
      (import_playbook "../service/mariadb_server.yml"))
    (task "Configure MariaDB/MySQL client"
      (import_playbook "../service/mariadb.yml"))
    (task "Configure PostgreSQL service"
      (import_playbook "../service/postgresql_server.yml"))
    (task "Configure PostgreSQL client"
      (import_playbook "../service/postgresql.yml"))
    (task "Configure Elastic APT repositories"
      (import_playbook "../service/elastic_co.yml"))
    (task "Configure Elasticsearch database"
      (import_playbook "../service/elasticsearch.yml"))
    (task "Configure Kibana service"
      (import_playbook "../service/kibana.yml"))
    (task "Configure InfluxData APT repositories"
      (import_playbook "../service/influxdata.yml"))
    (task "Configure InfluxDBv2 database"
      (import_playbook "../service/influxdb2.yml"))
    (task "Configure InfluxDB database"
      (import_playbook "../service/influxdb_server.yml"))
    (task "Configure InfluxDB client"
      (import_playbook "../service/influxdb.yml"))
    (task "Configure Icinga 2 service"
      (import_playbook "../service/icinga.yml"))
    (task "Configure Icinga 2 database"
      (import_playbook "../service/icinga_db.yml"))
    (task "Configure Icinga 2 Web frontend"
      (import_playbook "../service/icinga_web.yml"))
    (task "Configure RabbitMQ service"
      (import_playbook "../service/rabbitmq_server.yml"))
    (task "Configure RabbitMQ management webconsole"
      (import_playbook "../service/rabbitmq_management.yml"))
    (task "Configure memcached service"
      (import_playbook "../service/memcached.yml"))
    (task "Configure Redis database"
      (import_playbook "../service/redis_server.yml"))
    (task "Configure Redis Sentinel service"
      (import_playbook "../service/redis_sentinel.yml"))
    (task "Configure MinIO service"
      (import_playbook "../service/minio.yml"))
    (task "Configure MinIO Client"
      (import_playbook "../service/mcli.yml"))
    (task "Configure Docker Registry service"
      (import_playbook "../service/docker_registry.yml"))
    (task "Configure reprepro APT repository"
      (import_playbook "../service/reprepro.yml"))
    (task "Configure SMS Gateway service"
      (import_playbook "../service/smstools.yml"))
    (task "Install Salt Master service"
      (import_playbook "../service/salt.yml"))
    (task "Configure Fail2ban service"
      (import_playbook "../service/fail2ban.yml"))
    (task "Configure Prosody XMPP server"
      (import_playbook "../service/prosody.yml"))
    (task "Configure FreeRADIUS service"
      (import_playbook "../service/freeradius.yml"))
    (task "Configure Tinyproxy service"
      (import_playbook "../service/tinyproxy.yml"))
    (task "Configure libuser library"
      (import_playbook "../service/libuser.yml"))
    (task "Configure MiniDLNA service"
      (import_playbook "../service/minidlna.yml"))
    (task "Configure PowerDNS service"
      (import_playbook "../service/pdns.yml"))
    (task "Configure BIND DNS server"
      (import_playbook "../service/bind.yml"))
    (task "Configure rspamd service"
      (import_playbook "../service/rspamd.yml"))
    (task "Configure OpenSearch database"
      (import_playbook "../service/opensearch.yml"))))
