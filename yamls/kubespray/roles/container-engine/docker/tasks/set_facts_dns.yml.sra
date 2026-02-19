(playbook "kubespray/roles/container-engine/docker/tasks/set_facts_dns.yml"
  (tasks
    (task "Set dns server for docker"
      (set_fact 
        (docker_dns_servers (jinja "{{ dns_servers }}"))))
    (task "Show docker_dns_servers"
      (debug 
        (msg (jinja "{{ docker_dns_servers }}"))))
    (task "Add upstream dns servers"
      (set_fact 
        (docker_dns_servers (jinja "{{ docker_dns_servers + upstream_dns_servers }}")))
      (when "dns_mode in ['coredns', 'coredns_dual']"))
    (task "Add global searchdomains"
      (set_fact 
        (docker_dns_search_domains (jinja "{{ docker_dns_search_domains + searchdomains }}"))))
    (task "Check system nameservers"
      (shell "set -o pipefail && grep \"^nameserver\" /etc/resolv.conf | sed -r 's/^nameserver\\s*([^#\\s]+)\\s*(#.*)?/\\1/'")
      (args 
        (executable "/bin/bash"))
      (changed_when "false")
      (register "system_nameservers")
      (check_mode "false"))
    (task "Check system search domains"
      (shell "grep \"^search\" /etc/resolv.conf | sed -r 's/^search\\s*([^#]+)\\s*(#.*)?/\\1/'")
      (args 
        (executable "/bin/bash"))
      (changed_when "false")
      (register "system_search_domains")
      (check_mode "false"))
    (task "Add system nameservers to docker options"
      (set_fact 
        (docker_dns_servers (jinja "{{ docker_dns_servers | union(system_nameservers.stdout_lines) | unique }}")))
      (when "system_nameservers.stdout"))
    (task "Add system search domains to docker options"
      (set_fact 
        (docker_dns_search_domains (jinja "{{ docker_dns_search_domains | union(system_search_domains.stdout.split() | default([])) | unique }}")))
      (when "system_search_domains.stdout"))
    (task "Check number of nameservers"
      (fail 
        (msg "Too many nameservers. You can relax this check by set docker_dns_servers_strict=false in docker.yml and we will only use the first 3."))
      (when "docker_dns_servers | length > 3 and docker_dns_servers_strict | bool"))
    (task "Rtrim number of nameservers to 3"
      (set_fact 
        (docker_dns_servers (jinja "{{ docker_dns_servers[0:3] }}")))
      (when "docker_dns_servers | length > 3 and not docker_dns_servers_strict | bool"))
    (task "Check number of search domains"
      (fail 
        (msg "Too many search domains"))
      (when "docker_dns_search_domains | length > 6"))
    (task "Check length of search domains"
      (fail 
        (msg "Search domains exceeded limit of 256 characters"))
      (when "docker_dns_search_domains | join(' ') | length > 256"))))
