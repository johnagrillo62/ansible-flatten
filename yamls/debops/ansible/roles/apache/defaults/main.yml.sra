(playbook "debops/ansible/roles/apache/defaults/main.yml"
  (apache__base_packages (list
      "apache2"
      (jinja "{{ \"libapache2-mod-security2\" if (apache__security_module_enabled | bool) else [] }}")))
  (apache__packages (list))
  (apache__group_packages (list))
  (apache__host_packages (list))
  (apache__dependent_packages (list))
  (apache__deploy_state "present")
  (apache__fqdn (jinja "{{ ansible_fqdn }}"))
  (apache__domain (jinja "{{ ansible_domain }}"))
  (apache__config_path "/etc/apache2")
  (apache__service_name "apache2")
  (apache__user "www-data")
  (apache__server_name (jinja "{{ apache__fqdn }}"))
  (apache__server_admin (jinja "{{ ansible_local.core.admin_public_email[0]
                          if (ansible_local.core.admin_public_email | d())
                          else (apache__user + \"@\" + apache__fqdn) }}"))
  (apache__server_tokens "ProductOnly")
  (apache__server_signature "Off")
  (apache__trace_enabled "Off")
  (apache__http_listen (list
      "80"))
  (apache__https_listen (list
      "443"))
  (apache__config_use_if_version "True")
  (apache__config_min_version "current_major_minor")
  (apache__default_directory_match 
    (/. "Require all denied"))
  (apache__directory_match )
  (apache__group_directory_match )
  (apache__host_directory_match )
  (apache__combined_directory_match (jinja "{{ apache__default_directory_match
                                      | combine(apache__directory_match)
                                      | combine(apache__group_directory_match)
                                      | combine(apache__host_directory_match) }}"))
  (apache__allow (list))
  (apache__group_allow (list))
  (apache__host_allow (list))
  (apache__modules )
  (apache__group_modules )
  (apache__host_modules )
  (apache__role_modules 
    (headers "True")
    (alias "True")
    (ssl 
      (enabled (jinja "{{ True if (apache__https_listen and apache__https_enabled) else False }}")))
    (security2 
      (enabled (jinja "{{ apache__security_module_enabled | bool }}")))
    (status 
      (enabled (jinja "{{ apache__status_enabled | bool }}"))
      (config "<Location /server-status>
    # Revoke default permissions granted in `/etc/apache2/mods-available/status.conf`.
    Require all denied
</Location>
"))
    (socache_shmcb 
      (enabled (jinja "{{ True
                 if (apache__ocsp_stapling_enabled | bool
                     and \"shmcb\" in apache__ocsp_stapling_cache)
                 else omit }}")))
    (authz_host 
      (enabled (jinja "{{ True
                 if (apache__status_enabled | bool
                     and apache__status_allow_localhost)
                 else omit }}")))
    (rewrite 
      (enabled (jinja "{{ True
                 if (apache__register_mod_rewrite_used is defined and
                     apache__register_mod_rewrite_used.rc | d(1) == 0)
                 else omit }}"))))
  (apache__combined_modules (jinja "{{ apache__role_modules
                              | combine(apache__modules)
                              | combine(apache__group_modules)
                              | combine(apache__host_modules) }}"))
  (apache__security_module_enabled "False")
  (apache__security_module_server_signature (jinja "{{ omit }}"))
  (apache__mpm_max_connections_per_child "0")
  (apache__snippets )
  (apache__group_snippets )
  (apache__host_snippets )
  (apache__dependent_snippets )
  (apache__role_snippets 
    (local-debops_apache "True")
    (security 
      (type "divert")
      (raw "# This file exists here to make Debian package scripts happy.
# For the actual security directives enabled in server context refer to
# the `local-debops_apache.conf` file.
#
# `postinst` of the `apache2` package normally tries to enable the
# `security` snippet in server context without checking if it is actually
# there. The package provided `security.conf` snippet has been diverted
# to `package-security.conf` and is not enabled to allow `debops.apache`
# to configure and change security related settings.
")
      (divert_filename "package-security")
      (divert_suffix ""))
    (local-debops_apache_security_module 
      (state (jinja "{{ apache__security_module_enabled | bool | ternary(\"present\", \"absent\") }}"))))
  (apache__combined_snippets (jinja "{{ apache__dependent_snippets
                               | combine(apache__role_snippets)
                               | combine(apache__snippets)
                               | combine(apache__group_snippets)
                               | combine(apache__host_snippets) }}"))
  (apache__https_enabled (jinja "{{ ansible_local | d() and ansible_local.pki | d() and
                           (ansible_local.pki.enabled | d() | bool) and
                           apache__https_listen | length > 0 }}"))
  (apache__redirect_to_https (jinja "{{ apache__https_enabled | bool }}"))
  (apache__pki_realm_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (apache__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (apache__pki_crt_filename (jinja "{{ ansible_local.pki.crt | d(\"default.crt\") }}"))
  (apache__pki_key_filename (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (apache__pki_ca_filename (jinja "{{ ansible_local.pki.ca | d(\"CA.crt\") }}"))
  (apache__pki_trusted_filename (jinja "{{ ansible_local.pki.trusted | d(\"trusted.crt\") }}"))
  (apache__tls_cipher_suite_set_name (jinja "{{ \"mozilla_modern\"
                                      if apache__tls_protocols | length == 5 and
                                        apache__tls_protocols[4] == \"-TLSv1.2\"
                                      else \"mozilla_intermediate\" }}"))
  (apache__tls_protocols (list
      "all"
      "-SSLv3"
      "-TLSv1"
      "-TLSv1.1"))
  (apache__tls_cipher_suite_sets 
    (bettercrypto_org__set_a "EDH+aRSA+AES256:EECDH+aRSA+AES256:!SSLv3")
    (bettercrypto_org__set_b "EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA256:EECDH:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA128-SHA:AES128-SHA")
    (bettercrypto_org__set_b_pfs "EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA256:EECDH:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH")
    (cipherli_st "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH")
    (pfs "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4")
    (pfs_rc4 "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS")
    (hardened "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS")
    (mozilla "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:ECDHE-RSA-RC4-SHA:ECDHE-ECDSA-RC4-SHA:AES128:AES256:RC4-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK")
    (mozilla_modern "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384")
    (mozilla_intermediate "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384")
    (mozilla_old "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA")
    (fips "FIPS@STRENGTH:!aNULL:!eNULL")
    (ncsc_nl "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-GCM-SHA256")
    (default ""))
  (apache__tls_honor_cipher_order "on")
  (apache__tls_compression "off")
  (apache__tls_dhparam_set_name "default")
  (apache__tls_dhparam_file (jinja "{{ ansible_local.dhparam[apache__tls_dhparam_set_name]
                              if (ansible_local | d() and ansible_local.dhparam | d() and
                                  ansible_local.dhparam[apache__tls_dhparam_set_name] | d())
                              else \"\" }}"))
  (apache__ocsp_stapling_enabled "True")
  (apache__ocsp_stapling_cache "shmcb:${APACHE_RUN_DIR}/ocsp_scache(512000)")
  (apache__ocsp_stapling_response_max_age (jinja "{{ 30 * 24 * 3600 }}"))
  (apache__ocsp_stapling_force_url "False")
  (apache__ocsp_stapling_verify (jinja "{{ apache__ocsp_stapling_enabled | bool }}"))
  (apache__hsts_enabled "True")
  (apache__hsts_max_age "15768000")
  (apache__hsts_subdomains "True")
  (apache__hsts_preload "False")
  (apache__http_csp_append "")
  (apache__http_frame_options "SAMEORIGIN")
  (apache__http_xss_protection "1; mode=block")
  (apache__http_referrer_policy "same-origin")
  (apache__http_content_type_options "nosniff")
  (apache__http_sec_headers_directive_options "set")
  (apache__vhosts (list))
  (apache__default_vhost 
    (name (jinja "{{ apache__default_vhost_name }}"))
    (filename "000-default")
    (root "/var/www/html"))
  (apache__default_vhost_name "default." (jinja "{{ apache__domain }}"))
  (apache__group_vhosts (list))
  (apache__host_vhosts (list))
  (apache__role_vhosts (list
      
      (name "000-default")
      (type "divert")
      (divert_filename "package-default")
      (divert_suffix "")
      (comment "`postinst` of the `apache2` package normally tries to enable
the `000-default` site without checking if it is actually there.
Divert the package provided `000-default` site file away, we will not need it :)
")
      
      (name "default-ssl")
      (type "divert")
      (divert_filename "package-default-https")
      (divert_suffix "")
      (comment "Divert the package provided `default-ssl` site file away, we will not need it :)
")
      (jinja "{{ apache__default_vhost }}")
      (jinja "{{ apache__status_vhost }}")))
  (apache__dependent_vhosts (list))
  (apache__combined_vhosts (jinja "{{ apache__vhosts +
                             apache__group_vhosts +
                             apache__host_vhosts +
                             apache__role_vhosts +
                             apache__dependent_vhosts }}"))
  (apache__vhost_type "default")
  (apache__vhost_allow_override "None")
  (apache__vhost_options (list
      "+FollowSymLinks"))
  (apache__log_level "warn")
  (apache__access_log_format "combined")
  (apache__status_enabled "False")
  (apache__status_vhost_enabled (jinja "{{ apache__status_enabled }}"))
  (apache__status_for_vhost_enabled "False")
  (apache__status_location "/server-status")
  (apache__status_allow_localhost "False")
  (apache__status_directives "")
  (apache__status_extended_enabled (jinja "{{ apache__status_enabled | bool }}"))
  (apache__status_vhost_name (list
      "localhost"))
  (apache__status_vhost 
    (name (jinja "{{ apache__status_vhost_name }}"))
    (filename "debops.apache-status")
    (status_enabled "True")
    (status_allow_localhost "True")
    (listen_http (list
        "localhost:80"))
    (https_enabled "False")
    (enabled (jinja "{{ apache__status_vhost_enabled | bool }}")))
  (apache__ferm__dependent_rules (list
      
      (type "accept")
      (dport (jinja "{{ apache__http_listen | union(apache__https_listen) }}"))
      (saddr (jinja "{{ apache__allow + apache__group_allow + apache__host_allow }}"))
      (accept_any "True")
      (weight "40")
      (by_role "debops.apache")
      (name "http_https")
      (multiport "True")
      (rule_state (jinja "{{ apache__deploy_state }}")))))
