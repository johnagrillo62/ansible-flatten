(playbook "debops/ansible/roles/mariadb/defaults/main.yml"
  (mariadb__server "")
  (mariadb__port "3306")
  (mariadb__client (jinja "{{ ansible_fqdn }}"))
  (mariadb__delegate_to (jinja "{{ mariadb__server
                          if (mariadb__server | d() and
                              mariadb__server != \"localhost\")
                          else inventory_hostname }}"))
  (mariadb__flavor (jinja "{{ ansible_local.mariadb.flavor | d(\"mariadb\") }}"))
  (mariadb__apt_key (jinja "{{ mariadb__apt_key_map[mariadb__flavor] | d() }}"))
  (mariadb__apt_key_map 
    (mariadb (list))
    (mariadb_upstream (list
        
        (id "199369E5404BD5FC7D2FE43BCBCB082A1BB943DB")
        
        (id "177F4010FE56CA3336300305F1656F24C74CD1D8")
        
        (repo "deb " (jinja "{{ mariadb__upstream_mirror }}") " " (jinja "{{ ansible_distribution_release }}") " main")))
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
        
        (repo "deb http://repo.percona.com/ps-80/apt " (jinja "{{ ansible_distribution_release }}") " main")
        
        (repo "deb http://repo.percona.com/tools/apt " (jinja "{{ ansible_distribution_release }}") " main")))
    (percona-5.7 (list
        
        (id "4D1BB29D63D98E422B2113B19334A25F8507EFA5")
        
        (repo "deb http://repo.percona.com/ps-57/apt " (jinja "{{ ansible_distribution_release }}") " main")
        
        (repo "deb http://repo.percona.com/tools/apt " (jinja "{{ ansible_distribution_release }}") " main"))))
  (mariadb__upstream_version "10.1")
  (mariadb__upstream_mirror "http://nyc2.mirrors.digitalocean.com/mariadb/repo/" (jinja "{{ mariadb__upstream_version }}") "/" (jinja "{{ ansible_distribution | lower }}"))
  (mariadb__base_packages (list))
  (mariadb__packages (list))
  (mariadb__packages_map 
    (mariadb (list
        "mariadb-client"))
    (mariadb_upstream (list
        "mariadb-client"))
    (mysql-5.6_galera-3 (list
        "mysql-wsrep-client-5.6"))
    (mysql-5.7_galera-3 (list
        "mysql-wsrep-client-5.7"))
    (percona-8.0 (list
        "percona-server-client"))
    (percona-5.7 (list
        "percona-server-client-5.7")))
  (mariadb__client_charset_options 
    (default_character_set "utf8mb4"))
  (mariadb__client_remote_host_options (list
      
      (name "remote-host-options")
      (state (jinja "{{ \"present\"
               if (not mariadb__register_version.stdout | d(False))
               else \"absent\" }}"))
      (options (list
          
          (name "remote-host-not-tunnel")
          (state (jinja "{{ \"present\"
                   if (mariadb__register_tunnel.rc | d() != 0)
                   else \"absent\" }}"))
          (options 
            (host (jinja "{{ mariadb__server }}"))
            (port (jinja "{{ mariadb__port }}")))
          
          (name "remote-host-tunnel")
          (state (jinja "{{ \"present\"
                   if (mariadb__register_tunnel.rc | d() == 0)
                   else \"absent\" }}"))
          (options 
            (host "127.0.0.1")
            (port (jinja "{{ mariadb__port }}")))
          
          (name "pki-options")
          (comment "Support for SSL connections")
          (state (jinja "{{ \"present\" if mariadb__pki | bool else \"absent\" }}"))
          (options 
            (ssl null)
            (ssl_ca (jinja "{{ mariadb__pki_path + \"/\" + mariadb__pki_realm + \"/\" + mariadb__pki_ca }}"))
            (ssl_cert (jinja "{{ mariadb__pki_path + \"/\" + mariadb__pki_realm + \"/\" + mariadb__pki_crt }}"))
            (ssl_key (jinja "{{ mariadb__pki_path + \"/\" + mariadb__pki_realm + \"/\" + mariadb__pki_key }}"))
            (ssl_cipher (jinja "{{ mariadb__pki_cipher }}")))))))
  (mariadb__client_options (list
      
      (section "client")
      (options (list
          (jinja "{{ mariadb__client_charset_options }}")
          (jinja "{{ mariadb__client_remote_host_options }}")
          (jinja "{{ mariadb__options }}")))))
  (mariadb__options )
  (mariadb__client_cnf_file (jinja "{{ \"/etc/mysql/mariadb.conf.d/90-client.cnf\"
                              if (mariadb__register_confd.stat.exists | bool)
                              else \"/etc/mysql/conf.d/zz-client.cnf\" }}"))
  (mariadb__pki (jinja "{{ (True
                   if (ansible_local.pki.enabled | d() and
                       mariadb__pki_realm in ansible_local.pki.known_realms)
                   else False) | bool }}"))
  (mariadb__pki_path (jinja "{{ ansible_local.pki.base_path | d(\"/etc/pki\") }}"))
  (mariadb__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (mariadb__pki_ca "CA.crt")
  (mariadb__pki_crt "default.crt")
  (mariadb__pki_key "default.key")
  (mariadb__pki_cipher "DHE-RSA-AES256-SHA")
  (mariadb__default_privileges "True")
  (mariadb__default_privileges_aux "True")
  (mariadb__default_privileges_grant "ALL")
  (mariadb__password_length "48")
  (mariadb__databases (list))
  (mariadb__dependent_databases (list))
  (mariadb__users (list))
  (mariadb__dependent_users (list))
  (mariadb__keyring__dependent_apt_keys (list
      (jinja "{{ mariadb__apt_key }}")))
  (mariadb__python__dependent_packages3 (list
      "python3-mysqldb"))
  (mariadb__python__dependent_packages2 (list
      "python-mysqldb")))
