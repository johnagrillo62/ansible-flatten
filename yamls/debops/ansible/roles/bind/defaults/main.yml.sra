(playbook "debops/ansible/roles/bind/defaults/main.yml"
  (bind__features (list
      "dns"
      "dnssec"
      (jinja "{{ \"dot\" if bind__pki else [] }}")
      (jinja "{{ \"doh_https\"
        if (bind__pki
            and not ansible_local.nginx.enabled | d(False)
            and not ansible_local.apache.enabled | d(False)
            and \"debops_service_nginx\" not in group_names
            and \"debops_service_apache\" not in group_names)
        else [] }}")
      (jinja "{{ \"doh_proxy\"
        if (bind__pki and ansible_local.nginx.enabled | d(False)
            or \"debops_service_nginx\" in group_names)
        else [] }}")
      (jinja "{{ \"stats_proxy\"
        if (bind__pki and ansible_local.nginx.enabled | d(False)
            or \"debops_service_nginx\" in group_names)
        else [] }}")))
  (bind__version (jinja "{{ ansible_local.bind.version | d(\"0.0.0\") }}"))
  (bind__fqdn "dns." (jinja "{{ bind__domain }}"))
  (bind__domain (jinja "{{ ansible_domain }}"))
  (bind__blocked_domains (list
      "use-application-dns.net"))
  (bind__user "bind")
  (bind__additional_groups (list
      "ssl-cert"))
  (bind__base_packages (list
      "bind9"
      "bind9-dnsutils"))
  (bind__packages (list))
  (bind__snapshot_enabled "True")
  (bind__snapshot_cron_jobs (list
      "daily"
      "weekly"
      "monthly"))
  (bind__dnssec_use_nsec3 "True")
  (bind__dnssec_script_enabled (jinja "{{ True if \"dnssec\" in bind__features else False }}"))
  (bind__dnssec_script_domains (list))
  (bind__dnssec_script_method "email")
  (bind__dnssec_script_default_configuration (list
      
      (name "method")
      (value (jinja "{{ bind__dnssec_script_method }}"))
      
      (name "log_file")
      (value "/var/log/debops-bind-rollkey.log")
      
      (name "email_to")
      (value (jinja "{{ ansible_local.core.admin_public_email[0]
               | d(\"root@\" + ansible_domain) }}"))
      
      (name "email_from")
      (value (jinja "{{ \"noreply@\" + ansible_domain }}"))
      
      (name "email_host")
      (value "localhost")
      
      (name "email_port")
      (value "25")
      
      (name "email_subject")
      (value "BIND DNSSEC key updates")
      
      (name "external_script")
      (value "/usr/local/sbin/debops-bind-rollkey-action")
      
      (name "zones")
      (value (jinja "{{ bind__dnssec_script_domains }}"))))
  (bind__dnssec_script_configuration (list))
  (bind__dnssec_script_group_configuration (list))
  (bind__dnssec_script_host_configuration (list))
  (bind__dnssec_script_combined_configuration (jinja "{{
  bind__dnssec_script_default_configuration
  + bind__dnssec_script_configuration
  + bind__dnssec_script_group_configuration
  + bind__dnssec_script_host_configuration }}"))
  (bind__doh_endpoints (list
      "/dns-query"))
  (bind__doh_proxy_port "83")
  (bind__doh_proxy_allow (jinja "{%- set cidrs = [] -%}") " " (jinja "{%- for item in ((ansible_interfaces
                  | map('extract', ansible_facts, 'ipv4')
                  | select('defined') | list | flatten) +
                 (ansible_interfaces
                  | map('extract', ansible_facts, 'ipv6')
                  | select('defined') | list | flatten)) | d([]) -%}") "
" (jinja "{%-   if item.address | d() and not item.address | ansible.utils.ipaddr('link-local') -%}") " " (jinja "{%-     set address = item.address -%}") " " (jinja "{%-     set prefix_or_mask = item.prefix | d(item.netmask) -%}") " " (jinja "{%-     set cidr = '{}/{}'.format(address, prefix_or_mask) -%}") " " (jinja "{%-     set _ = cidrs.append(cidr | ansible.utils.ipaddr('network/prefix')) -%}") " " (jinja "{%-   endif -%}") " " (jinja "{%- endfor -%}") " " (jinja "{{ cidrs | unique | sort }}") "

                                                                 # ]]]")
  (bind__doh_proxy_access_policy "")
  (bind__stats_proxy_port "84")
  (bind__stats_proxy_allow (jinja "{{ [\"127.0.0.1\", \"::1\"]
                             + ansible_all_ipv4_addresses | d([])
                             + (ansible_all_ipv6_addresses | d([])
                                | difference(ansible_all_ipv6_addresses | d([])
                                             | ansible.utils.ipaddr(\"link-local\")))
                             | unique | sort }}"))
  (bind__stats_proxy_access_policy "")
  (bind__default_configuration (list
      
      (name "debops-tls")
      (option "tls \"debops-tls\"")
      (comment "TLS options for DoH and DoT")
      (state (jinja "{{ \"present\" if bind__features | intersect([\"dot\", \"doh_https\"])
               else \"absent\" }}"))
      (options (list
          
          (name "ciphers")
          (value "\"" (jinja "{{ bind__tls_cipher_list }}") "\"")
          
          (name "dhparam-file")
          (value "\"" (jinja "{{ bind__tls_dh_file }}") "\"")
          (state (jinja "{{ \"present\" if bind__dhparam else \"absent\" }}"))
          
          (name "cert-file")
          (value "\"" (jinja "{{ bind__pki_path + \"/\" + bind__pki_realm + \"/\" + bind__pki_crt }}") "\"")
          
          (name "key-file")
          (value "\"" (jinja "{{ bind__pki_path + \"/\" + bind__pki_realm + \"/\" + bind__pki_key }}") "\"")
          
          (name "protocols")
          (options (list
              
              (name "protocols")
              (raw (jinja "{{ bind__tls_protocols | d([]) | join(\"; \") }}") ";")))
          
          (name "session-tickets")
          (value "no")
          
          (name "prefer-server-ciphers")
          (value "yes")
          
          (name "ca-file")
          (state "absent")
          
          (name "remote-hostname")
          (state "absent")))
      
      (name "http \"debops-http\"")
      (comment "DoH options")
      (state (jinja "{{ \"present\"
               if bind__features | intersect([\"doh_https\", \"doh_proxy\", \"doh_http\"])
               else \"absent\" }}"))
      (options (list
          
          (name "endpoints")
          (options (list
              
              (name "endpoints")
              (raw (jinja "{{ bind__doh_endpoints | map('regex_replace', '^(.*)$', '\\\"\\\\1\\\";') | join(' ') }}"))))
          
          (name "listener-clients")
          (state "absent")
          
          (name "streams-per-connection")
          (state "absent")))
      
      (name "statistics-channels")
      (comment "Make stats available via a reverse proxy")
      (state (jinja "{{ \"present\" if \"stats_proxy\" in bind__features else \"absent\" }}"))
      (options (list
          
          (name "statistics-localhost")
          (raw "inet 127.0.0.1 port " (jinja "{{ bind__stats_proxy_port }}") " allow { any; };")))
      
      (name "options")
      (options (list
          
          (name "directory")
          (comment "For storage of non-authoritative/secondary zones")
          (value "\"/var/cache/bind\"")
          
          (name "forwarders")
          (state "absent")
          (options (list
              
              (name "forwarder-1")
              (raw "1.1.1.1;")))
          
          (name "zone-statistics")
          (comment "Collect stats for all zones, available via rndc stats")
          (value "yes")
          
          (name "listen-dns-v4")
          (option "listen-on")
          (comment "Regular DNS (Do53) - IPv4")
          (state (jinja "{{ \"present\" if \"dns\" in bind__features else \"absent\" }}"))
          (options (list
              
              (name "any")
              (raw "any;")))
          
          (name "listen-dot-v4")
          (option "listen-on port 853 tls debops-tls")
          (comment "DNS over TLS (DoT) - IPv4")
          (state (jinja "{{ \"present\" if \"dot\" in bind__features else \"absent\" }}"))
          (options (list
              
              (name "any")
              (raw "any;")))
          
          (name "listen-doh-https-v4")
          (option "listen-on port 443 tls debops-tls http debops-http")
          (comment "DNS over HTTPS (DoH) - IPv4")
          (state (jinja "{{ \"present\" if \"doh_https\" in bind__features else \"absent\" }}"))
          (options (list
              
              (name "any")
              (raw "any;")))
          
          (name "listen-doh-http-v4")
          (option "listen-on port 80 tls none http debops-http")
          (comment "DNS over HTTP (DoH) - IPv4")
          (state (jinja "{{ \"present\" if \"doh_http\" in bind__features else \"absent\" }}"))
          (options (list
              
              (name "localhost")
              (raw "any;")))
          
          (name "listen-doh-proxy-v4")
          (option "listen-on port " (jinja "{{ bind__doh_proxy_port | d(\"83\") }}") " tls none http debops-http")
          (comment "DNS over HTTP (DoH), behind proxy - IPv4")
          (state (jinja "{{ \"present\" if \"doh_proxy\" in bind__features else \"absent\" }}"))
          (options (list
              
              (name "localhost")
              (raw "127.0.0.1;")))
          
          (name "listen-dns-v6")
          (option "listen-on-v6")
          (comment "Regular DNS (Do53) - IPv6")
          (state (jinja "{{ \"present\" if \"dns\" in bind__features else \"absent\" }}"))
          (options (list
              
              (name "any")
              (raw "any;")))
          
          (name "listen-dns-dot-v6")
          (option "listen-on-v6 port 853 tls debops-tls")
          (comment "DNS over TLS (DoT) - IPv6")
          (state (jinja "{{ \"present\" if \"dot\" in bind__features else \"absent\" }}"))
          (options (list
              
              (name "any")
              (raw "any;")))
          
          (name "listen-doh-https-v6")
          (option "listen-on-v6 port 443 tls debops-tls http debops-http")
          (comment "DNS over HTTPS (DoH) - IPv6")
          (state (jinja "{{ \"present\" if \"doh_https\" in bind__features else \"absent\" }}"))
          (options (list
              
              (name "any")
              (raw "any;")))
          
          (name "listen-doh-http-v6")
          (option "listen-on-v6 port 80 tls none http debops-http")
          (state (jinja "{{ \"present\" if \"doh_http\" in bind__features else \"absent\" }}"))
          (comment "DNS over HTTP (DoH) - IPv6")
          (options (list
              
              (name "localhost")
              (raw "any;")))
          
          (name "listen-doh-proxy-v6")
          (option "listen-on-v6 port " (jinja "{{ bind__doh_proxy_port | d(\"83\") }}") " tls none http debops-http")
          (comment "DNS over HTTP (DoH), behind proxy - IPv6")
          (state (jinja "{{ \"present\" if \"doh_proxy\" in bind__features else \"absent\" }}"))
          (options (list
              
              (name "localhost")
              (raw "::1;")))
          
          (name "qname-minimization")
          (comment "Perform strict QNAME minimization (RFC7816)")
          (value "strict")
          (state "comment")
          
          (name "dnssec-validation")
          (comment "This is for when BIND acts as a resolver")
          (value "auto")
          
          (name "key-directory")
          (comment "For storage of DNSSEC keys")
          (value "\"/var/lib/bind/dnssec-keys\"")
          (state (jinja "{{ \"present\" if \"dnssec\" in bind__features else \"absent\" }}"))
          
          (name "dnssec-dnskey-kskonly")
          (comment "https://gitlab.isc.org/isc-projects/bind9/-/issues/1316")
          (state (jinja "{{ \"present\" if \"dnssec\" in bind__features else \"absent\" }}"))
          (value "yes")
          
          (name "response-policy-blocked-domains")
          (raw "response-policy { zone \"rpz.local\"; } break-dnssec yes;")
          (state (jinja "{{ \"present\" if bind__blocked_domains | d([]) | length > 0 else \"absent\" }}"))
          
          (name "max-udp-size")
          (comment "https://www.isc.org/blogs/dns-flag-day-2020-2/")
          (value "1220")
          
          (name "edns-udp-size")
          (comment "https://www.isc.org/blogs/dns-flag-day-2020-2/")
          (value "1220")
          
          (name "serial-update-method")
          (comment "Make the serial numbers meaningful to a human admin")
          (value "date")))
      
      (name "logging")
      (state "absent")
      (options (list
          
          (name "channel client_spam_channel")
          (options (list
              
              (name "file")
              (value "\"/var/log/named/named_recent_client.log\" versions 3 size 5m suffix increment")
              
              (name "severity")
              (value "info")
              
              (name "print-time")
              (value "yes")
              
              (name "print-category")
              (value "yes")
              
              (name "print-severity")
              (value "yes")
              
              (name "buffered")
              (value "no")))
          
          (name "channel server_spam_channel")
          (options (list
              
              (name "file")
              (value "\"/var/log/named/named_recent_server.log\" versions 3 size 5m suffix increment")
              
              (name "severity")
              (value "info")
              
              (name "print-time")
              (value "yes")
              
              (name "print-category")
              (value "yes")
              
              (name "print-severity")
              (value "yes")
              
              (name "buffered")
              (value "no")))
          
          (name "category client")
          (options (list
              
              (name "channel-1")
              (raw "client_spam_channel;")))
          
          (name "category query-errors")
          (options (list
              
              (name "channel-1")
              (raw "client_spam_channel;")))
          
          (name "category resolver")
          (options (list
              
              (name "channel-1")
              (raw "client_spam_channel;")))
          
          (name "category security")
          (options (list
              
              (name "channel-1")
              (raw "client_spam_channel;")))
          
          (name "category spill")
          (options (list
              
              (name "channel-1")
              (raw "client_spam_channel;")))
          
          (name "category cname")
          (options (list
              
              (name "channel-1")
              (raw "server_spam_channel;")))
          
          (name "category edns-disabled")
          (options (list
              
              (name "channel-1")
              (raw "server_spam_channel;")))
          
          (name "category lame-servers")
          (options (list
              
              (name "channel-1")
              (raw "server_spam_channel;")))))
      
      (name "generated-keys")
      (comment "Keys defined by the Ansible role")
      (state (jinja "{{ \"present\"
               if bind__combined_keys
                  | flatten
                  | debops.debops.parse_kv_items
                  | selectattr(\"state\", \"equalto\", \"present\")
                  | length > 0
               else \"absent\" }}"))
      (autovalue "keys")
      
      (name "acl debops-acl")
      (state (jinja "{{ \"present\"
               if \"debops-key\" in (bind__combined_keys
                                   | flatten
                                   | debops.debops.parse_kv_items
                                   | selectattr(\"state\", \"equalto\", \"present\")
                                   | map(attribute=\"name\"))
               else \"absent\" }}"))
      (options (list
          
          (name "debops-key")
          (raw "key debops-key;")))
      
      (name "dnssec-policy-csk")
      (option "dnssec-policy \"csk\"")
      (comment "Single CSK without rollover (BINDs default policy)")
      (state (jinja "{{ \"present\" if \"dnssec\" in bind__features else \"absent\" }}"))
      (options (list
          
          (name "keys")
          (options (list
              
              (name "csk")
              (value "key-directory lifetime unlimited algorithm ecdsap256sha256")))
          
          (name "nsec3param")
          (comment "If you consider changing these values, first read:
https://datatracker.ietf.org/doc/html/draft-ietf-dnsop-nsec3-guidance-10#section-3.1
")
          (state (jinja "{{ \"present\" if bind__dnssec_use_nsec3 | d(False) else \"absent\" }}"))
          (value "iterations 0 optout no salt-length 0")
          
          (name "dnskey-ttl")
          (comment "Key timings")
          (separator "True")
          (value "3600")
          
          (name "publish-safety")
          (value "1h")
          
          (name "retire-safety")
          (value "1h")
          
          (name "purge-keys")
          (value "P90D")
          
          (name "signatures-refresh")
          (comment "Signature timings")
          (separator "True")
          (value "5d")
          
          (name "signatures-validity")
          (value "14d")
          
          (name "signatures-validity-dnskey")
          (value "14d")
          
          (name "max-zone-ttl")
          (comment "Zone parameters")
          (separator "True")
          (value "86400")
          
          (name "zone-propagation-delay")
          (value "300")
          
          (name "parent-ds-ttl")
          (comment "Parent parameters")
          (separator "True")
          (value "86400")
          
          (name "parent-propagation-delay")
          (value "1h")))
      
      (name "dnssec-policy-csk-rollover")
      (option "dnssec-policy \"csk-rollover\"")
      (comment "Single CSK with rollover")
      (state (jinja "{{ \"present\" if \"dnssec\" in bind__features else \"absent\" }}"))
      (options (list
          
          (name "keys")
          (options (list
              
              (name "csk")
              (value "key-directory lifetime 365d algorithm ecdsap256sha256")))
          
          (name "nsec3param")
          (comment "If you consider changing these values, first read:
https://datatracker.ietf.org/doc/html/draft-ietf-dnsop-nsec3-guidance-10#section-3.1
")
          (state (jinja "{{ \"present\" if bind__dnssec_use_nsec3 | d(False) else \"absent\" }}"))
          (value "iterations 0 optout no salt-length 0")
          
          (name "dnskey-ttl")
          (comment "Key timings")
          (separator "True")
          (value "3600")
          
          (name "publish-safety")
          (value "1h")
          
          (name "retire-safety")
          (value "1h")
          
          (name "purge-keys")
          (value "P90D")
          
          (name "signatures-refresh")
          (comment "Signature timings")
          (separator "True")
          (value "5d")
          
          (name "signatures-validity")
          (value "14d")
          
          (name "signatures-validity-dnskey")
          (value "14d")
          
          (name "max-zone-ttl")
          (comment "Zone parameters")
          (separator "True")
          (value "86400")
          
          (name "zone-propagation-delay")
          (value "300")
          
          (name "parent-ds-ttl")
          (comment "Parent parameters")
          (separator "True")
          (value "86400")
          
          (name "parent-propagation-delay")
          (value "1h")))
      
      (name "dnssec-policy-kskzsk")
      (option "dnssec-policy \"kskzsk\"")
      (comment "Separate KSK and ZSK without rollover")
      (state (jinja "{{ \"present\" if \"dnssec\" in bind__features else \"absent\" }}"))
      (options (list
          
          (name "keys")
          (options (list
              
              (name "ksk")
              (value "key-directory lifetime unlimited algorithm ecdsap256sha256")
              
              (name "zsk")
              (value "key-directory lifetime unlimited algorithm ecdsap256sha256")))
          
          (name "nsec3param")
          (comment "If you consider changing these values, first read:
https://datatracker.ietf.org/doc/html/draft-ietf-dnsop-nsec3-guidance-10#section-3.1
")
          (state (jinja "{{ \"present\" if bind__dnssec_use_nsec3 | d(False) else \"absent\" }}"))
          (value "iterations 0 optout no salt-length 0")
          
          (name "dnskey-ttl")
          (comment "Key timings")
          (separator "True")
          (value "3600")
          
          (name "publish-safety")
          (value "1h")
          
          (name "retire-safety")
          (value "1h")
          
          (name "purge-keys")
          (value "P90D")
          
          (name "signatures-refresh")
          (comment "Signature timings")
          (separator "True")
          (value "5d")
          
          (name "signatures-validity")
          (value "14d")
          
          (name "signatures-validity-dnskey")
          (value "14d")
          
          (name "max-zone-ttl")
          (comment "Zone parameters")
          (separator "True")
          (value "86400")
          
          (name "zone-propagation-delay")
          (value "300")
          
          (name "parent-ds-ttl")
          (comment "Parent parameters")
          (separator "True")
          (value "86400")
          
          (name "parent-propagation-delay")
          (value "1h")))
      
      (name "dnssec-policy-kskzsk-rollover")
      (option "dnssec-policy \"kskzsk-rollover\"")
      (comment "Separate KSK and ZSK with rollover (the traditional policy)")
      (state (jinja "{{ \"present\" if \"dnssec\" in bind__features else \"absent\" }}"))
      (options (list
          
          (name "keys")
          (options (list
              
              (name "ksk")
              (value "key-directory lifetime 365d algorithm ecdsap256sha256")
              
              (name "zsk")
              (value "key-directory lifetime 60d algorithm ecdsap256sha256")))
          
          (name "nsec3param")
          (comment "If you consider changing these values, first read:
https://datatracker.ietf.org/doc/html/draft-ietf-dnsop-nsec3-guidance-10#section-3.1
")
          (state (jinja "{{ \"present\" if bind__dnssec_use_nsec3 | d(False) else \"absent\" }}"))
          (value "iterations 0 optout no salt-length 0")
          
          (name "dnskey-ttl")
          (comment "Key timings")
          (separator "True")
          (value "3600")
          
          (name "publish-safety")
          (value "1h")
          
          (name "retire-safety")
          (value "1h")
          
          (name "purge-keys")
          (value "P90D")
          
          (name "signatures-refresh")
          (comment "Signature timings")
          (separator "True")
          (value "5d")
          
          (name "signatures-validity")
          (value "14d")
          
          (name "signatures-validity-dnskey")
          (value "14d")
          
          (name "max-zone-ttl")
          (comment "Zone parameters")
          (separator "True")
          (value "86400")
          
          (name "zone-propagation-delay")
          (value "300")
          
          (name "parent-ds-ttl")
          (comment "Parent parameters")
          (separator "True")
          (value "86400")
          
          (name "parent-propagation-delay")
          (value "1h")))
      
      (name "generated-zones")
      (comment "Views/zones defined by the Ansible role")
      (autovalue "zones")
      (weight "10000")))
  (bind__configuration (list))
  (bind__group_configuration (list))
  (bind__host_configuration (list))
  (bind__combined_configuration (jinja "{{ bind__default_configuration
                                   + bind__configuration
                                   + bind__group_configuration
                                   + bind__host_configuration }}"))
  (bind__default_keys (list
      
      (name "debops-key")
      (algorithm "hmac-sha512")
      (type "tsig")))
  (bind__keys (list))
  (bind__group_keys (list))
  (bind__host_keys (list))
  (bind__combined_keys (jinja "{{ bind__default_keys
                          + bind__keys
                          + bind__group_keys
                          + bind__host_keys }}"))
  (bind__default_zone_ttl "1D")
  (bind__default_zone_soa_primary (jinja "{{ ansible_fqdn | regex_replace(\"\\.*$\", \".\") }}"))
  (bind__default_zone_soa_email (jinja "{{ \"hostmaster.\" + ansible_domain + \".\" }}"))
  (bind__default_zone_soa_serial "1")
  (bind__default_zone_soa_refresh "1D")
  (bind__default_zone_soa_retry "2H")
  (bind__default_zone_soa_expire "1000H")
  (bind__default_zone_soa_neg_ttl "2D")
  (bind__default_zones (list
      
      (name "rpz.local")
      (force "True")
      (comment "Domain blocklist")
      (state (jinja "{{ \"present\" if bind__blocked_domains | d([]) | length > 0 else \"absent\" }}"))
      (options (list
          
          (name "type")
          (value "master")
          
          (name "file")
          (autovalue "zone_file_path")))
      (content (jinja "{{ [\"@	IN NS localhost.\"]
                 + bind__blocked_domains | d([]) | map(\"regex_replace\", \"^(.*)$\", \"\\1 CNAME .\")
              }}"))))
  (bind__zones (list))
  (bind__group_zones (list))
  (bind__host_zones (list))
  (bind__combined_zones (jinja "{{ bind__default_zones
                           + bind__zones
                           + bind__group_zones
                           + bind__host_zones }}"))
  (bind__default_generic_zones (list
      
      (name ".")
      (comment "prime the server with knowledge of the root servers")
      (options (list
          
          (name "type")
          (value "hint")
          
          (name "file")
          (value "\"/usr/share/dns/root.hints\"")))
      
      (name "localhost")
      (comment "be authoritative for the localhost forward zone (RFC1912, 4.1)")
      (options (list
          
          (name "type")
          (value "master")
          
          (name "file")
          (value "\"/etc/bind/db.local\"")))
      
      (name "127.in-addr.arpa")
      (comment "be authoritative for the localhost reverse zone (RFC1912, 4.1)")
      (options (list
          
          (name "type")
          (value "master")
          
          (name "file")
          (value "\"/etc/bind/db.127\"")))
      
      (name "0.in-addr.arpa")
      (comment "be authoritative for this network (RFC1912, 4.1)")
      (options (list
          
          (name "type")
          (value "master")
          
          (name "file")
          (value "\"/etc/bind/db.0\"")))
      
      (name "255.in-addr.arpa")
      (comment "be authoritative for the broadcast zone (RFC1912, 4.1)")
      (options (list
          
          (name "type")
          (value "master")
          
          (name "file")
          (value "\"/etc/bind/db.255\"")))))
  (bind__generic_zones (list))
  (bind__group_generic_zones (list))
  (bind__host_generic_zones (list))
  (bind__combined_generic_zones (jinja "{{ bind__default_generic_zones
                                   + bind__generic_zones
                                   + bind__group_generic_zones
                                   + bind__host_generic_zones }}"))
  (bind__pki (jinja "{{ True
               if (ansible_local.pki.enabled | d(False) | bool
                   and bind__version is version(\"9.18.0\", \">=\"))
               else False }}"))
  (bind__pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (bind__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (bind__pki_ca (jinja "{{ ansible_local.pki.ca | d(\"CA.crt\") }}"))
  (bind__pki_crt (jinja "{{ ansible_local.pki.crt | d(\"default.crt\") }}"))
  (bind__pki_key (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (bind__tls_ca_cert_dir "/etc/ssl/certs/")
  (bind__tls_protocols (list
      "TLSv1.3"))
  (bind__tls_cipher_list "HIGH:!kRSA:!aNULL:!eNULL:!RC4:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!SHA1:!SHA256:!SHA384")
  (bind__pki_hook_name "bind")
  (bind__pki_hook_path (jinja "{{ ansible_local.pki.hooks | d(\"/etc/pki/hooks\") }}"))
  (bind__pki_hook_action "reload")
  (bind__dhparam (jinja "{{ ansible_local.dhparam.enabled | d(False) }}"))
  (bind__dhparam_set "default")
  (bind__tls_dh_file (jinja "{{ ansible_local.dhparam[bind__dhparam_set] | d(\"\") }}"))
  (bind__tcp_ports (list
      (jinja "{{ \"domain\" if \"dns\" in bind__features else [] }}")
      (jinja "{{ \"domain-s\" if \"dot\" in bind__features else [] }}")
      (jinja "{{ \"http\" if \"doh_http\" in bind__features else [] }}")
      (jinja "{{ \"https\" if \"doh_https\" in bind__features else [] }}")))
  (bind__udp_ports (list
      (jinja "{{ \"domain\" if \"dns\" in bind__features else [] }}")))
  (bind__accept_any (jinja "{{ True
                      if bind__features
                         | intersect([\"dns\", \"dot\", \"doh_http\", \"doh_https\"])
                      else False }}"))
  (bind__deny (list))
  (bind__group_deny (list))
  (bind__host_deny (list))
  (bind__allow (list))
  (bind__group_allow (list))
  (bind__host_allow (list))
  (bind__ferm__dependent_rules (list
      
      (name "reject_bind_tcp")
      (type "accept")
      (protocol "tcp")
      (dport (jinja "{{ q(\"flattened\", bind__tcp_ports) }}"))
      (multiport "True")
      (saddr (jinja "{{ bind__deny + bind__group_deny + bind__host_deny }}"))
      (weight "45")
      (by_role "debops.bind")
      (target "REJECT")
      (rule_state (jinja "{{ \"present\"
                    if (bind__deny + bind__group_deny + bind__host_deny)
                    else \"absent\" }}"))
      
      (name "reject_bind_udp")
      (type "accept")
      (protocol "udp")
      (dport (jinja "{{ q(\"flattened\", bind__udp_ports) }}"))
      (multiport "True")
      (saddr (jinja "{{ bind__deny + bind__group_deny + bind__host_deny }}"))
      (weight "45")
      (by_role "debops.bind")
      (target "REJECT")
      (rule_state (jinja "{{ \"present\"
                    if (bind__deny + bind__group_deny + bind__host_deny)
                    else \"absent\" }}"))
      
      (name "accept_bind_tcp")
      (type "accept")
      (protocol "tcp")
      (dport (jinja "{{ q(\"flattened\", bind__tcp_ports) }}"))
      (multiport "True")
      (saddr (jinja "{{ bind__allow + bind__group_allow + bind__host_allow }}"))
      (accept_any (jinja "{{ bind__accept_any }}"))
      (weight "50")
      (by_role "debops.bind")
      
      (name "accept_bind_udp")
      (type "accept")
      (protocol "udp")
      (dport (jinja "{{ q(\"flattened\", bind__udp_ports) }}"))
      (multiport "True")
      (saddr (jinja "{{ bind__allow + bind__group_allow + bind__host_allow }}"))
      (accept_any (jinja "{{ bind__accept_any }}"))
      (weight "50")
      (by_role "debops.bind")))
  (bind__nginx__dependent_servers (list
      
      (name (jinja "{{ bind__fqdn }}"))
      (filename "debops.bind")
      (by_role "debops.bind")
      (type "default")
      (webroot_create "False")
      (state (jinja "{{ \"present\"
               if bind__features | intersect([\"doh_proxy\", \"stats_proxy\"])
               else \"absent\" }}"))
      (root "False")
      (maintenance "False")
      (toplevel_options (jinja "{% if \"doh_proxy\" in bind__features | d([]) %}") "
# address and port of the DoH server, serving unencrypted HTTP/2
upstream http2-doh {
        server 127.0.0.1:" (jinja "{{ bind__doh_proxy_port }}") ";
}" (jinja "{% endif %}"))
      (location_list (jinja "{%- set locations =  [{
          \"pattern\": \"/\",
          \"options\": \"proxy_pass http://127.0.0.1:\"
                      + bind__stats_proxy_port | string + \";\",
          \"allow\": bind__stats_proxy_allow,
          \"access_policy\": bind__stats_proxy_access_policy,
          \"enabled\": True if \"stats_proxy\" in bind__features else False
    }] -%}") "
" (jinja "{%- for endpoint in bind__doh_endpoints | d([]) -%}") " " (jinja "{%-   set _ = locations.append({
                \"pattern\": endpoint,
                \"options\": \"grpc_pass grpc://http2-doh;\",
                \"allow\": bind__doh_proxy_allow,
                \"access_policy\": bind__doh_proxy_access_policy,
                \"enabled\": True if \"doh_proxy\" in bind__features else False
      }) -%}") "
" (jinja "{%- endfor -%}") " " (jinja "{{ locations }}") "

                                                             # ]]]")))
  (bind__logrotate__dependent_config (list
      
      (filename "debops-bind-rollkeys")
      (state (jinja "{{ \"present\"
                if (\"dnssec\" in bind__features and
                    bind__dnssec_script_enabled | d(False))
                else \"absent\" }}"))
      (sections (list
          
          (logs "/var/log/debops-bind-rollkey.log")
          (options "notifempty
missingok
yearly
rotate 10
compress
")
          (comment "BIND DNSSEC key rollover logs")))))
  (bind__apt_preferences__dependent_list (list
      
      (packages (list
          "bind9"
          "bind9-dnsutils"
          "bind9-libs"
          "bind9-utils"))
      (backports (list
          "bullseye"))
      (reason "Support for DNS-over-TLS/HTTPS")
      (by_role "debops.bind"))))
