(playbook "kubespray/roles/kubernetes/preinstall/vars/main.yml"
  (coredns_server_by_mode 
    (coredns (jinja "{{ [skydns_server] }}"))
    (coredns_dual (jinja "{{ [skydns_server, skydns_server_secondary] }}"))
    (manual (jinja "{{ manual_dns_server.split(',') }}"))
    (none (list)))
  (coredns_server (jinja "{{ upstream_dns_servers if dns_early else coredns_server_by_mode[dns_mode] }}"))
  (_nameserverentries 
    (late (list
        (jinja "{{ nodelocaldns_ip if enable_nodelocaldns else coredns_server }}")))
    (early (list
        (jinja "{{ nameservers }}")
        (jinja "{{ cloud_resolver }}")
        (jinja "{{ configured_nameservers if not disable_host_nameservers else [] }}"))))
  (nameserverentries (jinja "{{ ((_nameserverentries['late'] if not dns_early else []) + _nameserverentries['early']) | flatten | unique }}"))
  (dhclient_supersede 
    (domain-name-servers (jinja "{{ ([nameservers, cloud_resolver] | flatten | unique) if dns_early else nameserverentries }}"))
    (domain-name (jinja "{{ [dns_domain] }}"))
    (domain-search (jinja "{{ default_searchdomains + searchdomains }}")))
  (configured_nameservers (jinja "{{ (resolvconf_slurp.content | b64decode | regex_findall('^nameserver\\\\s*(\\\\S*)', multiline=True) | ansible.utils.ipaddr)
                            if resolvconf_stat.stat.exists else [] }}")))
