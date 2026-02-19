(playbook "debops/ansible/roles/dhcp_probe/defaults/main.yml"
  (dhcp_probe__base_packages (list
      "dhcp-probe"))
  (dhcp_probe__packages (list))
  (dhcp_probe__cache (jinja "{{ (ansible_local.fhs.cache | d(\"/var/cache\"))
                       + \"/dhcp-probe\" }}"))
  (dhcp_probe__lib (jinja "{{ (ansible_local.fhs.lib | d(\"/usr/local/lib\"))
                     + \"/dhcp-probe\" }}"))
  (dhcp_probe__default_interfaces (jinja "{{ lookup(\"template\", \"lookup/dhcp_probe__default_interfaces.j2\",
                                    convert_data=False) | from_yaml }}"))
  (dhcp_probe__interfaces (list))
  (dhcp_probe__combined_interfaces (jinja "{{ dhcp_probe__default_interfaces
                                     + dhcp_probe__interfaces }}"))
  (dhcp_probe__alert_program (jinja "{{ dhcp_probe__lib + \"/dhcp_probe_notify2\" }}"))
  (dhcp_probe__legal_servers (list))
  (dhcp_probe__legal_servers_ethersrc (list))
  (dhcp_probe__options "")
  (dhcp_probe__domain (jinja "{{ ansible_domain }}"))
  (dhcp_probe__mail_from "root")
  (dhcp_probe__mail_to (list
      "root@" (jinja "{{ dhcp_probe__domain }}")))
  (dhcp_probe__mail_subject "Unexpected BOOTP/DHCP server")
  (dhcp_probe__mail_timeout (jinja "{{ 20 * 60 }}"))
  (dhcp_probe__page_to (list))
  (dhcp_probe__page_timeout (jinja "{{ 20 * 60 }}")))
