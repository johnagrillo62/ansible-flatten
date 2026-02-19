(playbook "kubespray/roles/kubernetes/preinstall/tasks/0063-networkmanager-dns.yml"
  (tasks
    (task "NetworkManager | Add nameservers to NM configuration"
      (community.general.ini_file 
        (path "/etc/NetworkManager/conf.d/dns.conf")
        (section "global-dns-domain-*")
        (option "servers")
        (value (jinja "{{ nameserverentries | join(',') }}"))
        (mode "0600")
        (backup (jinja "{{ leave_etc_backup_files }}")))
      (when (list
          "('127.0.0.53' not in nameserverentries or systemd_resolved_enabled.rc != 0)"))
      (notify "Preinstall | update resolvconf for networkmanager"))
    (task "Set default dns if remove_default_searchdomains is false"
      (set_fact 
        (default_searchdomains (list
            "default.svc." (jinja "{{ dns_domain }}")
            "svc." (jinja "{{ dns_domain }}"))))
      (when "not remove_default_searchdomains | default() | bool or (remove_default_searchdomains | default() | bool and searchdomains | default([]) | length==0)"))
    (task "NetworkManager | Add DNS search to NM configuration"
      (community.general.ini_file 
        (path "/etc/NetworkManager/conf.d/dns.conf")
        (section "global-dns")
        (option "searches")
        (value (jinja "{{ (default_searchdomains | default([]) + searchdomains) | join(',') }}"))
        (mode "0600")
        (backup (jinja "{{ leave_etc_backup_files }}")))
      (notify "Preinstall | update resolvconf for networkmanager"))
    (task "NetworkManager | Add DNS options to NM configuration"
      (community.general.ini_file 
        (path "/etc/NetworkManager/conf.d/dns.conf")
        (section "global-dns")
        (option "options")
        (value "ndots:" (jinja "{{ ndots }}") ",timeout:" (jinja "{{ dns_timeout | default('2') }}") ",attempts:" (jinja "{{ dns_attempts | default('2') }}"))
        (mode "0600")
        (backup (jinja "{{ leave_etc_backup_files }}")))
      (notify "Preinstall | update resolvconf for networkmanager"))))
