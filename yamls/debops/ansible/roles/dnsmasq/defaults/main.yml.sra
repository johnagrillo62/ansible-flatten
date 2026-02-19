(playbook "debops/ansible/roles/dnsmasq/defaults/main.yml"
  (dnsmasq__base_packages (list
      "dnsmasq"))
  (dnsmasq__packages (list))
  (dnsmasq__dhcpv4 "True")
  (dnsmasq__dhcpv6 "True")
  (dnsmasq__default_interfaces (list
      
      (name "br2")
      (state (jinja "{{ \"present\"
               if (hostvars[inventory_hostname][\"ansible_br2\"] is defined)
               else \"absent\" }}"))))
  (dnsmasq__interfaces (list))
  (dnsmasq__combined_interfaces (jinja "{{ dnsmasq__default_interfaces
                                  + dnsmasq__interfaces }}"))
  (dnsmasq__hostname (jinja "{{ ansible_hostname }}"))
  (dnsmasq__base_domain (jinja "{{ ansible_domain }}"))
  (dnsmasq__base_domain_rebind_ok "True")
  (dnsmasq__etc_hosts (list))
  (dnsmasq__nameservers (list))
  (dnsmasq__public_dns "False")
  (dnsmasq__public_dns_allow (list))
  (dnsmasq__boot_enabled "True")
  (dnsmasq__boot_ipxe_enabled "True")
  (dnsmasq__boot_server "")
  (dnsmasq__boot_tftp_root "/srv/tftp")
  (dnsmasq__boot_filename (jinja "{{ \"menu.ipxe\" if dnsmasq__boot_ipxe_enabled | bool else \"pxelinux.0\" }}"))
  (dnsmasq__dhcp_hosts (list))
  (dnsmasq__dns_records (list))
  (dnsmasq__dhcp_dns_filename "host-resource-records.conf")
  (dnsmasq__default_configuration (list
      
      (name "00_main.conf")
      (state "absent")
      
      (name "global.conf")
      (options (list
          
          (name "conntrack")
          (comment "Enable connection tracking support for firewalls")
          (raw "conntrack
")
          (state "present")
          
          (name "enable-ra")
          (comment "Enable support for IPv6 Router Advertisements using dnsmasq")
          (raw "enable-ra
")
          (state "present")
          
          (name "bind-interfaces")
          (comment "Bind only to the network interfaces explicitly set in the
configuration. This is required to allow additional dnsmasq instances
managed by, for example, libvirt.
")
          (raw "bind-dynamic
")
          (state "present")
          
          (name "loopback-interface")
          (comment "Bind to loopback interface for local DNS queries")
          (raw "interface = lo
no-dhcp-interface = lo
")
          (state "present")
          
          (name "addn-hosts")
          (comment "Read hosts information from additional files or directories")
          (value (jinja "{{ dnsmasq__etc_hosts }}"))
          (state (jinja "{{ \"present\" if dnsmasq__etc_hosts | d() else \"absent\" }}"))))
      
      (name "consul.conf")
      (comment "Support for Consul Agent DNS service on localhost
Ref: https://www.consul.io/docs/agent/dns.html
")
      (raw "server = /consul/127.0.0.1#8600
")
      (state (jinja "{{ \"present\"
               if (ansible_local.consul.installed | d() | bool)
               else \"init\" }}"))
      
      (name "lxd-override")
      (filename "lxd")
      (comment "Tell any system-wide dnsmasq instance to make sure to bind to interfaces
instead of listening on 0.0.0.0
")
      (raw "bind-dynamic
except-interface = lxdbr0
")
      (state (jinja "{{ \"present\" if (ansible_distribution == \"Ubuntu\") else \"ignore\" }}"))
      
      (name "reserved-domains.conf")
      (options (list
          
          (name "reserved-domains")
          (comment "Do not forward the reserved top level domains to upstream nameservers
")
          (raw "# Ref: https://tools.ietf.org/html/rfc2606
local = /test/example/invalid/

# Ref: https://tools.ietf.org/html/rfc6762
local = /local/

# Ref: https://tools.ietf.org/html/rfc7686
local = /onion/
")
          (state "present")
          
          (name "private-domains")
          (comment "Do not forward the following private top level DNS names to upstream
DNS servers because RFC 6762 recommends not to use unregistered
top-level domains (https://tools.ietf.org/html/rfc6762#appendix-G)
")
          (raw "local = /intranet/internal/private/corp/home/lan/
")
          (state "present")))
      
      (name "block-dns-over-https")
      (comment "Blocking the 'use-application-dns.net' domain instructs the applications
that support DNS over HTTPS to not use it and rely on the system resolver
instead. This might be required for certain applications to support
access to internal services, resolve split-DNS correctly, etc.

Ref: https://support.mozilla.org/en-US/kb/canary-domain-use-application-dnsnet
")
      (raw "server = /use-application-dns.net/
")
      (state "present")
      
      (name "dns-global.conf")
      (options (list
          
          (name "localise-queries")
          (comment "Return localized answers to DNS queries from '/etc/hosts' depending
on the originating network interface
")
          (raw "localise-queries
")
          (state "present")
          
          (name "domain-needed")
          (comment "Never forward plain hostname queries for A or AAAA records to
upstream servers
")
          (raw "domain-needed
")
          (state "present")
          
          (name "expand-hosts")
          (comment "Expand short hostnames found in the '/etc/hosts' file to full FQDN
addresses
")
          (raw "expand-hosts
")
          (state "present")
          
          (name "stop-dns-rebind")
          (comment "Reject addresses from the upstream DNS nameservers which are located
in the private IP address ranges
")
          (raw "stop-dns-rebind
")
          (state "present")
          
          (name "rebind-localhost-ok")
          (comment "Skip rebinding checks for '127.0.0.0/8' IP address range. This range
is used by the realtime black hole (RBL) servers.
")
          (raw "rebind-localhost-ok
")
          (state "present")
          
          (name "rebind-local-domain-ok")
          (comment "Skip rebinding checks for local domain, in case dnsmasq is used as
a DNS cache and forwarder on a host that is a part of a network with
private IP address ranges, with a different DHCP/DNS server
maintaining the leases.
")
          (option "rebind-domain-ok")
          (value (jinja "{{ dnsmasq__base_domain }}"))
          (state (jinja "{{ \"present\"
                   if (dnsmasq__base_domain_rebind_ok | bool and
                       dnsmasq__base_domain | d())
                   else \"absent\" }}"))
          
          (name "rebind-parent-domain-ok")
          (comment "Skip rebinding checks for the parent domain if it has 4 or more
levels, which is most likely an internal domain on a network with
private IP address ranges.
")
          (option "rebind-domain-ok")
          (value (jinja "{{ dnsmasq__base_domain.split(\".\")[1:] | join(\".\") }}"))
          (state (jinja "{{ \"present\"
                   if (dnsmasq__base_domain_rebind_ok | bool and
                        dnsmasq__base_domain | d() and
                       (dnsmasq__base_domain.split(\".\") | length >= 4))
                   else \"absent\" }}"))
          
          (name "bogus-priv")
          (comment "Do not forward reverse DNS queries for private IP addresses to
upstream DNS servers.
When an LXC network support is enabled, this parameter is commented
out to allow revDNS queries. It will also be commented out when
upstream nameservers are located in a private network to allow DNS
queries to reach them. Ref: https://bugs.debian.org/461054
")
          (raw "bogus-priv
")
          (state (jinja "{{ \"comment\"
                   if ((ansible_local.lxc.net_domain | d()) or
                       (ansible_local.resolvconf.upstream_nameservers
                        | d(ansible_dns.nameservers)
                        | ansible.utils.ipaddr(\"private\")))
                   else \"present\" }}"))
          
          (name "resolv-file")
          (comment "Use custom list of nameservers instead of the system upstream
nameservers
")
          (value "/etc/resolvconf/upstream.conf")
          (state (jinja "{{ \"present\" if dnsmasq__nameservers | d() else \"absent\" }}"))))
      
      (name "lxc-net.conf")
      (comment "Support for resolving LXC container hosts that use the 'lxc-net' bridge
configuration
")
      (options (list
          
          (name "local")
          (value (jinja "{{ \"/\" + (ansible_local.lxc.net_domain | d(\"\"))
                   + \"/\" + ansible_local.lxc.net_address | d(\"\") }}"))
          
          (name "host-record")
          (value (jinja "{{ ansible_local.lxc.net_domain | d(\"\")
                   + \",\" + ansible_local.lxc.net_address | d(\"\") }}"))
          (state (jinja "{{ \"present\"
                   if (\".\" not in ansible_local.lxc.net_domain | d())
                   else \"absent\" }}"))
          
          (name "rev-server")
          (value (jinja "{{ ansible_local.lxc.net_subnet | d(\"\")
                   + \",\" + ansible_local.lxc.net_address | d(\"\") }}"))
          
          (name "rebind-domain-ok")
          (value (jinja "{{ ansible_local.lxc.net_domain | d(\"\") }}"))))
      (state (jinja "{{ \"present\"
               if (ansible_local.lxc.net_domain | d())
               else \"init\" }}"))
      
      (name "dhcp-boot.conf")
      (comment "This configuration file contains dnsmasq options related to booting
remote hosts using iPXE boot menu
")
      (options (list
          
          (name "dhcp-match-ipxe")
          (comment "Tag all DHCP requests with option 175 as coming from iPXE to avoid
recursive loops
")
          (option "dhcp-match")
          (value "set:ipxe,175")
          
          (name "dhcp-match-d-i")
          (comment "Tag all DHCP requests with 'd-i' vendor class as coming from the
Debian Installer
")
          (option "dhcp-match")
          (value "set:debian-installer,option:vendor-class,\"d-i\"")
          
          (name "vendor-match")
          (comment "Inspect the vendor class string and match the text to set the tag
Ref: https://tools.ietf.org/html/rfc4578#section-2.1
")
          (raw "dhcp-vendorclass = BIOS,PXEClient:Arch:00000
dhcp-vendorclass = UEFI32,PXEClient:Arch:00006
dhcp-vendorclass = UEFI,PXEClient:Arch:00007
dhcp-vendorclass = UEFI64,PXEClient:Arch:00009
")
          
          (name "boot-ipxe-local")
          (comment "Set the boot file name based on the matching tag from the vendor class (above)")
          (raw (jinja "{% if dnsmasq__boot_ipxe_enabled | bool %}") "
# Redirect non-iPXE clients to iPXE
dhcp-boot = tag:!ipxe,tag:BIOS,undionly.kpxe
dhcp-boot = tag:!ipxe,tag:UEFI32,i386-efi/ipxe.efi
dhcp-boot = tag:!ipxe,tag:UEFI,ipxe.efi
dhcp-boot = tag:!ipxe,tag:UEFI64,ipxe.efi

# Load the main menu in iPXE clients
" (jinja "{% endif %}") "
dhcp-boot = " (jinja "{{ dnsmasq__boot_filename }}") "
")
          (state (jinja "{{ \"absent\" if dnsmasq__boot_server | d() else \"present\" }}"))
          
          (name "boot-ipxe-remote")
          (comment "Set the boot file name based on the matching tag from the vendor class (above)")
          (raw (jinja "{% if dnsmasq__boot_ipxe_enabled | bool %}") "
# Redirect non-iPXE clients to iPXE
dhcp-boot = tag:!ipxe,tag:BIOS,undionly.kpxe,," (jinja "{{ dnsmasq__boot_server }}") "
dhcp-boot = tag:!ipxe,tag:UEFI32,i386-efi/ipxe.efi,," (jinja "{{ dnsmasq__boot_server }}") "
dhcp-boot = tag:!ipxe,tag:UEFI,ipxe.efi,," (jinja "{{ dnsmasq__boot_server }}") "
dhcp-boot = tag:!ipxe,tag:UEFI64,ipxe.efi,," (jinja "{{ dnsmasq__boot_server }}") "

# Load the main menu in iPXE clients
" (jinja "{% endif %}") "
dhcp-boot = " (jinja "{{ dnsmasq__boot_filename }}") ",," (jinja "{{ dnsmasq__boot_server }}") "
")
          (state (jinja "{{ \"present\" if dnsmasq__boot_server | d() else \"absent\" }}"))))
      (state (jinja "{{ \"present\" if dnsmasq__boot_enabled | bool else \"init\" }}"))))
  (dnsmasq__interface_configuration (jinja "{{ lookup(\"template\", \"lookup/dnsmasq__interface_configuration.j2\",
                                             convert_data=False) | from_yaml }}"))
  (dnsmasq__configuration (list))
  (dnsmasq__group_configuration (list))
  (dnsmasq__host_configuration (list))
  (dnsmasq__combined_configuration (jinja "{{ dnsmasq__default_configuration
                                     + dnsmasq__interface_configuration
                                     + dnsmasq__configuration
                                     + dnsmasq__group_configuration
                                     + dnsmasq__host_configuration }}"))
  (dnsmasq__ferm__dependent_rules (list
      
      (type "accept")
      (by_role "debops.dnsmasq")
      (name "dns")
      (weight "40")
      (protocol (list
          "udp"
          "tcp"))
      (saddr (jinja "{{ dnsmasq__public_dns_allow }}"))
      (dport (list
          "domain"))
      (accept_any "True")
      (interface (jinja "{{ []
                   if (dnsmasq__public_dns | bool)
                   else (dnsmasq__combined_interfaces | flatten | debops.debops.parse_kv_items
                         | selectattr(\"state\", \"equalto\", \"present\")
                         | map(attribute=\"name\") | list) }}"))
      (rule_state (jinja "{{ \"present\"
                    if ((dnsmasq__public_dns | bool) or
                        (dnsmasq__combined_interfaces | flatten | debops.debops.parse_kv_items
                            | selectattr(\"state\", \"equalto\", \"present\")
                            | map(attribute=\"name\") | list))
                    else \"absent\" }}"))
      
      (type "accept")
      (by_role "debops.dnsmasq")
      (name "dhcpv4")
      (weight "40")
      (protocol (list
          "udp"))
      (dport (list
          "bootps"))
      (interface (jinja "{{ dnsmasq__combined_interfaces | flatten | debops.debops.parse_kv_items
                   | selectattr(\"state\", \"equalto\", \"present\")
                   | map(attribute=\"name\") | list }}"))
      (rule_state (jinja "{{ \"present\"
                    if (dnsmasq__dhcpv4 | bool and
                        (dnsmasq__combined_interfaces | flatten | debops.debops.parse_kv_items
                         | selectattr(\"state\", \"equalto\", \"present\")
                         | map(attribute=\"name\") | list))
                    else \"absent\" }}"))
      
      (type "accept")
      (by_role "debops.dnsmasq")
      (name "dhcpv6")
      (weight "40")
      (saddr (list
          "fe80::/10"))
      (daddr (list
          "ff02::1:2"))
      (protocol (list
          "udp"))
      (sport (list
          "dhcpv6-client"))
      (dport (list
          "dhcpv6-server"))
      (interface (jinja "{{ dnsmasq__combined_interfaces | flatten | debops.debops.parse_kv_items
                   | selectattr(\"state\", \"equalto\", \"present\")
                   | map(attribute=\"name\") | list }}"))
      (rule_state (jinja "{{ \"present\"
                    if (dnsmasq__dhcpv6 | bool and
                        (dnsmasq__combined_interfaces | flatten | debops.debops.parse_kv_items
                         | selectattr(\"state\", \"equalto\", \"present\")
                         | map(attribute=\"name\") | list))
                    else \"absent\" }}"))
      
      (type "accept")
      (by_role "debops.dnsmasq")
      (filename "tftp")
      (weight "40")
      (dport (list
          "tftp"))
      (protocol (list
          "udp"))
      (interface (jinja "{{ dnsmasq__combined_interfaces | flatten | debops.debops.parse_kv_items
                   | selectattr(\"state\", \"equalto\", \"present\")
                   | map(attribute=\"name\") | list }}"))
      (rule_state (jinja "{{ \"present\"
                    if (dnsmasq__boot_enabled | bool and
                        (dnsmasq__combined_interfaces | flatten | debops.debops.parse_kv_items
                         | selectattr(\"state\", \"equalto\", \"present\")
                         | map(attribute=\"name\") | list))
                    else \"absent\" }}"))))
  (dnsmasq__tcpwrappers__dependent_allow (jinja "{{ lookup(\"template\", \"lookup/dnsmasq__tcpwrappers__dependent_allow.j2\",
                                             convert_data=False) | from_yaml }}"))
  (dnsmasq__apparmor__local_dependent_config 
    (usr.sbin.dnsmasq (list
        
        (comment "Allow dnsmasq to read upstream DNS servers")
        (rules (list
            "/etc/resolvconf/upstream.conf r"
            "/etc/hosts.dnsmasq r"))
        
        (comment "Allow dnsmasq to read /usr/share/dnsmasq-base/trust-anchors.conf provided by dnsmasq-base")
        (rules (list
            "/usr/share/dnsmasq-base/* r")))))
  (dnsmasq__persistent_paths__dependent_paths 
    (50_debops_dnsmasq 
      (by_role "debops.dnsmasq")
      (paths (list
          "/etc/ansible"
          "/etc/dnsmasq.d"
          "/etc/default/dnsmasq"
          "/etc/resolvconf/upstream.conf"
          "/etc/hosts.dnsmasq")))))
