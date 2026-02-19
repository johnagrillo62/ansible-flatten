(playbook "debops/ansible/roles/icinga/defaults/main.yml"
  (icinga__upstream (jinja "{{ True
                      if (ansible_distribution_release in [\"trusty\"])
                      else False }}"))
  (icinga__upstream_apt_key_id "DD3A F619 8ED0 00B4 C0B7 3956 CC11 6F55 AA7F 2382")
  (icinga__upstream_apt_repo "deb https://packages.icinga.com/" (jinja "{{ icinga__distribution | lower }}") " icinga-" (jinja "{{ icinga__distribution_release | lower }}") " main")
  (icinga__distribution (jinja "{{ ansible_local.core.distribution | d(ansible_distribution) }}"))
  (icinga__distribution_release (jinja "{{ ansible_local.core.distribution_release | d(ansible_distribution_release) }}"))
  (icinga__version (jinja "{{ ansible_local.icinga.version | d(\"0.0.0\") }}"))
  (icinga__base_packages (list
      "icinga2"
      "ssl-cert"
      "monitoring-plugins"
      "nagios-plugins-contrib"))
  (icinga__packages (list))
  (icinga__user "nagios")
  (icinga__group "nagios")
  (icinga__additional_groups (list
      "ssl-cert"
      (jinja "{{ ansible_local.proc_hidepid.group
        if (ansible_local.proc_hidepid.group | d() and
            (ansible_local.proc_hidepid.enabled | d()) | bool)
        else [] }}")))
  (icinga__fqdn (jinja "{{ ansible_fqdn }}"))
  (icinga__display_name (jinja "{{ (inventory_hostname_short | d(inventory_hostname.split(\".\")[0]))
                          if (inventory_hostname_short | d(inventory_hostname.split(\".\")[0]) != \"localhost\")
                          else ansible_hostname }}"))
  (icinga__ipv4_address (jinja "{{ ansible_default_ipv4.address
                          | d(ansible_all_ipv4_addresses | d([]) | first)
                          | d(icinga_fqdn) }}"))
  (icinga__ipv6_address (jinja "{{ ansible_default_ipv6.address
                          | d(ansible_all_ipv6_addresses | d([]) | first)
                          | d(omit, true) }}"))
  (icinga__domain (jinja "{{ ansible_domain }}"))
  (icinga__master_nodes (jinja "{{ q(\"debops.debops.dig_srv\", \"_icinga-master._tcp.\" + icinga__domain,
                            \"icinga-master.\" + icinga__domain, icinga__api_port) }}"))
  (icinga__master_delegate_to (jinja "{{ icinga__master_nodes[0][\"target\"] }}"))
  (icinga__director_nodes (jinja "{{ q(\"debops.debops.dig_srv\", \"_icinga-director._tcp.\" + icinga__domain,
                              \"icinga-director.\" + icinga__domain, 443) }}"))
  (icinga__node_type (jinja "{{ \"master\"
                       if (icinga__fqdn in
                           (icinga__master_nodes | map(attribute=\"target\")) or
                           not icinga__director_enabled | bool)
                       else \"client\" }}"))
  (icinga__allow (list))
  (icinga__group_allow (list))
  (icinga__host_allow (list))
  (icinga__api_listen "::")
  (icinga__api_port "5665")
  (icinga__api_user "root")
  (icinga__api_password (jinja "{{ lookup(\"password\", secret + \"/icinga/api/\"
                                  + icinga__fqdn + \"/credentials/\"
                                  + icinga__api_user + \"/password\")
                          if (icinga__node_type == \"master\")
                          else \"\" }}"))
  (icinga__api_permissions (list
      "*"))
  (icinga__director_enabled (jinja "{{ True
                              if (icinga__master_nodes[0][\"dig_srv_src\"] | d(\"\") != \"fallback\" and
                                  icinga__director_nodes[0][\"dig_srv_src\"] | d(\"\") != \"fallback\")
                              else False }}"))
  (icinga__director_register (jinja "{{ True
                               if (icinga__director_enabled | bool)
                               else False }}"))
  (icinga__director_register_api_fqdn (jinja "{{ icinga__director_nodes[0][\"target\"] }}"))
  (icinga__director_register_api_url "https://" (jinja "{{ icinga__director_register_api_fqdn }}") "/director/host")
  (icinga__director_register_api_user "director-api")
  (icinga__director_register_api_password (jinja "{{ lookup(\"password\", secret + \"/icinga_web/api/\"
                                            + icinga__director_register_api_fqdn + \"/credentials/\"
                                            + icinga__director_register_api_user + \"/password\") }}"))
  (icinga__director_register_default_templates (list
      "icinga-agent-host"))
  (icinga__director_register_templates (list))
  (icinga__director_register_group_templates (list))
  (icinga__director_register_host_templates (list))
  (icinga__director_register_default_vars 
    (ansible_managed "True"))
  (icinga__director_register_vars )
  (icinga__director_register_group_vars )
  (icinga__director_register_host_vars )
  (icinga__director_register_host_object 
    (object_type "object")
    (object_name (jinja "{{ icinga__fqdn }}"))
    (display_name (jinja "{{ icinga__display_name }}"))
    (address (jinja "{{ icinga__ipv4_address }}"))
    (address6 (jinja "{{ icinga__ipv6_address }}"))
    (imports (jinja "{{ q(\"flattened\",
                 (icinga__director_register_default_templates
                  + icinga__director_register_templates
                  + icinga__director_register_group_templates
                  + icinga__director_register_host_templates)) }}"))
    (vars (jinja "{{ icinga__director_register_default_vars
            | combine(icinga__director_register_vars,
                      icinga__director_register_group_vars,
                      icinga__director_register_host_vars) }}")))
  (icinga__director_deploy (jinja "{{ True
                             if (icinga__director_register | bool)
                             else False }}"))
  (icinga__director_deploy_api_fqdn (jinja "{{ icinga__director_nodes[0][\"target\"] }}"))
  (icinga__director_deploy_api_url "https://" (jinja "{{ icinga__director_deploy_api_fqdn }}") "/director/config/deploy")
  (icinga__director_deploy_api_user "director-api")
  (icinga__director_deploy_api_password (jinja "{{ lookup(\"password\", secret + \"/icinga_web/api/\"
                                            + icinga__director_deploy_api_fqdn + \"/credentials/\"
                                            + icinga__director_deploy_api_user + \"/password\") }}"))
  (icinga__pki_enabled (jinja "{{ True
                         if (ansible_local | d() and ansible_local.pki | d() and
                             (ansible_local.pki.enabled | d()) | bool)
                         else False }}"))
  (icinga__pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (icinga__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (icinga__pki_ca (jinja "{{ ansible_local.pki.ca | d(\"CA.crt\") }}"))
  (icinga__pki_crt (jinja "{{ ansible_local.pki.crt | d(\"default.crt\") }}"))
  (icinga__pki_key (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (icinga__pki_cert_path (jinja "{{ icinga__pki_path + \"/\" + icinga__pki_realm
                           + \"/\" + icinga__pki_crt }}"))
  (icinga__pki_key_path (jinja "{{ icinga__pki_path + \"/\" + icinga__pki_realm
                          + \"/\" + icinga__pki_key }}"))
  (icinga__pki_ca_path (jinja "{{ icinga__pki_path + \"/\" + icinga__pki_realm
                         + \"/\" + icinga__pki_ca }}"))
  (icinga__default_configuration (list
      
      (name "icinga2.conf")
      (divert "True")
      (comment "Icinga 2 configuration file
- this is where you define settings for the Icinga application including
which hosts/services to check.

For an overview of all available configuration options please refer
to the documentation that is distributed as part of Icinga 2.
")
      (options (list
          
          (name "constants")
          (comment "The constant.conf defines global constants.")
          (value "include \"constants.conf\"
")
          (state "present")
          
          (name "zones")
          (comment "The zones.conf defines zones for a cluster setup.
Not required for single instance setups.
")
          (value "include \"zones.conf\"
")
          (state "present")
          
          (name "itl")
          (comment "The Icinga Template Library (ITL) provides a number of useful templates
and command definitions.
Common monitoring plugin command definitions are included separately.
")
          (value "include <itl>
include <plugins>
include <plugins-contrib>
include <manubulon>
")
          (state "present")
          
          (name "windows_plugins")
          (comment "This includes the Icinga 2 Windows plugins. These command definitions
are required on a master node when a client is used as command endpoint.
")
          (value "include <windows-plugins>
")
          (state "present")
          
          (name "nscp")
          (comment "This includes the NSClient++ check commands. These command definitions
are required on a master node when a client is used as command endpoint.
")
          (value "include <nscp>
")
          (state "present")
          
          (name "features_enabled")
          (comment "The features-available directory contains a number of configuration
files for features which can be enabled and disabled using the
icinga2 feature enable / icinga2 feature disable CLI commands.
These commands work by creating and removing symbolic links in
the features-enabled directory.
")
          (value "include \"features-enabled/*.conf\"
")
          (state "present")
          
          (name "repository.d")
          (comment "The repository.d directory contains all configuration objects
managed by the 'icinga2 repository' CLI commands.
")
          (value "include_recursive \"repository.d\"
")
          (state (jinja "{{ \"absent\"
                   if (icinga__version is version(\"2.8.0\", \">=\"))
                   else \"present\" }}"))
          
          (name "conf.d")
          (comment "Although in theory you could define all your objects in this file
the preferred way is to create separate directories and files in the conf.d
directory. Each of these files must have the file extension \".conf\".
")
          (value "include_recursive \"conf.d\"
")
          (state (jinja "{{ \"absent\" if (icinga__director_enabled | bool) else \"present\" }}"))
          
          (name "api_users")
          (comment "Read the API User objects on master node.
")
          (value "include \"conf.d/api-users.conf\"
")
          (state (jinja "{{ \"present\"
                   if (icinga__director_enabled | bool and
                       icinga__node_type == \"master\")
                   else \"absent\" }}"))))
      
      (name "zones.conf")
      (divert "True")
      (comment "Endpoint and Zone configuration for a cluster setup
This local example requires 'NodeName' defined in
constants.conf
")
      (options (list
          
          (name "object_master")
          (value (jinja "{% for record in icinga__master_nodes %}") "
" (jinja "{% if record.target | d() %}") "
object Endpoint \"" (jinja "{{ record.target | regex_replace('\\.$', '') }}") "\" {
  host = \"" (jinja "{{ record.target | regex_replace('\\.$', '') }}") "\"
  port = \"" (jinja "{{ record.port }}") "\"
}

" (jinja "{% endif %}") "
" (jinja "{% endfor %}") "
object Zone \"master\" {
  endpoints = [ \"" (jinja "{{ icinga__master_nodes | map(attribute='target') | join('\", \"') }}") "\" ]
}
")
          (state (jinja "{{ \"present\"
                   if (icinga__node_type != \"master\" and
                       icinga__master_nodes[0][\"dig_srv_src\"] | d(\"\") != \"fallback\")
                   else \"absent\" }}"))
          
          (name "object_node")
          (value "object Endpoint NodeName {
  host = NodeName
}

object Zone ZoneName {
  endpoints = [ NodeName ]
" (jinja "{% if (icinga__director_enabled | bool and icinga__node_type != 'master') %}") "
  parent = \"master\"
" (jinja "{% endif %}") "
}
")
          (state "present")
          
          (name "object_global_templates")
          (value "object Zone \"global-templates\" {
  global = true
}
")
          (state "present")
          
          (name "object_director_global")
          (value "object Zone \"director-global\" {
  global = true
}
")
          (state (jinja "{{ \"present\" if (icinga__director_enabled | bool) else \"absent\" }}"))))
      
      (name "conf.d/api-users.conf")
      (comment "The APIUser objects are used for authentication against the API.")
      (group (jinja "{{ icinga__group }}"))
      (mode "0640")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\"
               if (icinga__node_type == \"master\")
               else \"absent\" }}"))
      (options (list
          
          (name "api_user_root")
          (value "object ApiUser \"" (jinja "{{ icinga__api_user }}") "\" {
  password = \"" (jinja "{{ icinga__api_password }}") "\"

  permissions = [ \"" (jinja "{{ icinga__api_permissions | join('\", \"') }}") "\" ]
}
")
          (state "present")))
      
      (name "features-available/api.conf")
      (divert "True")
      (comment "The API listener is used for distributed monitoring setups.")
      (value "object ApiListener \"api\" {
  bind_host = \"" (jinja "{{ icinga__api_listen }}") "\"
  bind_port = " (jinja "{{ icinga__api_port }}") "

" (jinja "{% if icinga__pki_enabled | bool %}") "
  cert_path = \"" (jinja "{{ icinga__pki_cert_path }}") "\"
  key_path  = \"" (jinja "{{ icinga__pki_key_path }}") "\"
  ca_path   = \"" (jinja "{{ icinga__pki_ca_path }}") "\"
" (jinja "{% else %}") "
  cert_path = SysconfDir + \"/icinga2/pki/\" + NodeName + \".crt\"
  key_path = SysconfDir + \"/icinga2/pki/\" + NodeName + \".key\"
  ca_path = SysconfDir + \"/icinga2/pki/ca.crt\"
" (jinja "{% endif %}") "

  accept_config   = " (jinja "{{ 'false' if (icinga__director_enabled | bool and icinga__node_type == 'master') else 'true' }}") "
  accept_commands = " (jinja "{{ 'false' if (icinga__director_enabled | bool and icinga__node_type == 'master') else 'true' }}") "

  ticket_salt = TicketSalt
}
")
      (state "present")
      (feature_name "api")
      (feature_state "present")
      
      (name "features-available/notification.conf")
      (divert "True")
      (state (jinja "{{ \"init\" if (icinga__node_type == \"master\") else \"feature\" }}"))
      (feature_name "notification")
      (feature_state (jinja "{{ \"present\" if (icinga__node_type == \"master\") else \"absent\" }}"))
      
      (name "features-available/checker.conf")
      (divert "True")
      (state (jinja "{{ \"init\" if (icinga__node_type == \"master\") else \"feature\" }}"))
      (feature_name "checker")
      (feature_state (jinja "{{ \"present\" if (icinga__node_type == \"master\") else \"absent\" }}"))))
  (icinga__configuration (list))
  (icinga__group_configuration (list))
  (icinga__host_configuration (list))
  (icinga__dependent_configuration (list))
  (icinga__dependent_configuration_filter (jinja "{{ lookup(\"template\",
                                             \"lookup/icinga__dependent_configuration_filter.j2\")
                                             | from_yaml }}"))
  (icinga__combined_configuration (jinja "{{ icinga__default_configuration
                                    + icinga__dependent_configuration_filter
                                    + icinga__configuration
                                    + icinga__group_configuration
                                    + icinga__host_configuration }}"))
  (icinga__master_configuration (list))
  (icinga__master_group_configuration (list))
  (icinga__master_host_configuration (list))
  (icinga__master_combined_configuration (jinja "{{ icinga__master_configuration
                                           + icinga__master_group_configuration
                                           + icinga__master_host_configuration }}"))
  (icinga__custom_files (list))
  (icinga__group_custom_files (list))
  (icinga__host_custom_files (list))
  (icinga__etc_services__dependent_list (list
      
      (name "icinga-api")
      (port (jinja "{{ icinga__api_port }}"))
      (comment "Icinga 2 REST API")))
  (icinga__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ icinga__upstream_apt_key_id }}"))
      (repo (jinja "{{ icinga__upstream_apt_repo }}"))
      (state (jinja "{{ \"present\" if icinga__upstream | bool else \"absent\" }}"))))
  (icinga__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "icinga-api"))
      (saddr (jinja "{{ icinga__allow + icinga__group_allow + icinga__host_allow }}"))
      (accept_any "False")
      (weight "40")
      (by_role "icinga")
      (name "icinga_api")))
  (icinga__unattended_upgrades__dependent_origins (list
      
      (origin "site=packages.icinga.com")
      (by_role "debops.icinga")
      (state (jinja "{{ \"present\" if icinga__upstream | bool else \"absent\" }}")))))
