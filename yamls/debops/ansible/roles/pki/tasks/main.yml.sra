(playbook "debops/ansible/roles/pki/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "DebOps pre_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup('debops.debops.task_src', 'pki/pre_main.yml') }}")))
    (task "Generate random session token"
      (ansible.builtin.set_fact 
        (pki_fact_session_token (jinja "{{ 9999999999999999999999999999999999999 | random | string | hash(\"sha256\") }}")))
      (delegate_to "localhost")
      (become "False")
      (run_once "True"))
    (task "Expose host FQDN and library path in temporary variables"
      (ansible.builtin.set_fact 
        (pki_fact_lib_path (jinja "{{ (ansible_local.fhs.lib | d(\"/usr/local/lib\"))
                           + \"/pki\" }}"))))
    (task "Install PKI packages"
      (ansible.builtin.apt 
        (name (jinja "{{ (pki_base_packages
             + (pki_acme_packages if (pki_acme | bool or pki_acme_install | bool) else [])
             + pki_packages)
             | flatten }}"))
        (state "present")
        (install_recommends "False")
        (cache_valid_time (jinja "{{ ansible_local.core.cache_valid_time | d(\"86400\") }}")))
      (register "pki__register_packages")
      (until "pki__register_packages is succeeded")
      (when "pki_enabled | bool"))
    (task "Check Ansible Controller bash version"
      (ansible.builtin.command "/usr/bin/env bash -c 'echo $BASH_VERSION'")
      (changed_when "False")
      (register "pki__register_bash_version")
      (delegate_to "localhost")
      (become "False")
      (run_once "True")
      (check_mode "False"))
    (task "Check Ansible Controller crypto library version"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
" (jinja "{% if pki_ca_library == 'gnutls' %}") "
certtool --version | head -n 1 | awk '{print $NF}'
" (jinja "{% elif pki_ca_library == 'openssl' %}") "
openssl version | awk '{print $2}'
" (jinja "{% endif %}") "
")
      (args 
        (executable "bash"))
      (changed_when "False")
      (register "pki__register_crypto_library_version")
      (delegate_to "localhost")
      (become "False")
      (run_once "True")
      (check_mode "False"))
    (task "Assert that required dependencies are met as documented"
      (ansible.builtin.assert 
        (that (list
            "pki__register_bash_version.stdout | regex_replace(\"[^0-9.]\", \"\") is version_compare(\"4.3.0\", \">=\")"
            "pki__register_crypto_library_version.stdout | regex_replace(\"[a-z]\", \"\") is version_compare(\"1.0.1\" if (pki_ca_library == \"openssl\") else pki__register_crypto_library_version.stdout, \">=\")")))
      (delegate_to "localhost")
      (become "False")
      (run_once "True")
      (when "pki_authorities | d() and pki_dependent_authorities | d()"))
    (task "Create library directory"
      (ansible.builtin.file 
        (path (jinja "{{ pki_fact_lib_path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "pki_enabled | bool"))
    (task "Install local PKI scripts"
      (ansible.builtin.copy 
        (src "secret/pki/lib/")
        (dest (jinja "{{ secret + \"/pki/lib/\" }}"))
        (mode "0755"))
      (become "False")
      (delegate_to "localhost")
      (run_once "True")
      (when "(pki_authorities or pki_dependent_authorities)"))
    (task "Install remote PKI scripts"
      (ansible.builtin.copy 
        (src "usr/local/lib/pki/")
        (dest (jinja "{{ pki_fact_lib_path }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "pki_enabled | bool"))
    (task "Create private groups if requested"
      (ansible.builtin.group 
        (name (jinja "{{ item.name | d(item) }}"))
        (system (jinja "{{ (item.system | d(True)) | bool }}"))
        (state "present"))
      (with_items (jinja "{{ pki_private_groups_present }}"))
      (when "((pki_enabled | bool and pki_private_groups_present) and (item.when | d(True) | bool))"))
    (task "Configure acme-tiny support"
      (ansible.builtin.include_tasks "acme_tiny.yml")
      (when "(pki_enabled | bool and (pki_acme | bool or pki_acme_install | bool))"))
    (task "Configure certbot support"
      (ansible.builtin.include_tasks "certbot.yml")
      (when "(pki_enabled | bool and (pki_acme | bool or pki_acme_install | bool) and pki_acme_type != 'acme-tiny')"))
    (task "Ensure that /etc/pki directory exists"
      (ansible.builtin.file 
        (path "/etc/pki")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Ensure that sensitive files are excluded from version control"
      (ansible.builtin.template 
        (src "etc/pki/gitignore.j2")
        (dest "/etc/pki/.gitignore")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Initialize PKI realms"
      (ansible.builtin.command "\"" (jinja "{{ pki_fact_lib_path }}") "/pki-realm\" init -n \"" (jinja "{{ item.name }}") "\"
--authority-preference \"" (jinja "{{ (item.authority_preference | d(pki_authority_preference)) | join('/') }}") "\"
--library \"" (jinja "{{ item.library | d(pki_library) }}") "\"
--realm-key-size \"" (jinja "{{ item.realm_key_size | d(pki_realm_key_size) }}") "\"
--internal \"" (jinja "{{ (item.internal | d(pki_internal)) | bool | lower }}") "\"
--private-dir-group \"" (jinja "{{ item.private_dir_group | d(pki_private_group) }}") "\"
--private-file-group \"" (jinja "{{ item.private_file_group | d(pki_private_group) }}") "\"
--private-dir-acl-groups \"" (jinja "{{ (item.private_dir_acl_groups | d(pki_private_dir_acl_groups)) | join('/') }}") "\"
--private-file-acl-groups \"" (jinja "{{ (item.private_file_acl_groups | d(pki_private_file_acl_groups)) | join('/') }}") "\"
--acme-ca \"" (jinja "{{ item.acme_ca | d(pki_acme_ca) }}") "\"
--acme-ca-api \"" (jinja "{{ item.acme_ca_api | d(pki_acme_ca_api_map[item.acme_ca | d(pki_acme_ca)]) }}") "\"
--acme-type \"" (jinja "{{ item.type | d(pki_acme_type) }}") "\"
--acme-contacts \"" (jinja "{{ item.acme_contacts | d(pki_acme_contacts) | join(',') }}") "\"
--acme-domains \"" (jinja "{{ item.acme_domains | d([]) | join('/') }}") "\"
--acme-default-subdomains \"" (jinja "{{ (item.acme_default_subdomains | d(pki_acme_default_subdomains)) | join('/') }}") "\"
--acme-challenge-dir \"" (jinja "{{ item.acme_challenge_dir | d(pki_acme_challenge_dir) }}") "\"
--default-domain \"" (jinja "{{ item.default_domain | d(pki_default_domain) }}") "\"
--default-subdomains \"" (jinja "{{ (item.default_subdomains | d(pki_default_subdomains)) | join('/') }}") "\"
--dhparam \"" (jinja "{{ (item.dhparam | d(pki_dhparam)) | bool | lower }}") "\"
--dhparam-file \"" (jinja "{{ item.dhparam_file | d(pki_dhparam_file) }}") "\"
--selfsigned-sign-days \"" (jinja "{{ item.selfsigned_sign_days | d('365') }}") "\"
")
      (environment 
        (PKI_ROOT (jinja "{{ pki_root }}"))
        (PKI_ACME (jinja "{{ (item.acme | d(pki_acme)) | bool | lower }}"))
        (PKI_INTERNAL (jinja "{{ (item.internal | d(pki_internal)) | bool | lower }}"))
        (PKI_LIBRARY (jinja "{{ item.library | d(pki_library) }}"))
        (PKI_ACME_LIBRARY (jinja "{{ item.acme_library | d(pki_acme_library) }}")))
      (args 
        (creates (jinja "{{ pki_root + \"/realms/\" + item.name + \"/config/realm.conf\" }}")))
      (loop (jinja "{{ q(\"flattened\", pki_realms
                           + pki_group_realms
                           + pki_host_realms
                           + pki_default_realms
                           + pki_dependent_realms) }}"))
      (when "(pki_enabled | bool and item.name is defined and (item.enabled | d(True) | bool) and (item.when | d(True) | bool))"))
    (task "Configure PKI realm environment"
      (ansible.builtin.template 
        (src "etc/pki/realms/realm/config/environment.j2")
        (dest (jinja "{{ pki_root + \"/realms/\" + item.name + \"/config/environment\" }}"))
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", pki_realms
                           + pki_group_realms
                           + pki_host_realms
                           + pki_default_realms
                           + pki_dependent_realms) }}"))
      (when "(pki_enabled | bool and item.name is defined and (item.enabled | d(True) | bool) and (item.when | d(True) | bool))"))
    (task "Download private files to remove hosts"
      (block (list
          
          (name "Download custom private files")
          (ansible.builtin.copy 
            (src (jinja "{{ item.src | d(omit) }}"))
            (content (jinja "{{ item.content | d(omit) }}"))
            (dest (jinja "{{ item.dest }}"))
            (owner (jinja "{{ item.owner | d(\"root\") }}"))
            (group (jinja "{{ item.group | d(pki_private_group) }}"))
            (mode (jinja "{{ item.mode | d(\"0640\") }}"))
            (directory_mode (jinja "{{ item.directory_mode | d(omit) }}"))
            (follow (jinja "{{ item.follow | d(omit) }}"))
            (force (jinja "{{ item.force | d(omit) }}")))
          (loop (jinja "{{ q(\"flattened\", pki_private_files
                               + pki_group_private_files
                               + pki_host_private_files) }}"))
          (when "(pki_enabled | bool and (item.src is defined or item.content is defined) and item.dest is defined)")
          
          (name "Download private realm contents by host")
          (ansible.builtin.copy 
            (src (jinja "{{ secret + \"/pki/realms/by-host/\" + inventory_hostname + \"/\" + item.name + \"/private/\" }}"))
            (dest "/etc/pki/realms/" (jinja "{{ item.name }}") "/private/")
            (owner "root")
            (group (jinja "{{ item.private_file_group | d(pki_private_group) }}"))
            (mode "0640"))
          (with_items (list
              (jinja "{{ pki_realms + pki_group_realms + pki_host_realms + pki_default_realms + pki_dependent_realms }}")))
          (when "(pki_enabled | bool and item.name is defined and (item.enabled | d(True) | bool) and (item.when | d(True) | bool))")
          
          (name "Download private realm contents by group")
          (ansible.builtin.copy 
            (src (jinja "{{ secret + \"/pki/realms/by-group/\" + item.1 + \"/\" + item.0.name + \"/private/\" }}"))
            (dest "/etc/pki/realms/" (jinja "{{ item.0.name }}") "/private/")
            (owner "root")
            (group (jinja "{{ item.private_file_group | d(pki_private_group) }}"))
            (mode "0640")
            (force "False"))
          (with_nested (list
              (jinja "{{ pki_group_realms + pki_default_realms }}")
              (jinja "{{ pki_inventory_groups }}")))
          (when "(pki_enabled | bool and (item.0.name is defined and (item.0.enabled | d(True) | bool) and (item.0.when | d(True) | bool)) and (item.1 is defined and item.1 in group_names))")
          
          (name "Download private realm contents for all hosts")
          (ansible.builtin.copy 
            (src (jinja "{{ secret + \"/pki/realms/by-group/all/\" + item.name + \"/private/\" }}"))
            (dest "/etc/pki/realms/" (jinja "{{ item.name }}") "/private/")
            (owner "root")
            (group (jinja "{{ item.private_file_group | d(pki_private_group) }}"))
            (mode "0640")
            (force "False"))
          (with_items (list
              (jinja "{{ pki_realms + pki_default_realms }}")))
          (when "(pki_enabled | bool and item.name is defined and (item.enabled | d(True) | bool) and (item.when | d(True) | bool))")))
      (when "pki_download_extra | bool"))
    (task "Create new PKI realms"
      (ansible.builtin.command "\"" (jinja "{{ pki_fact_lib_path }}") "/pki-realm\" new-realm -n \"" (jinja "{{ item.name }}") "\"
--subject \"" (jinja "{{ item.subject | d([]) | join('/') }}") "\"
--domains \"" (jinja "{{ item.domains | d([]) | join('/') }}") "\"
--subdomains \"" (jinja "{{ item.subdomains | d([]) | join('/') }}") "\"
--acme \"" (jinja "{{ item.acme | d(pki_acme) | bool | lower }}") "\"
--acme-type \"" (jinja "{{ item.type | d(pki_acme_type) }}") "\"
--acme-subject \"" (jinja "{{ item.acme_subject | d([]) | join('/') }}") "\"
--acme-domains \"" (jinja "{{ item.acme_domains | d([]) | join('/') }}") "\"
--acme-subdomains \"" (jinja "{{ item.acme_subdomains | d([]) | join('/') }}") "\"
--subject-alt-names \"" (jinja "{{ item.subject_alt_names | d([]) | join('|') }}") "\"
--acme-alt-names \"" (jinja "{{ item.acme_alt_names | d([]) | join('|') }}") "\"
")
      (environment 
        (PKI_SESSION_TOKEN (jinja "{{ pki_fact_session_token }}")))
      (args 
        (creates "/etc/pki/realms/" (jinja "{{ item.name }}") "/default.key"))
      (loop (jinja "{{ q(\"flattened\", pki_realms
                           + pki_group_realms
                           + pki_host_realms
                           + pki_default_realms
                           + pki_dependent_realms) }}"))
      (when "(pki_enabled | bool and item.name is defined and (item.enabled | d(True) | bool) and (item.when | d(True) | bool))"))
    (task "Execute PKI realm commands"
      (ansible.builtin.command "\"" (jinja "{{ pki_fact_lib_path }}") "/pki-realm\" run -n \"" (jinja "{{ item.name }}") "\"")
      (environment 
        (PKI_SESSION_TOKEN (jinja "{{ pki_fact_session_token }}")))
      (loop (jinja "{{ q(\"flattened\", pki_realms
                           + pki_group_realms
                           + pki_host_realms
                           + pki_default_realms
                           + pki_dependent_realms) }}"))
      (changed_when "False")
      (when "(pki_enabled | bool and item.name is defined and (item.enabled | d(True) | bool) and (item.when | d(True) | bool))"))
    (task "Upload internal certificate requests"
      (ansible.builtin.fetch 
        (src "/etc/pki/realms/" (jinja "{{ item.name }}") "/internal/request.pem")
        (dest (jinja "{{ secret + \"/pki/requests/\" + (item.authority | d(pki_default_authority)) +
              \"/\" + inventory_hostname + \"/\" + item.name + \"/request.pem\" }}"))
        (flat "True"))
      (loop (jinja "{{ q(\"flattened\", pki_realms
                           + pki_group_realms
                           + pki_host_realms
                           + pki_default_realms
                           + pki_dependent_realms) }}"))
      (when "(pki_enabled | bool and item.name is defined and ((item.internal | d(True) | bool) and pki_internal | bool) and (item.enabled | d(True) | bool) and (item.when | d(True) | bool))"))
    (task "Initialize PKI authorities"
      (ansible.builtin.command "./lib/pki-authority init --name \"" (jinja "{{ item.name }}") "\" --default-sign-base \"" (jinja "{{ pki_default_sign_base }}") "\" --root-sign-multiplier \"" (jinja "{{ pki_default_root_sign_multiplier }}") "\" --ca-sign-multiplier \"" (jinja "{{ pki_default_ca_sign_multiplier }}") "\" --cert-sign-multiplier \"" (jinja "{{ pki_default_cert_sign_multiplier }}") "\"")
      (environment 
        (PKI_ROOT (jinja "{{ secret + \"/pki\" }}"))
        (PKI_LIBRARY (jinja "{{ item.pki_ca_library | d(pki_ca_library) }}"))
        (PKI_CA_CERTIFICATES (jinja "{{ secret + \"/pki/ca-certificates/\"
                             + (item.ca_certificates_path | d(pki_ca_certificates_path)) }}")))
      (args 
        (chdir (jinja "{{ secret + \"/pki\" }}"))
        (creates (jinja "{{ secret + \"/pki/authorities/\" + item.name + \"/config/authority.conf\" }}")))
      (delegate_to "localhost")
      (become "False")
      (run_once "True")
      (loop (jinja "{{ q(\"flattened\", pki_authorities + pki_dependent_authorities) }}"))
      (when "(item.name is defined and (item.enabled | d(True) | bool))"))
    (task "Create PKI authorities"
      (ansible.builtin.command "./lib/pki-authority new-ca --name \"" (jinja "{{ item.name }}") "\" --type \"" (jinja "{{ item.type | d('') }}") "\" --domain \"" (jinja "{{ item.domain | d(pki_ca_domain) }}") "\" --subdomain \"" (jinja "{{ item.subdomain }}") "\" --subject \"" (jinja "{{ item.subject | join('/') }}") "\" --issuer-name \"" (jinja "{{ item.issuer_name | d('') }}") "\" --root-sign-days \"" (jinja "{{ item.root_sign_days | d('') }}") "\" --ca-sign-days \"" (jinja "{{ item.ca_sign_days | d('') }}") "\" --cert-sign-days \"" (jinja "{{ item.cert_sign_days | d('') }}") "\" --system-ca \"" (jinja "{{ (item.system_ca | d(True)) | bool | lower }}") "\" --alt-authority \"" (jinja "{{ item.alt_authority | d('') }}") "\" --key-size \"" (jinja "{{ item.key_size | d('') }}") "\" --crl \"" (jinja "{{ item.crl | d(True) }}") "\" --ocsp \"" (jinja "{{ item.ocsp | d(True) }}") "\" --name-constraints \"" (jinja "{{ item.name_constraints | d(pki_ca_name_constraints) }}") "\" --name-constraints-critical \"" (jinja "{{ item.name_constraints_critical | d(pki_ca_name_constraints_critical) }}") "\"")
      (environment 
        (PKI_SESSION_TOKEN (jinja "{{ pki_fact_session_token }}"))
        (PKI_ROOT (jinja "{{ secret + \"/pki\" }}"))
        (PKI_LIBRARY (jinja "{{ item.pki_ca_library | d(pki_ca_library) }}"))
        (PKI_CA_CERTIFICATES (jinja "{{ secret + \"/pki/ca-certificates/\"
                             + (item.ca_certificates_path | d(pki_ca_certificates_path)) }}")))
      (args 
        (chdir (jinja "{{ secret + \"/pki\" }}"))
        (creates (jinja "{{ secret + \"/pki/authorities/\" + item.name + \"/subject/cert.pem\" }}")))
      (delegate_to "localhost")
      (become "False")
      (run_once "True")
      (loop (jinja "{{ q(\"flattened\", pki_authorities + pki_dependent_authorities) }}"))
      (when "(item.name is defined and (item.enabled | d(True) | bool))"))
    (task "Sign certificate requests for current hosts"
      (ansible.builtin.command "./lib/pki-authority sign-by-host " (jinja "{% for host in play_hosts %}") (jinja "{{ host }}") " " (jinja "{% endfor %}"))
      (environment 
        (PKI_SESSION_TOKEN (jinja "{{ pki_fact_session_token }}")))
      (args 
        (chdir (jinja "{{ secret + \"/pki\" }}")))
      (delegate_to "localhost")
      (register "pki_register_sign_by_host")
      (become "False")
      (run_once "True")
      (when "(pki_authorities or pki_dependent_authorities)")
      (changed_when "pki_register_sign_by_host.stdout | d()"))
    (task "Download public files to remote hosts"
      (block (list
          
          (name "Download public realm contents by host")
          (ansible.builtin.copy 
            (src (jinja "{{ secret + \"/pki/realms/by-host/\" + inventory_hostname + \"/\" + item.0.name + \"/\" + item.1 + \"/\" }}"))
            (dest "/etc/pki/realms/" (jinja "{{ item.0.name }}") "/" (jinja "{{ item.1 }}") "/")
            (owner "root")
            (group "root")
            (mode "0644"))
          (with_nested (list
              (jinja "{{ pki_realms + pki_group_realms + pki_host_realms + pki_default_realms + pki_dependent_realms }}")
              (list
                "external"
                "internal")))
          (when "(pki_enabled | bool and item.0.name is defined and (item.0.enabled | d(True) | bool) and (item.0.when | d(True) | bool))")
          
          (name "Download custom public files")
          (ansible.builtin.copy 
            (src (jinja "{{ item.src | d(omit) }}"))
            (content (jinja "{{ item.content | d(omit) }}"))
            (dest (jinja "{{ item.dest }}"))
            (owner (jinja "{{ item.owner | d(\"root\") }}"))
            (group (jinja "{{ item.group | d(pki_public_group) }}"))
            (mode (jinja "{{ item.mode | d(\"0644\") }}"))
            (directory_mode (jinja "{{ item.directory_mode | d(omit) }}"))
            (follow (jinja "{{ item.follow | d(omit) }}"))
            (force (jinja "{{ item.force | d(omit) }}")))
          (loop (jinja "{{ q(\"flattened\", pki_public_files
                               + pki_group_public_files
                               + pki_host_public_files) }}"))
          (when "(pki_enabled | bool and (item.src is defined or item.content is defined) and item.dest is defined)")
          
          (name "Download external realm contents by group")
          (ansible.builtin.copy 
            (src (jinja "{{ secret + \"/pki/realms/by-group/\" + item.1 + \"/\" + item.0.name + \"/external/\" }}"))
            (dest "/etc/pki/realms/" (jinja "{{ item.0.name }}") "/external/")
            (owner "root")
            (group "root")
            (mode "0644")
            (force "False"))
          (with_nested (list
              (jinja "{{ pki_group_realms + pki_default_realms }}")
              (jinja "{{ pki_inventory_groups }}")))
          (when "(pki_enabled | bool and (item.0.name is defined and (item.0.enabled | d(True) | bool) and (item.0.when | d(True) | bool)) and (item.1 is defined and item.1 in group_names))")
          
          (name "Download external realm contents for all hosts")
          (ansible.builtin.copy 
            (src (jinja "{{ secret + \"/pki/realms/by-group/all/\" + item.name + \"/external/\" }}"))
            (dest "/etc/pki/realms/" (jinja "{{ item.name }}") "/external/")
            (owner "root")
            (group "root")
            (mode "0644")
            (force "False"))
          (with_items (list
              (jinja "{{ pki_realms + pki_default_realms }}")))
          (when "(pki_enabled | bool and item.name is defined and (item.enabled | d(True) | bool) and (item.when | d(True) | bool))")
          
          (name "Download custom CA certificates by host")
          (ansible.builtin.copy 
            (src (jinja "{{ secret + \"/pki/ca-certificates/by-host/\" + inventory_hostname + \"/\" }}"))
            (dest "/usr/local/share/ca-certificates/pki/")
            (owner "root")
            (group "root")
            (mode "0644"))
          (notify (list
              "Regenerate ca-certificates.crt"))
          (when "pki_system_ca_certificates_download_by_host | d(pki_enabled) | bool")
          
          (name "Download custom CA certificates by group")
          (ansible.builtin.copy 
            (src (jinja "{{ secret + \"/pki/ca-certificates/by-group/\" + item + \"/\" }}"))
            (dest "/usr/local/share/ca-certificates/pki/")
            (owner "root")
            (group "root")
            (mode "0644")
            (force "False"))
          (with_items (jinja "{{ pki_inventory_groups }}"))
          (notify (list
              "Regenerate ca-certificates.crt"))
          (when "((pki_system_ca_certificates_download_by_group | d(pki_enabled) | bool) and item in group_names)")
          
          (name "Download custom CA certificates for all hosts")
          (ansible.builtin.copy 
            (src (jinja "{{ secret + \"/pki/ca-certificates/by-group/all/\" }}"))
            (dest "/usr/local/share/ca-certificates/pki/")
            (owner "root")
            (group "root")
            (mode "0644")
            (force (jinja "{{ pki_system_ca_certificates_download_all_hosts_force | bool }}")))
          (notify (list
              "Regenerate ca-certificates.crt"))
          (when "pki_system_ca_certificates_download_all_hosts | d(pki_enabled) | bool")))
      (when "pki_download_extra | bool"))
    (task "Execute PKI realm commands"
      (ansible.builtin.command "\"" (jinja "{{ pki_fact_lib_path }}") "/pki-realm\" run -n \"" (jinja "{{ item.name }}") "\"")
      (environment 
        (PKI_SESSION_TOKEN (jinja "{{ pki_fact_session_token }}")))
      (loop (jinja "{{ q(\"flattened\", pki_realms
                           + pki_group_realms
                           + pki_host_realms
                           + pki_default_realms
                           + pki_dependent_realms) }}"))
      (changed_when "False")
      (when "(pki_enabled | bool and item.name is defined and (item.enabled | d(True) | bool) and (item.when | d(True) | bool))"))
    (task "Manage PKI scheduler"
      (ansible.builtin.cron 
        (name "Process PKI system realms")
        (user "root")
        (cron_file "pki-realm-scheduler")
        (job "test -x \"" (jinja "{{ pki_fact_lib_path }}") "/pki-realm\" && \"" (jinja "{{ pki_fact_lib_path }}") "/pki-realm\" schedule")
        (special_time (jinja "{{ pki_scheduler_interval }}"))
        (state (jinja "{{ \"present\" if (pki_enabled | bool and pki_scheduler | bool) else \"absent\" }}")))
      (when "not ansible_check_mode"))
    (task "Manage system CA certificates"
      (ansible.builtin.include_tasks "ca_certificates.yml")
      (when "pki_enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/pki.fact.j2")
        (dest "/etc/ansible/facts.d/pki.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (register "pki_register_facts")
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Flush handlers for PKI"
      (ansible.builtin.meta "flush_handlers"))
    (task "DebOps post_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup('debops.debops.task_src', 'pki/post_main.yml') }}")))))
