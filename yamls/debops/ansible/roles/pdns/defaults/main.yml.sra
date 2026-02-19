(playbook "debops/ansible/roles/pdns/defaults/main.yml"
  (pdns__base_packages (jinja "{{ [\"pdns-server\"]
                         + ([\"pdns-backend-pgsql\"]
                            if \"gpgsql\" in pdns__backends
                            else []) }}"))
  (pdns__packages (list))
  (pdns__allow (list
      "0.0.0.0/0"
      "::/0"))
  (pdns__local_address (jinja "{{ (ansible_all_ipv4_addresses
                          + ansible_all_ipv6_addresses)
                         | difference(ansible_all_ipv6_addresses | d([])
                                      | ansible.utils.ipaddr(\"link-local\")) }}"))
  (pdns__local_port "53")
  (pdns__primary "False")
  (pdns__secondary "False")
  (pdns__autosecondary "False")
  (pdns__resolver (jinja "{{ ansible_local.resolvconf.nameservers[0]
                     | d(ansible_dns.nameservers[0]) }}"))
  (pdns__backends (list
      "gpgsql"))
  (pdns__api (jinja "{{ True
               if \"debops_service_pdns_nginx\" in group_names
               else False }}"))
  (pdns__api_key (jinja "{{ lookup(\"password\", secret + \"/pdns/\" + ansible_fqdn
                          + \"/api_key chars=ascii_letters,digits length=22\")
                   if pdns__api
                   else \"\" }}"))
  (pdns__metrics (jinja "{{ pdns__api }}"))
  (pdns__http_port "16836")
  (pdns__nginx_fqdn "powerdns." (jinja "{{ ansible_domain }}"))
  (pdns__nginx_allow (list))
  (pdns__dnsupdate "True")
  (pdns__allow_dnsupdate_from (list))
  (pdns__postgresql_delegate_to (jinja "{{ ansible_local.postgresql.delegate_to
                                   | d(ansible_fqdn) }}"))
  (pdns__postgresql_server (jinja "{{ ansible_local.postgresql.server | d(\"localhost\") }}"))
  (pdns__postgresql_port (jinja "{{ ansible_local.postgresql.port | d(\"5432\") }}"))
  (pdns__postgresql_database "pdns")
  (pdns__postgresql_role "pdns")
  (pdns__postgresql_password (jinja "{{ lookup(\"password\", secret + \"/postgresql/\"
                                      + pdns__postgresql_delegate_to + \"/\"
                                      + pdns__postgresql_port + \"/credentials/\"
                                      + pdns__postgresql_role
                                      + \"/password chars=ascii_letters,digits \"
                                      + \"length=22\")
                               if \"gpgsql\" in pdns__backends
                               else \"\" }}"))
  (pdns__postgresql_schema "/usr/share/pdns-backend-pgsql/schema/schema.pgsql.sql")
  (pdns__postgresql_dnssec "True")
  (pdns__original_configuration (list
      
      (name "include-dir")
      (comment "Directory to scan for additional config files.")
      (value "/etc/powerdns/pdns.d")
      
      (name "launch")
      (comment "Which backends to launch and order to query them in.")
      (value "")
      
      (name "security-poll-suffix")
      (comment "Zone name from which to query security update notifications.")
      (value "")
      
      (name "setgid")
      (comment "Run as an unprivileged group instead of root. Explicitly configuring this
is no longer necessary since pdns 4.3.0.")
      (value "pdns")
      (state (jinja "{{ \"present\"
               if ansible_local.pdns.version is version(\"4.3.0\", \"<\")
               else \"absent\" }}"))
      
      (name "setuid")
      (comment "Run as an unprivileged user instead of root. Explicitly configuring this
is no longer necessary since pdns 4.3.0.")
      (value "pdns")
      (state (jinja "{{ \"present\"
               if ansible_local.pdns.version is version(\"4.3.0\", \"<\")
               else \"absent\" }}"))))
  (pdns__default_configuration (list
      
      (name "local-address")
      (comment "Local IP addresses to which we bind. Accepts IPv6 addresses since pdns
4.3.0.")
      (value (jinja "{{ (pdns__local_address if ansible_local.pdns.version is version(\"4.3.0\", \">=\")
                else (pdns__local_address | ansible.utils.ipv4)) | join(\",\") }}"))
      
      (name "local-ipv6")
      (comment "Local IPv6 addresses to which we bind. Will be deprecated in pdns 4.3.0
and removed in pdns 4.5.0.")
      (value (jinja "{{ pdns__local_address | ansible.utils.ipv6 | join(\",\") }}"))
      (state (jinja "{{ \"present\"
               if ansible_local.pdns.version is version(\"4.3.0\", \"<\")
               else \"absent\" }}"))
      
      (name "local-port")
      (comment "Local TCP and UDP port to bind to.")
      (value (jinja "{{ pdns__local_port }}"))
      
      (name "resolver")
      (comment "Recursive DNS server to use for ALIAS lookups and the internal stub
resolver. Only one address can be given.")
      (value (jinja "{{ pdns__resolver }}"))
      
      (name (jinja "{{ \"primary\"
              if ansible_local.pdns.version is version(\"4.5.0\", \">=\")
              else \"master\" }}"))
      (comment "Turn on primary operation. Note: the name of this setting was changed
with the release of pdns 4.5.0.")
      (value "True")
      (state (jinja "{{ \"present\" if pdns__primary else \"absent\" }}"))
      
      (name (jinja "{{ \"secondary\"
              if ansible_local.pdns.version is version(\"4.5.0\", \">=\")
              else \"slave\" }}"))
      (comment "Turn on secondary operation. Note: the name of this setting was changed
with the release of pdns 4.5.0.")
      (value "True")
      (state (jinja "{{ \"present\" if pdns__secondary else \"absent\" }}"))
      
      (name (jinja "{{ \"autosecondary\"
              if ansible_local.pdns.version is version(\"4.5.0\", \">=\")
              else \"superslave\"
                   if ansible_local.pdns.version is version(\"4.2.0\", \">=\")
                   else \"supermaster\" }}"))
      (comment "Turn on autosecondary operation. Note: the name of this setting was
changed with the release of pdns 4.2.0, and once more with the release of
pdns 4.5.0.")
      (value "True")
      (state (jinja "{{ \"present\" if pdns__autosecondary else \"absent\" }}"))
      
      (name "api")
      (comment "Enable/Disable the built-in webserver and HTTP API.")
      (value "True")
      (state (jinja "{{ \"present\" if pdns__api else \"absent\" }}"))
      
      (name "api-key")
      (comment "Static pre-shared authentication key for access to the REST API.")
      (value (jinja "{{ pdns__api_key }}"))
      (state (jinja "{{ \"present\" if pdns__api else \"absent\" }}"))
      
      (name "dnsupdate")
      (comment "Enable/Disable DNS update (RFC2136) support.")
      (value "True")
      (state (jinja "{{ \"present\" if pdns__dnsupdate else \"absent\" }}"))
      
      (name "allow-dnsupdate-from")
      (comment "Allow DNS updates from these IP ranges.")
      (value (jinja "{{ pdns__allow_dnsupdate_from | join(\",\") }}"))
      (state (jinja "{{ \"present\" if pdns__dnsupdate else \"absent\" }}"))
      
      (name "launch")
      (comment "Which backends to launch and order to query them in.")
      (value (jinja "{{ pdns__backends | join(\",\") }}"))
      
      (name "gpgsql-host")
      (comment "The PostgreSQL backend host.")
      (value (jinja "{{ pdns__postgresql_server }}"))
      (state (jinja "{{ \"present\" if \"gpgsql\" in pdns__backends else \"absent\" }}"))
      
      (name "gpgsql-port")
      (comment "The PostgreSQL backend port.")
      (value (jinja "{{ pdns__postgresql_port }}"))
      (state (jinja "{{ \"present\" if \"gpgsql\" in pdns__backends else \"absent\" }}"))
      
      (name "gpgsql-dbname")
      (comment "The PostgreSQL backend database name.")
      (value (jinja "{{ pdns__postgresql_database }}"))
      (state (jinja "{{ \"present\" if \"gpgsql\" in pdns__backends else \"absent\" }}"))
      
      (name "gpgsql-user")
      (comment "The username to authenticate to the PostgreSQL backend with.")
      (value (jinja "{{ pdns__postgresql_role }}"))
      (state (jinja "{{ \"present\" if \"gpgsql\" in pdns__backends else \"absent\" }}"))
      
      (name "gpgsql-password")
      (comment "The password to authenticate to the PostgreSQL backend with.")
      (value (jinja "{{ pdns__postgresql_password }}"))
      (state (jinja "{{ \"present\" if \"gpgsql\" in pdns__backends else \"absent\" }}"))
      
      (name "gpgsql-dnssec")
      (comment "Whether to enable DNSSEC processing for the PostgreSQL backend.")
      (value (jinja "{{ pdns__postgresql_dnssec }}"))
      (state (jinja "{{ \"present\" if \"gpgsql\" in pdns__backends else \"absent\" }}"))
      
      (name "webserver")
      (comment "Enable/Disable the built-in webserver and metrics endpoint.")
      (value "True")
      (state (jinja "{{ \"present\" if pdns__metrics else \"absent\" }}"))
      
      (name "webserver-port")
      (comment "The TCP port the built-in webserver will listen on.")
      (value (jinja "{{ pdns__http_port }}"))
      (state (jinja "{{ \"present\" if pdns__api or pdns__metrics else \"absent\" }}"))))
  (pdns__configuration (list))
  (pdns__group_configuration (list))
  (pdns__host_configuration (list))
  (pdns__combined_configuration (jinja "{{ pdns__original_configuration
                                  + pdns__default_configuration
                                  + pdns__configuration
                                  + pdns__group_configuration
                                  + pdns__host_configuration }}"))
  (pdns__etc_services__dependent_list (list
      
      (name "powerdns-http")
      (port (jinja "{{ pdns__http_port }}"))
      (protocols (list
          "tcp"))
      (comment "Added by debops.pdns Ansible role.")))
  (pdns__ferm__dependent_rules (list
      
      (name "pdns")
      (by_role "debops.pdns")
      (type "accept")
      (protocol (list
          "tcp"
          "udp"))
      (dport (list
          (jinja "{{ pdns__local_port }}")))
      (saddr (jinja "{{ pdns__allow }}"))))
  (pdns__nginx__dependent_servers (list
      
      (name (jinja "{{ pdns__nginx_fqdn }}"))
      (filename "debops.pdns")
      (allow (jinja "{{ pdns__nginx_allow }}"))
      (type "proxy")
      (proxy_pass "http://127.0.0.1:" (jinja "{{ pdns__http_port }}"))
      (webroot_create "False")))
  (pdns__postgresql__dependent_roles (list
      
      (role (jinja "{{ pdns__postgresql_role }}"))
      (port (jinja "{{ pdns__postgresql_port }}"))
      (password (jinja "{{ pdns__postgresql_password }}")))))
