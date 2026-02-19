(playbook "debops/ansible/roles/pki/defaults/main.yml"
  (pki_enabled (jinja "{{ (True
                  if pki_default_domain
                  else False) | bool }}"))
  (pki_download_extra "True")
  (pki_internal (jinja "{{ (True
                   if pki_default_domain
                   else False) | bool }}"))
  (pki_inventory_groups (list
      "debops_service_pki"))
  (pki_vcs_ignore_patterns_role (list
      "**/private/**"))
  (pki_vcs_ignore_patterns (list))
  (pki_vcs_ignore_patterns_group (list))
  (pki_vcs_ignore_patterns_host (list))
  (pki_acme (jinja "{{ (True
               if (((ansible_all_ipv4_addresses | d([]) +
                     ansible_all_ipv6_addresses | d([])) | ansible.utils.ipaddr(\"public\")
                    and pki_default_domain)
                   or pki_acme_type != \"acme-tiny\")
               else False) | bool }}"))
  (pki_acme_install (jinja "{{ pki_acme | bool }}"))
  (pki_acme_library "openssl")
  (pki_acme_user "pki-acme")
  (pki_acme_group "pki-acme")
  (pki_acme_home "/run/pki-acme")
  (pki_acme_default_subdomains (list))
  (pki_acme_type "acme-tiny")
  (pki_acme_tiny_repo "https://github.com/diafygi/acme-tiny")
  (pki_acme_tiny_version "main")
  (pki_acme_tiny_src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                       + \"/\" + pki_acme_user }}"))
  (pki_acme_tiny_bin "/usr/local/bin/acme-tiny")
  (pki_acme_ca "le-live-v2")
  (pki_acme_ca_api_map 
    (le-live "https://acme-v01.api.letsencrypt.org")
    (le-staging "https://acme-staging.api.letsencrypt.org")
    (le-live-v2 "https://acme-v02.api.letsencrypt.org/directory")
    (le-staging-v2 "https://acme-staging-v02.api.letsencrypt.org/directory"))
  (pki_acme_contacts (list
      "mailto:" (jinja "{{ ansible_local.core.admin_public_email[0] | d(\"root@\" + ansible_domain) }}")))
  (pki_acme_challenge_dir (jinja "{{ ansible_local.nginx.acme_root | d(\"/srv/www/sites/acme/public\")
                            + \"/.well-known/acme-challenge\" }}"))
  (pki_create_acme_challenge_dir (jinja "{{ True if (ansible_local.nginx.acme | d() and
                                            ansible_local.nginx.acme | bool) else False }}"))
  (pki_certbot_default_configuration (list
      
      (name "key-type")
      (comment "Define the default key signature algorithm to use for certificates.
DebOps currently supports only RSA signature algorithm.
")
      (value "rsa")
      
      (name "max-log-backups")
      (comment "Because we are using logrotate for greater flexibility, disable the
internal certbot logrotation.
")
      (value "0")
      
      (name "post-hook")
      (comment "The certbot script does not execute post-hooks on initial certificate
issuance, only renewals. This should ensure that the permissions are
fixed when certificates are created.
")
      (value "/etc/letsencrypt/renewal-hooks/post/000-fix-permissions")))
  (pki_certbot_configuration (list))
  (pki_certbot_combined_configuration (jinja "{{ pki_certbot_default_configuration
                                        + pki_certbot_configuration }}"))
  (pki_base_packages (list
      "ssl-cert"
      "make"
      "ca-certificates"
      "gnutls-bin"
      "openssl"
      "acl"))
  (pki_acme_packages (list
      (jinja "{{ \"curl\" if (pki_acme_type == \"acme-tiny\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"git\" if (pki_acme_type == \"acme-tiny\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ [] if (pki_acme_install | bool == false or ansible_distribution_release in
               [\"stretch\", \"trusty\", \"xenial\", \"bionic\"])
           else \"acme-tiny\" if (pki_acme_type == \"acme-tiny\") else [] }}")
      (jinja "{{ \"python3-certbot-dns-cloudflare\" if (pki_acme_type == \"dns-cloudflare\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"python3-certbot-dns-digitalocean\" if (pki_acme_type == \"dns-digitalocean\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"python3-certbot-dns-dnsimple\" if (pki_acme_type == \"dns-dnsimple\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"python3-certbot-dns-gehirn\" if (pki_acme_type == \"dns-gehirn\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"python3-certbot-dns-google\" if (pki_acme_type == \"dns-google\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"python3-certbot-dns-linode\" if (pki_acme_type == \"dns-linode\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"python3-certbot-dns-ovh\" if (pki_acme_type == \"dns-ovh\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"python3-certbot-dns-rfc2136\" if (pki_acme_type == \"dns-rfc2136\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"python3-certbot-dns-route53\" if (pki_acme_type == \"dns-route53\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"python3-certbot-dns-sakuracloud\" if (pki_acme_type == \"dns-sakuracloud\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"python3-certbot-dns-gandi\" if (pki_acme_type == \"dns-gandi\" and pki_acme_install | bool) else [] }}")
      (jinja "{{ \"certbot\" if (pki_acme_type in
                [\"dns-cloudflare\", \"dns-digitalocean\",
                 \"dns-dnsimple\", \"dns-gehirn\", \"dns-google\",
                 \"dns-linode\", \"dns-ovh\", \"dns-rfc2136\",
                 \"dns-route53\", \"dns-sakuracloud\", \"dns-gandi\", \"manual\"]
           and pki_acme_install | bool) else [] }}")))
  (pki_packages (list))
  (pki_root "/etc/pki")
  (pki_public_group "root")
  (pki_private_group "ssl-cert")
  (pki_public_dir_mode "0755")
  (pki_private_dir_mode "0750")
  (pki_public_mode "0644")
  (pki_private_mode "0640")
  (pki_private_groups_present (list))
  (pki_private_dir_acl_groups (list))
  (pki_private_file_acl_groups (list))
  (pki_default_sign_base "365")
  (pki_default_root_sign_multiplier "12")
  (pki_default_ca_sign_multiplier "10")
  (pki_default_cert_sign_multiplier "3")
  (pki_library "gnutls")
  (pki_realm_key_size "2048")
  (pki_system_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (pki_system_ca_realm (jinja "{{ pki_system_realm }}"))
  (pki_default_domain (jinja "{{ ansible_domain }}"))
  (pki_default_subdomains (list
      "_wildcard_"))
  (pki_authority_preference (list
      "external"
      "acme"
      "internal"
      "selfsigned"))
  (pki_realms (list))
  (pki_default_realms (list
      
      (name "domain")
      (acme "False")
      (default_subdomains (list
          (jinja "{{ ansible_hostname }}")
          "*." (jinja "{{ ansible_hostname }}")
          "_wildcard_"))))
  (pki_group_realms (list))
  (pki_host_realms (list))
  (pki_dependent_realms (list))
  (pki_scheduler "True")
  (pki_scheduler_interval "weekly")
  (pki_dhparam (jinja "{{ True
                 if ansible_local.dhparam.default | d()
                 else False }}"))
  (pki_dhparam_file (jinja "{{ ansible_local.dhparam.default | d(\"\") }}"))
  (pki_ca_library "openssl")
  (pki_default_authority "domain")
  (pki_ca_name_constraints "True")
  (pki_ca_name_constraints_critical "True")
  (pki_ca_domain (jinja "{{ ansible_domain }}"))
  (pki_ca_organization (jinja "{{ pki_ca_domain.split(\".\") | first | capitalize }}"))
  (pki_ca_root_dn (list
      "o=" (jinja "{{ pki_ca_organization }}") " Certificate Authority"))
  (pki_ca_root_key_size "4096")
  (pki_ca_domain_dn (list
      "o=" (jinja "{{ pki_ca_organization }}")
      "ou=Domain CA"))
  (pki_ca_domain_key_size "4096")
  (pki_ca_service_enabled "False")
  (pki_ca_service_dn (list
      "o=" (jinja "{{ pki_ca_organization }}")
      "ou=Internal Services CA"))
  (pki_ca_service_key_size "4096")
  (pki_authorities_ca_root 
    (name "root")
    (enabled (jinja "{{ True if pki_ca_domain | d() else False }}"))
    (subdomain "root-ca")
    (subject (jinja "{{ pki_ca_root_dn }}"))
    (key_size (jinja "{{ pki_ca_root_key_size }}")))
  (pki_authorities_ca_domain 
    (name "domain")
    (enabled (jinja "{{ True if pki_ca_domain | d() else False }}"))
    (subdomain "domain-ca")
    (subject (jinja "{{ pki_ca_domain_dn }}"))
    (issuer_name "root")
    (key_size (jinja "{{ pki_ca_domain_key_size }}")))
  (pki_authorities_ca_service 
    (name "service")
    (subdomain "service-ca")
    (subject (jinja "{{ pki_ca_service_dn }}"))
    (type "service")
    (enabled (jinja "{{ True if (pki_ca_domain | d() and pki_ca_service_enabled | bool) else False }}"))
    (key_size (jinja "{{ pki_ca_service_key_size }}")))
  (pki_authorities (list
      (jinja "{{ pki_authorities_ca_root }}")
      (jinja "{{ pki_authorities_ca_domain }}")
      (jinja "{{ pki_authorities_ca_service }}")))
  (pki_dependent_authorities (list))
  (pki_ca_certificates_path "by-group/all")
  (pki_private_files (list))
  (pki_group_private_files (list))
  (pki_host_private_files (list))
  (pki_public_files (list))
  (pki_group_public_files (list))
  (pki_host_public_files (list))
  (pki_system_ca_certificates_trust_new "True")
  (pki_system_ca_certificates_blacklist (list
      "mozilla/CNNIC_ROOT.crt"
      "mozilla/China_Internet_Network_Information_Center_EV_Certificates_Root.crt"))
  (pki_system_ca_certificates_whitelist (list))
  (pki_system_ca_certificates_download_by_host (jinja "{{ pki_enabled | bool }}"))
  (pki_system_ca_certificates_download_by_group (jinja "{{ pki_enabled | bool }}"))
  (pki_system_ca_certificates_download_all_hosts (jinja "{{ pki_enabled | bool }}"))
  (pki_system_ca_certificates_download_all_hosts_force "False"))
