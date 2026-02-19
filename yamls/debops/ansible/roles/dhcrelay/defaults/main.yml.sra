(playbook "debops/ansible/roles/dhcrelay/defaults/main.yml"
  (dhcrelay__base_packages (list
      "isc-dhcp-relay"))
  (dhcrelay__packages (list))
  (dhcrelay__servers (list
      (jinja "{{ ansible_default_ipv4.gateway
                         if ansible_default_ipv4.gateway | d()
                         else [] }}")))
  (dhcrelay__interfaces (list
      (jinja "{{ ansible_local.ifupdown.internal_interface
                            if ansible_local.ifupdown.internal_interface | d()
                            else ansible_default_ipv4.interface }}")))
  (dhcrelay__options ""))
