(playbook "debops/ansible/roles/mariadb_server/defaults/main.yml"
  (mariadb_server__flavor (jinja "{{ ansible_local.mariadb.flavor | d(\"mariadb\") }}"))
  (mariadb_server__apt_key (jinja "{{ mariadb_server__apt_key_map[mariadb_server__flavor] | d() }}"))
  (mariadb_server__apt_key_map 
    (mariadb (list))
    (mariadb_upstream (list
        
        (id "199369E5404BD5FC7D2FE43BCBCB082A1BB943DB")
        
        (id "177F4010FE56CA3336300305F1656F24C74CD1D8")
        
        (repo "deb " (jinja "{{ mariadb_server__upstream_mirror }}") " " (jinja "{{ ansible_distribution_release }}") " main")))
    (mysql-5.6_galera-3 (list
        
        (id "44B7345738EBDE52594DAD80D669017EBC19DDBA")
        
        (repo "deb http://releases.galeracluster.com/mysql-wsrep-5.6/" (jinja "{{ ansible_distribution | lower }}") " " (jinja "{{ ansible_distribution_release }}") " main")
        
        (repo "deb http://releases.galeracluster.com/galera-3/" (jinja "{{ ansible_distribution | lower }}") " " (jinja "{{ ansible_distribution_release }}") " main")))
    (mysql-5.7_galera-3 (list
        
        (id "44B7345738EBDE52594DAD80D669017EBC19DDBA")
        
        (repo "deb http://releases.galeracluster.com/mysql-wsrep-5.7/" (jinja "{{ ansible_distribution | lower }}") " " (jinja "{{ ansible_distribution_release }}") " main")
        
        (repo "deb http://releases.galeracluster.com/galera-3/" (jinja "{{ ansible_distribution | lower }}") " " (jinja "{{ ansible_distribution_release }}") " main")))
    (percona-8.0 (list
        
        (id "4D1BB29D63D98E422B2113B19334A25F8507EFA5")
        
        (repo "deb http://repo.percona.com/tools/apt " (jinja "{{ ansible_distribution_release }}") " main")
        
        (repo "deb http://repo.percona.com/ps-80/apt " (jinja "{{ ansible_distribution_release }}") " main")))
    (percona-5.7 (list
        
        (id "4D1BB29D63D98E422B2113B19334A25F8507EFA5")
        
        (repo "deb http://repo.percona.com/tools/apt " (jinja "{{ ansible_distribution_release }}") " main")
        
        (repo "deb http://repo.percona.com/ps-57/apt " (jinja "{{ ansible_distribution_release }}") " main"))))
  (mariadb_server__upstream_version "10.1")
  (mariadb_server__upstream_mirror "http://nyc2.mirrors.digitalocean.com/mariadb/repo/" (jinja "{{ mariadb_server__upstream_version }}") "/" (jinja "{{ ansible_distribution | lower }}"))
  (mariadb_server__base_packages (list
      "ssl-cert"))
  (mariadb_server__packages (list))
  (mariadb_server__packages_map 
    (mariadb (list
        "mariadb-server"))
    (mariadb_upstream (list
        "mariadb-server"))
    (mysql (list
        "mysql-server"))
    (mysql-5.6_galera-3 (list
        "mysql-wsrep-server-5.6"
        "galera-3"
        "galera-arbitrator-3"))
    (mysql-5.7_galera-3 (list
        "mysql-wsrep-server-5.7"
        "galera-3"
        "galera-arbitrator-3"))
    (percona-8.0 (list
        "percona-server-server"))
    (percona-5.7 (list
        "percona-server-server-5.7")))
  (mariadb_server__bind_address "localhost")
  (mariadb_server__port "3306")
  (mariadb_server__allow (list))
  (mariadb_server__max_connections "100")
  (mariadb_server__default_datadir "/var/lib/mysql")
  (mariadb_server__datadir (jinja "{{ mariadb_server__default_datadir }}"))
  (mariadb_server__delegate_to (jinja "{{ inventory_hostname }}"))
  (mariadb_server__mysqld_performance_options 
    (innodb_buffer_pool_instances (jinja "{{ ansible_processor_vcpus | d(1) }}"))
    (innodb_buffer_pool_size (jinja "{{ (ansible_memtotal_mb / 2) | int }}") "M")
    (query_cache_type "0"))
  (mariadb_server__local_infile "False")
  (mariadb_server__mysqld_security_options 
    (local_infile (jinja "{{ \"1\" if mariadb_server__local_infile | bool else \"0\" }}")))
  (mariadb_server__mysqld_charset_options 
    (character_set_server "utf8mb4")
    (collation_server "utf8mb4_general_ci")
    (init_connect "SET NAMES utf8mb4"))
  (mariadb_server__mysqld_network_options 
    (bind_address (jinja "{{ mariadb_server__bind_address }}"))
    (port (jinja "{{ mariadb_server__port }}"))
    (max_connections (jinja "{{ mariadb_server__max_connections }}")))
  (mariadb_server__mysqld_pki_options 
    (name "pki-options")
    (comment "Support for SSL connections")
    (state (jinja "{{ \"present\" if mariadb_server__pki | bool else \"absent\" }}"))
    (options 
      (ssl null)
      (ssl_ca (jinja "{{ mariadb_server__pki_path + \"/\" + mariadb_server__pki_realm + \"/\" + mariadb_server__pki_ca }}"))
      (ssl_cert (jinja "{{ mariadb_server__pki_path + \"/\" + mariadb_server__pki_realm + \"/\" + mariadb_server__pki_crt }}"))
      (ssl_key (jinja "{{ mariadb_server__pki_path + \"/\" + mariadb_server__pki_realm + \"/\" + mariadb_server__pki_key }}"))
      (ssl_cipher (jinja "{{ mariadb_server__pki_cipher }}"))))
  (mariadb_server__mysqld_cluster_options 
    (name "cluster-options")
    (comment "Required for cluster operation")
    (state (jinja "{{ \"present\" if mariadb_server__flavor in [\"mysql-5.6_galera-3\", \"percona\", \"percona-5.7\"] else \"absent\" }}"))
    (options 
      (binlog_format "ROW")
      (default_storage_engine "InnoDB")
      (innodb_autoinc_lock_mode "2")))
  (mariadb_server__mysqld_directory_options 
    (datadir (jinja "{{ mariadb_server__datadir }}")))
  (mariadb_server__mysqld_options (list
      
      (section "mysqld")
      (options (list
          (jinja "{{ mariadb_server__mysqld_performance_options }}")
          (jinja "{{ mariadb_server__mysqld_charset_options }}")
          (jinja "{{ mariadb_server__mysqld_security_options }}")
          (jinja "{{ mariadb_server__mysqld_network_options }}")
          (jinja "{{ mariadb_server__mysqld_pki_options }}")
          (jinja "{{ mariadb_server__mysqld_cluster_options }}")
          (jinja "{{ mariadb_server__mysqld_directory_options }}")
          (jinja "{{ mariadb_server__options }}")))))
  (mariadb_server__client_options (list
      
      (section "client")
      (options 
        (default_character_set "utf8mb4"))))
  (mariadb_server__options )
  (mariadb_server__client_cnf_file (jinja "{{ \"/etc/mysql/mariadb.conf.d/90-client.cnf\"
                                     if (mariadb_server__register_confd.stat.exists | bool)
                                     else \"/etc/mysql/conf.d/zz-client.cnf\" }}"))
  (mariadb_server__mysqld_cnf_file (jinja "{{ \"/etc/mysql/mariadb.conf.d/90-mysqld.cnf\"
                                     if (mariadb_server__register_confd.stat.exists | bool)
                                     else \"/etc/mysql/conf.d/zz-mysqld.cnf\" }}"))
  (mariadb_server__append_groups (list
      "ssl-cert"))
  (mariadb_server__pki (jinja "{{ (True
                      if (ansible_local.pki.enabled | d() and
                          mariadb_server__pki_realm in ansible_local.pki.known_realms)
                      else False) | bool }}"))
  (mariadb_server__pki_path (jinja "{{ ansible_local.pki.base_path | d(\"/etc/pki\") }}"))
  (mariadb_server__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (mariadb_server__pki_ca "CA.crt")
  (mariadb_server__pki_crt "default.crt")
  (mariadb_server__pki_key "default.key")
  (mariadb_server__pki_cipher "DHE-RSA-AES256-SHA")
  (mariadb_server__backup "True")
  (mariadb_server__backup_mailaddr "backup")
  (mariadb_server__backup_create_database "True")
  (mariadb_server__backup_exclude_databases (list))
  (mariadb_server__backup_doweekly "6")
  (mariadb_server__backup_latest "no")
  (mariadb_server__backup_directory "/var/lib/automysqlbackup")
  (mariadb_server__backup_max_allowed_packet "")
  (mariadb_server__keyring__dependent_apt_keys (list
      (jinja "{{ mariadb_server__apt_key }}")))
  (mariadb_server__etc_services__dependent_rules (list
      
      (name "galera-cluster-rep")
      (port "4567")
      (protocols (list
          "tcp"
          "udp"))
      (comment "Galera Cluster Replication")
      
      (name "galera-ist")
      (port "4568")
      (protocols (list
          "tcp"))
      (comment "Galera Incremental State Transfer")
      
      (name "galera-sst")
      (port "4444")
      (protocols (list
          "tcp"))
      (comment "Galera State Snapshot Transfer")))
  (mariadb_server__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "mysql"))
      (saddr (jinja "{{ mariadb_server__allow }}"))
      (accept_any "False")
      (weight "50")
      (role "mariadb_server")))
  (mariadb_server__tcpwrappers__dependent_allow (list
      
      (daemon "mysqld")
      (client (jinja "{{ mariadb_server__allow }}"))
      (accept_any "False")
      (weight "50")
      (filename "mariadb_server_allow")
      (comment "Allow remote connections to MariaDB / MySQL server")))
  (mariadb_server__python__dependent_packages3 (list
      "python3-mysqldb"))
  (mariadb_server__python__dependent_packages2 (list
      "python-mysqldb")))
