(playbook "debops/ansible/roles/snmpd/defaults/main.yml"
  (snmpd_packages (list))
  (snmpd_user (jinja "{{ \"snmp\"
                if (ansible_distribution == \"Ubuntu\" and
                    ansible_distribution_release not in [\"bionic\"])
                else \"Debian-snmp\" }}"))
  (snmpd_group (jinja "{{ \"snmp\"
                 if (ansible_distribution == \"Ubuntu\" and
                     ansible_distribution_release not in [\"bionic\"])
                 else \"Debian-snmp\" }}"))
  (snmpd_logging_options "-LScd")
  (snmpd_custom_options "")
  (snmpd_group_custom_options "")
  (snmpd_host_custom_options "")
  (snmpd_combined_custom_options (jinja "{{ snmpd_custom_options
                                   + snmpd_group_custom_options
                                   + snmpd_host_custom_options }}"))
  (snmpd_download_mibs (jinja "{{ True
                         if (ansible_local | d() and ansible_local.apt | d() and
                             (ansible_local.apt.nonfree | d()) | bool)
                         else False }}"))
  (snmpd_extension_scripts (jinja "{{ (ansible_local.fhs.lib | d(\"/usr/local/lib\"))
                             + \"/snmpd\" }}"))
  (snmpd_allow (list))
  (snmpd_group_allow (list))
  (snmpd_host_allow (list))
  (snmpd_local_allow (jinja "{{ ansible_all_ipv4_addresses | d([]) +
                       (ansible_all_ipv6_addresses | d([])
                        | difference(ansible_all_ipv6_addresses | d([])
                                     | ansible.utils.ipaddr(\"link-local\"))) }}"))
  (snmpd_agent_address (list
      "udp:0.0.0.0:161"
      "udp6:[::]:161"))
  (snmpd_organization (jinja "{{ ansible_domain.split(\".\") | first | capitalize }}"))
  (snmpd_sys_location (jinja "{{ snmpd_organization + \" \" + snmpd_sys_location_name }}"))
  (snmpd_sys_location_name "Data Center")
  (snmpd_sys_contact (jinja "{{ snmpd_sys_contact_name + \" <\" + snmpd_sys_contact_email + \">\" }}"))
  (snmpd_sys_contact_name (jinja "{{ snmpd_organization + \" System Administrator\" }}"))
  (snmpd_sys_contact_email "root@" (jinja "{{ ansible_domain }}"))
  (snmpd_sys_name (jinja "{{ ansible_fqdn }}"))
  (snmpd_load "True")
  (snmpd_load_profile "default")
  (snmpd_load_percent (jinja "{{ snmpd_load_profile }}"))
  (snmpd_load_weight (jinja "{{ snmpd_load_profile }}"))
  (snmpd_load_base (jinja "{{ ansible_processor_vcpus }}"))
  (snmpd_load_percent_map 
    (default (list
        "90"
        "90"
        "100")))
  (snmpd_load_weight_map 
    (default (list
        "1.5"
        "1.7"
        "1.8")))
  (snmpd_load_1min (jinja "{{ (((snmpd_load_base | float) *
                      (snmpd_load_percent_map[snmpd_load_percent][0] | float) / 100) | float *
                       snmpd_load_weight_map[snmpd_load_weight][0] | float) }}"))
  (snmpd_load_5min (jinja "{{ (((snmpd_load_base | float) *
                      (snmpd_load_percent_map[snmpd_load_percent][1] | float) / 100) | float *
                       snmpd_load_weight_map[snmpd_load_weight][1] | float) }}"))
  (snmpd_load_15min (jinja "{{ (((snmpd_load_base | float) *
                      (snmpd_load_percent_map[snmpd_load_percent][2] | float) / 100) | float *
                       snmpd_load_weight_map[snmpd_load_weight][2] | float) }}"))
  (snmpd_proc_hidepid (jinja "{{ True
                        if (ansible_local | d() and ansible_local.proc_hidepid | d() and
                            (ansible_local.proc_hidepid.enabled | d()) | bool)
                        else False }}"))
  (snmpd_proc_hidepid_group (jinja "{{ ansible_local.proc_hidepid.group | d(\"\") }}"))
  (snmpd_account "True")
  (snmpd_account_username_length "16")
  (snmpd_account_password_length "48")
  (snmpd_account_admin_username (jinja "{{ lookup(\"password\", secret +
                                  \"/snmp/credentials/admin/username chars=ascii_letters,digits length=\" +
                                  snmpd_account_username_length) }}"))
  (snmpd_account_admin_password (jinja "{{ lookup(\"password\", secret +
                                  \"/snmp/credentials/admin/password chars=ascii_letters,digits,hexdigits length=\" +
                                  snmpd_account_password_length) }}"))
  (snmpd_account_agent_username (jinja "{{ lookup(\"password\", secret +
                                  \"/snmp/credentials/agent/username chars=ascii_letters,digits length=\" +
                                  snmpd_account_username_length) }}"))
  (snmpd_account_agent_password (jinja "{{ lookup(\"password\", secret +
                                  \"/snmp/credentials/agent/password chars=ascii_letters,digits,hexdigits length=\" +
                                  snmpd_account_password_length) }}"))
  (snmpd_ferm_dependent_rules (list
      
      (type "accept")
      (protocol (list
          "udp"))
      (dport (list
          "snmp"))
      (saddr (jinja "{{ snmpd_allow + snmpd_group_allow + snmpd_host_allow + snmpd_local_allow }}"))
      (role "snmpd")))
  (snmpd_tcpwrappers_dependent_allow (list
      
      (daemon "snmpd")
      (client (jinja "{{ snmpd_allow + snmpd_group_allow + snmpd_host_allow + snmpd_local_allow }}"))
      (weight "50")
      (filename "snmpd_dependency_allow")
      (comment "Allow remote connections to SNMP daemon"))))
