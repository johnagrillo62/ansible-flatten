(playbook "kubespray/roles/network_facts/tasks/main.yaml"
  (tasks
    (task "Set facts variables"
      (block (list
          
          (name "Gather node IPs")
          (setup 
            (gather_subset "!all,!min,network")
            (filter "ansible_default_ip*"))
          (when "ansible_default_ipv4 is not defined or ansible_default_ipv6 is not defined")
          (ignore_unreachable "true")
          
          (name "Set computed IPs varables")
          (vars 
            (fallback_ip (jinja "{{ ansible_default_ipv4.address | d('127.0.0.1') }}"))
            (fallback_ip6 (jinja "{{ ansible_default_ipv6.address | d('::1') }}"))
            (_ipv4 (jinja "{{ ip | default(fallback_ip) }}"))
            (_access_ipv4 (jinja "{{ access_ip | default(_ipv4) }}"))
            (_ipv6 (jinja "{{ ip6 | default(fallback_ip6) }}"))
            (_access_ipv6 (jinja "{{ access_ip6 | default(_ipv6) }}"))
            (_access_ips (list
                (jinja "{{ _access_ipv4 if ipv4_stack }}")
                (jinja "{{ _access_ipv6 if ipv6_stack }}")))
            (_ips (list
                (jinja "{{ _ipv4 if ipv4_stack }}")
                (jinja "{{ _ipv6 if ipv6_stack }}"))))
          (set_fact 
            (cacheable "true")
            (main_access_ip (jinja "{{ _access_ipv4 if ipv4_stack else _access_ipv6 }}"))
            (main_ip (jinja "{{ _ipv4 if ipv4_stack else _ipv6  }}"))
            (main_access_ips (jinja "{{ _access_ips | select }}"))
            (main_ips (jinja "{{ _ips | select }}")))
          
          (name "Set no_proxy")
          (import_tasks "no_proxy.yml")
          (when (list
              "http_proxy is defined or https_proxy is defined"
              "no_proxy is not defined"))))
      (tags (list
          "always")))))
