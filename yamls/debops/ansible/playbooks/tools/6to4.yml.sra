(playbook "debops/ansible/playbooks/tools/6to4.yml"
    (play
    (name "Configure and enable IPv6 6to4 tunnel")
    (hosts "debops_6to4")
    (become "True")
    (vars
      (debops_6to4_var_iface (jinja "{{ debops_6to4_iface | default(\"6to4\") }}"))
      (debops_6to4_var_ipv4_interface (jinja "{{ debops_6to4_ipv4_interface | default(ansible_default_ipv4.interface) }}"))
      (debops_6to4_var_ipv6_address (jinja "{{ hostvars[inventory_hostname][\"ansible_\" + debops_6to4_var_ipv4_interface].ipv4.address | ansible.utils.ipv4(\"6to4\") }}")))
    (pre_tasks
      (task "Make sure that host has a public IPv4 address"
        (ansible.builtin.assert 
          (that (list
              (jinja "{{ debops_6to4_var_ipv6_address != \"False\" }}"))))))
    (roles
      
        (role "ifupdown")
        (tags "ifupdown")
        (ifupdown_dependent_interfaces (list
            
            (iface (jinja "{{ debops_6to4_var_iface }}"))
            (type "6to4")
            (tunnel_6to4_ipv4_interface (jinja "{{ debops_6to4_var_ipv4_interface }}"))
            (filename "debops_6to4_tunnel_" (jinja "{{ debops_6to4_var_ipv4_interface }}"))
            (weight "30")))
      
        (role "ferm")
        (tags "ferm")
        (ferm_input_dependent_list (list
            
            (type "custom")
            (dport (list))
            (by_role "DebOps playbook: net/ipv6/6to4")
            (filename "debops_6to4_tunnel_" (jinja "{{ debops_6to4_var_ipv4_interface }}"))
            (weight "30")
            (rules (jinja "{% if debops_6to4_var_ipv6_address is defined and debops_6to4_var_ipv6_address %}") "
# Allow IPv6-in-IPv4 traffic
@if @eq($DOMAIN, ip) protocol ipv6 interface " (jinja "{{ debops_6to4_var_ipv4_interface }}") " ACCEPT;
" (jinja "{% else %}") "
# IPv6-in-IPv4 traffic not allowed
" (jinja "{% endif %}")))))))
