(playbook "debops/ansible/roles/ldap/defaults/main.yml"
  (ldap__enabled (jinja "{{ ansible_local.ldap.enabled
                   if (ansible_local | d() and ansible_local.ldap | d() and
                       (ansible_local.ldap.enabled | d()) | bool)
                   else False }}"))
  (ldap__posix_enabled (jinja "{{ ansible_local.ldap.posix_enabled | d(ldap__enabled) }}"))
  (ldap__configured (jinja "{{ ansible_local.ldap.configured
                      if (ansible_local | d() and ansible_local.ldap | d() and
                          ansible_local.ldap.configured is defined)
                      else False }}"))
  (ldap__dependent_play (jinja "{{ True
                          if (ldap__configured | bool and
                              ldap__dependent_tasks | d())
                          else False }}"))
  (ldap__base_packages (list
      "libldap-common"
      "ldap-utils"
      "libsasl2-modules"))
  (ldap__packages (list))
  (ldap__domain (jinja "{{ ansible_domain }}"))
  (ldap__servers_srv_rr (jinja "{{ q(\"debops.debops.dig_srv\", \"_ldap._tcp.\" + ldap__domain,
                            \"ldap.\" + ldap__domain, 389) }}"))
  (ldap__servers (jinja "{{ ldap__servers_srv_rr | map(attribute=\"target\") }}"))
  (ldap__servers_protocol (jinja "{{ \"ldap\" if ldap__start_tls | bool else \"ldaps\" }}"))
  (ldap__servers_uri (jinja "{{ ldap__servers
                       | map(\"regex_replace\", \"^(.*)$\",
                             ldap__servers_protocol + \"://\\1/\")
                       | list }}"))
  (ldap__start_tls (jinja "{{ True
                     if (ansible_local | d() and ansible_local.pki | d() and
                         (ansible_local.pki.enabled | d()) | bool)
                     else False }}"))
  (ldap__base_dn (jinja "{{ ldap__domain.split(\".\")
                   | map(\"regex_replace\", \"^(.*)$\", \"dc=\\1\")
                   | list }}"))
  (ldap__basedn (jinja "{{ ldap__base_dn | join(\",\") }}"))
  (ldap__people_rdn "ou=People")
  (ldap__system_groups_rdn "ou=System Groups")
  (ldap__groups_rdn "ou=Groups")
  (ldap__hosts_rdn "ou=Hosts")
  (ldap__machines_rdn "ou=Machines")
  (ldap__roles_rdn "ou=Roles")
  (ldap__services_rdn "ou=Services")
  (ldap__device_enabled "True")
  (ldap__device_separate_domains "True")
  (ldap__device_domain (jinja "{{ ldap__domain }}"))
  (ldap__device_fqdn (jinja "{{ ansible_fqdn }}"))
  (ldap__device_aliases (list
      (jinja "{{ ansible_hostname }}")))
  (ldap__device_ip_addresses (jinja "{{ lookup(\"template\", \"lookup/ldap__device_ip_addresses.j2\",
                                      convert_data=False) | from_yaml }}"))
  (ldap__device_ip_iface_regex "^(bond|en|eth|vlan|mv-|host)")
  (ldap__device_mac_addresses (jinja "{{ lookup(\"template\", \"lookup/ldap__device_mac_addresses.j2\",
                                       convert_data=False) | from_yaml }}"))
  (ldap__device_mac_iface_regex "^(en|eth|mv-)")
  (ldap__device_self_rdn "cn=" (jinja "{{ ldap__device_fqdn }}"))
  (ldap__device_domain_rdn "dc=" (jinja "{{ ldap__device_domain }}"))
  (ldap__device_branch_rdn (jinja "{{ ldap__hosts_rdn }}"))
  (ldap__device_dn (jinja "{{ q(\"flattened\", [ldap__device_self_rdn]
                                    + ([ldap__device_domain_rdn]
                                       if ldap__device_separate_domains | bool
                                       else [])
                                    + [ldap__device_branch_rdn]
                                    + ldap__base_dn) }}"))
  (ldap__device_managers (list
      (jinja "{{ ldap__admin_dn | join(\",\") }}")))
  (ldap__device_domain_object_classes (list
      "domain"))
  (ldap__device_domain_attributes 
    (dc (jinja "{{ ldap__device_domain_rdn.split(\"=\")[1] }}")))
  (ldap__device_object_classes (jinja "{{ [\"device\", \"ieee802Device\", \"ipHost\"]
                                 + ([]
                                    if (ansible_virtualization_role == \"guest\" and
                                        ansible_virtualization_type in [\"lxc\", \"docker\", \"openvz\"])
                                    else [\"bootableDevice\"]) }}"))
  (ldap__device_attributes 
    (cn (jinja "{{ ([ldap__device_self_rdn.split(\"=\")[1]] + ldap__device_aliases) | unique }}"))
    (ipHostNumber (jinja "{{ ldap__device_ip_addresses }}"))
    (macAddress (jinja "{{ ldap__device_mac_addresses }}"))
    (manager (jinja "{{ ldap__device_managers }}")))
  (ldap__uid_gid_min "2000000000")
  (ldap__groupid_min (jinja "{{ ldap__uid_gid_min }}"))
  (ldap__groupid_max (jinja "{{ ldap__uid_gid_min | int + 1999999 }}"))
  (ldap__uid_gid_max (jinja "{{ ldap__uid_gid_min | int + 99999999 }}"))
  (ldap__home "/home")
  (ldap__shell "/bin/bash")
  (ldap__default_urn_patterns (list
      (jinja "{{ (\"deploy:\" + ansible_local.machine.deployment)
        if (ansible_local.machine.deployment | d())
        else [] }}")))
  (ldap__urn_patterns (list))
  (ldap__group_urn_patterns (list))
  (ldap__host_urn_patterns (list))
  (ldap__combined_urn_patterns (jinja "{{ ldap__default_urn_patterns
                                 + ldap__urn_patterns
                                 + ldap__group_urn_patterns
                                 + ldap__host_urn_patterns }}"))
  (ldap__default_configuration (list
      
      (name "base")
      (value (jinja "{{ ldap__basedn }}"))
      
      (name "uri")
      (value (jinja "{{ ldap__servers_uri }}"))
      
      (name "sizelimit")
      (value "12")
      (state "comment")
      (separator "True")
      
      (name "timelimit")
      (value "15")
      (state "comment")
      
      (name "deref")
      (value "never")
      (state "comment")
      
      (name "tls_cacert")
      (comment "TLS certificates (needed for GnuTLS)")
      (value "/etc/ssl/certs/ca-certificates.crt")
      
      (name "tls_reqcert")
      (value "demand")))
  (ldap__configuration (list))
  (ldap__group_configuration (list))
  (ldap__host_configuration (list))
  (ldap__combined_configuration (jinja "{{ ldap__default_configuration
                                  + ldap__configuration
                                  + ldap__group_configuration
                                  + ldap__host_configuration }}"))
  (ldap__admin_enabled (jinja "{{ True if ldap__fact_admin_bindpw | d() else False }}"))
  (ldap__admin_passwordstore_path "debops/ldap/credentials")
  (ldap__admin_rdn (jinja "{{ \"uid=\" + lookup(\"env\", \"USER\") }}"))
  (ldap__admin_dn (jinja "{{ [ldap__admin_rdn, ldap__people_rdn] + ldap__base_dn }}"))
  (ldap__admin_binddn (jinja "{{ lookup(\"env\", \"DEBOPS_LDAP_ADMIN_BINDDN\")
                        | d(ldap__admin_dn | join(\",\"), True) }}"))
  (ldap__admin_bindpw (jinja "{{ (lookup(\"env\", \"DEBOPS_LDAP_ADMIN_BINDPW\")
                         if lookup(\"env\", \"DEBOPS_LDAP_ADMIN_BINDPW\") | d()
                         else (lookup(\"file\", secret + \"/ldap/credentials/\"
                                              + ldap__admin_binddn | to_uuid
                                              + \".password\")
                               if lookup(\"first_found\",
                                         [secret + \"/ldap/credentials/\"
                                          + ldap__admin_binddn | to_uuid
                                          + \".password\"],
                                         skip=True, errors=\"ignore\")
                               else lookup(\"passwordstore\",
                                           ldap__admin_passwordstore_path + \"/\"
                                           + ldap__admin_binddn | to_uuid
                                           + \" create=false\", errors=\"ignore\")))
                        if ldap__enabled | bool else \"\" }}"))
  (ldap__admin_server_uri (jinja "{{ ldap__servers_uri | first }}"))
  (ldap__admin_delegate_to "localhost")
  (ldap__admin_become "False")
  (ldap__admin_become_user "root")
  (ldap__default_tasks (list
      
      (name "Ensure that " (jinja "{{ ldap__hosts_rdn }}") " object exists in LDAP directory")
      (dn (jinja "{{ [ldap__hosts_rdn] + ldap__base_dn }}"))
      (objectClass (list
          "organizationalStructure"))
      (attributes 
        (ou (jinja "{{ ldap__hosts_rdn.split(\"=\")[1] }}"))
        (description "Servers and other data center equipment"))
      
      (name "Create domain object for " (jinja "{{ ldap__device_dn | join(\",\") }}"))
      (dn (jinja "{{ [ldap__device_domain_rdn, ldap__device_branch_rdn]
            + ldap__base_dn }}"))
      (objectClass (jinja "{{ ldap__device_domain_object_classes }}"))
      (attributes (jinja "{{ ldap__device_domain_attributes }}"))
      (state (jinja "{{ \"present\"
               if (ldap__device_enabled | bool and
                   ldap__device_separate_domains | bool)
               else \"ignore\" }}"))
      
      (name "Create device object for " (jinja "{{ ldap__device_dn | join(\",\") }}"))
      (dn (jinja "{{ ldap__device_dn }}"))
      (objectClass (jinja "{{ ldap__device_object_classes }}"))
      (attributes (jinja "{{ ldap__device_attributes }}"))
      (state (jinja "{{ \"present\"
               if (ldap__device_enabled | bool)
               else \"ignore\" }}"))
      
      (name "Update device object for " (jinja "{{ ldap__device_dn | join(\",\") }}"))
      (dn (jinja "{{ ldap__device_dn }}"))
      (attributes (jinja "{{ ldap__device_attributes }}"))
      (state (jinja "{{ \"present\"
               if (ldap__fact_configured | bool and
                   ldap__device_enabled | bool)
               else (\"exact\"
                     if (ldap__device_enabled | bool)
                     else \"ignore\") }}"))))
  (ldap__tasks (list))
  (ldap__group_tasks (list))
  (ldap__host_tasks (list))
  (ldap__dependent_tasks (list))
  (ldap__combined_tasks (jinja "{{ ldap__dependent_tasks
                          if (ldap__fact_configured | bool and
                              ldap__dependent_tasks | d())
                          else (ldap__default_tasks
                                + ldap__tasks
                                + ldap__group_tasks
                                + ldap__host_tasks
                                + ldap__dependent_tasks) }}"))
  (ldap__python__dependent_packages3 (list
      (jinja "{{ ([]
         if (ansible_distribution_release in
             ([\"stretch\", \"trusty\", \"xenial\"]))
         else \"python3-ldap\")
        if ldap__enabled | bool
        else [] }}")))
  (ldap__python__dependent_packages2 (list
      (jinja "{{ \"python-ldap\" if ldap__enabled | bool else [] }}"))))
