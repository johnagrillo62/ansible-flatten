(playbook "debops/ansible/roles/resolved/defaults/main.yml"
  (resolved__enabled (jinja "{{ True
                       if (ansible_service_mgr == \"systemd\" and
                           resolved__fact_service_state == \"present\")
                       else False }}"))
  (resolved__deploy_state "absent")
  (resolved__resolv_conf "/run/systemd/resolve/stub-resolv.conf")
  (resolved__fallback_conf "00fallback-dns.conf")
  (resolved__dnssd_enabled "True")
  (resolved__base_packages (jinja "{{ [\"libnss-resolve\"]
                              if (ansible_distribution_release in
                                  ([\"stretch\", \"buster\", \"bullseye\",
                                    \"bionic\", \"focal\", \"jammy\"]))
                              else [\"systemd-resolved\", \"libnss-resolve\"] }}"))
  (resolved__packages (list))
  (resolved__skip_packages (list
      "resolvconf"
      "openresolv"))
  (resolved__version (jinja "{{ ansible_local.resolved.version | d(\"0\") }}"))
  (resolved__synthesize_hostname "False")
  (resolved__default_configuration (list
      
      (name "DNS")
      (value (list))
      (state "init")
      
      (name "FallbackDNS")
      (value (list))
      (state "init")
      
      (name "Domains")
      (value (list))
      (state "init")
      
      (name "DNSSEC")
      (value "False")
      (state "init")
      
      (name "DNSOverTLS")
      (value "False")
      (state "init")
      
      (name "MulticastDNS")
      (value (jinja "{{ resolved__dnssd_enabled | bool }}"))
      (state (jinja "{{ \"init\" if (resolved__dnssd_enabled | bool) else \"present\" }}"))
      
      (name "LLMNR")
      (value "True")
      (state "init")
      
      (name "Cache")
      (value "True")
      (state "init")
      
      (name "DNSStubListener")
      (value "True")
      (state "init")
      
      (name "DNSStubListenerExtra")
      (value "")
      (state "init")
      
      (name "ReadEtcHosts")
      (value "True")
      (state "init")
      
      (name "ResolveUnicastSingleLabel")
      (value "False")
      (state "init")))
  (resolved__configuration (list))
  (resolved__group_configuration (list))
  (resolved__host_configuration (list))
  (resolved__combined_configuration (jinja "{{ resolved__default_configuration
                                      + resolved__configuration
                                      + resolved__group_configuration
                                      + resolved__host_configuration }}"))
  (resolved__default_units (list
      
      (name "workstation.dnssd")
      (comment "Publish information about the host in mDNS")
      (raw "[Service]
Name=%H
Type=_workstation._tcp
Port=9
")
      (state "present")
      
      (name "ssh.dnssd")
      (comment "Publish information about the SSH service")
      (raw "[Service]
Name=%H
Type=_ssh._tcp
Port=22
")
      (state "present")
      
      (name "sftp-ssh.dnssd")
      (comment "Publish information about the SFTP service")
      (raw "[Service]
Name=%H
Type=_sftp-ssh._tcp
Port=22
")
      (state "present")))
  (resolved__units (list))
  (resolved__group_units (list))
  (resolved__host_units (list))
  (resolved__dependent_units (list))
  (resolved__combined_units (jinja "{{ resolved__default_units
                              + resolved__dependent_units
                              + resolved__units
                              + resolved__group_units
                              + resolved__host_units }}"))
  (resolved__etc_services__dependent_list (list
      
      (name "llmnr")
      (port "5355")
      (protocols (list
          "tcp"
          "udp"))))
  (resolved__dpkg_cleanup__dependent_packages (list
      
      (name "systemd-resolved")
      (ansible_fact "resolved")
      (state (jinja "{{ \"absent\"
               if (ansible_distribution_release in
                   ([\"stretch\", \"buster\", \"bullseye\",
                     \"bionic\", \"focal\", \"jammy\"]))
               else \"present\" }}")))))
