(playbook "debops/ansible/roles/dropbear_initramfs/defaults/main.yml"
  (dropbear_initramfs__base_packages (list
      (jinja "{{ \"dropbear\"
        if (ansible_distribution == \"Ubuntu\" and ansible_distribution_release in [\"trusty\"])
        else \"dropbear-initramfs\" }}")))
  (dropbear_initramfs__packages (list))
  (dropbear_initramfs__config_path (jinja "{{ \"/etc/dropbear-initramfs\"
                                     if (ansible_distribution_release in [\"stretch\", \"buster\", \"bullseye\"])
                                     else \"/etc/dropbear/initramfs\" }}"))
  (dropbear_initramfs__config_file (jinja "{{ dropbear_initramfs__config_path + \"/\"
                                     + (\"config\"
                                        if (ansible_distribution_release in [\"stretch\", \"buster\", \"bullseye\"])
                                        else \"dropbear.conf\") }}"))
  (dropbear_initramfs__deploy_state "present")
  (dropbear_initramfs__network_autoconf "dhcp")
  (dropbear_initramfs__network_device (jinja "{{ ansible_default_ipv6.interface
                                        if ansible_default_ipv6.interface | d()
                                        else (ansible_default_ipv4.interface
                                              if ansible_default_ipv4.interface | d()
                                              else \"eth0\") }}"))
  (dropbear_initramfs__network_address (jinja "{{ ansible_default_ipv4.address }}"))
  (dropbear_initramfs__network_netmask (jinja "{{ ansible_default_ipv4.netmask }}"))
  (dropbear_initramfs__network_gateway (jinja "{{ ansible_default_ipv4.gateway }}"))
  (dropbear_initramfs__network_manual (jinja "{{
  (dropbear_initramfs__network_address | ansible.utils.ipwrap) + \"::\" +
  (dropbear_initramfs__network_gateway | ansible.utils.ipwrap) + \":\" +
  dropbear_initramfs__network_netmask + \"::\" +
  dropbear_initramfs__network_device + \":none\" }}"))
  (dropbear_initramfs__network (jinja "{{ dropbear_initramfs__network_manual
                                 if (dropbear_initramfs__network_autoconf in [\"off\", \"none\"])
                                 else dropbear_initramfs__network_autoconf }}"))
  (dropbear_initramfs__interfaces )
  (dropbear_initramfs__group_interfaces )
  (dropbear_initramfs__host_interfaces )
  (dropbear_initramfs__combined_interfaces (jinja "{{ lookup(\"template\", \"lookup/dropbear_initramfs__combined_interfaces.j2\", convert_data=False) | from_yaml }}"))
  (dropbear_initramfs__update_options "-k all")
  (dropbear_initramfs__port "22")
  (dropbear_initramfs__disable_password_login (jinja "{{
  True
  if dropbear_initramfs__combined_authorized_keys | d()
  else False
  }}"))
  (dropbear_initramfs__disable_port_forwarding "True")
  (dropbear_initramfs__idle_timeout "180")
  (dropbear_initramfs__max_authentication_attempts "10")
  (dropbear_initramfs__forced_command "")
  (dropbear_initramfs__dropbear_options (jinja "{{
  \"-p \" + dropbear_initramfs__port +
  (\" -g -s\" if dropbear_initramfs__disable_password_login | d() else \"\") +
  (\" -j -k\" if dropbear_initramfs__disable_port_forwarding | d() else \"\") +
  \" -I \" + dropbear_initramfs__idle_timeout +
  \" -T \" + dropbear_initramfs__max_authentication_attempts +
  (\" -c \" + dropbear_initramfs__forced_command if dropbear_initramfs__forced_command | d() else \"\")
  }}"))
  (dropbear_initramfs__authorized_keys (list))
  (dropbear_initramfs__group_authorized_keys (list))
  (dropbear_initramfs__host_authorized_keys (list))
  (dropbear_initramfs__combined_authorized_keys (jinja "{{ dropbear_initramfs__authorized_keys +
                                                  dropbear_initramfs__group_authorized_keys +
                                                  dropbear_initramfs__host_authorized_keys }}"))
  (dropbear_initramfs__authorized_keys_key_options (jinja "{{ omit }}")))
