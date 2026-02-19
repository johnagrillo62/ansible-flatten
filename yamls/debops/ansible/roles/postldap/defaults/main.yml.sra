(playbook "debops/ansible/roles/postldap/defaults/main.yml"
  (postldap__postfix__dependent_packages (jinja "{{ [\"postfix-ldap\"]
                                           if postldap__ldap_enabled else [] }}"))
  (postldap__domain (jinja "{{ ansible_domain }}"))
  (postldap__domain_rev_pattern (jinja "{% set reversed = [] %}") "
" (jinja "{% for element in postldap__domain.split(\".\") %}") "
" (jinja "{% set _ = reversed.append(\"%\" + loop.index | string) %}") "
" (jinja "{% endfor %}") "
" (jinja "{% if reversed | length == 1 %}") "
" (jinja "{{ \"%d\" }}") (jinja "{% else %}") "
" (jinja "{{ reversed[0:9][::-1] | join(\".\") }}") (jinja "{% endif %}"))
  (postldap__tls_ca_cert_dir "/etc/ssl/certs/")
  (postldap__vmail_posix_user "vmail")
  (postldap__vmail_posix_uidnumber (jinja "{{ ansible_local.postldap.vmail_posix_uidnumber | d(None) }}"))
  (postldap__vmail_posix_group "vmail")
  (postldap__vmail_posix_gidnumber (jinja "{{ ansible_local.postldap.vmail_posix_gidnumber | d(None) }}"))
  (postldap__mailbox_base "/var/vmail")
  (postldap__virtual_mailbox_maps_attribute "mailAddress")
  (postldap__virtual_mailbox_maps_format "/%d/%u/Maildir/")
  (postldap__virtual_alias_maps (list
      "$alias_maps"
      "ldap:/etc/postfix/ldap_virtual_forward_maps.cf"
      "ldap:/etc/postfix/ldap_virtual_alias_maps.cf"))
  (postldap__postfix__dependent_maincf (list
      
      (name "virtual_mailbox_domains")
      (value "ldap:/etc/postfix/ldap_virtual_mailbox_domains.cf")
      (section "virtual")
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool and
                postfix__version is version_compare(\"2.0\", \">=\"))
            else \"absent\" }}"))
      
      (name "virtual_alias_maps")
      (value (jinja "{{ postldap__virtual_alias_maps }}"))
      (section "virtual")
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool and
                postfix__version is version_compare(\"2.0\", \">=\"))
            else \"absent\" }}"))
      
      (name "virtual_mailbox_base")
      (value (jinja "{{ postldap__mailbox_base }}"))
      (section "virtual")
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool and
                postfix__version is version_compare(\"2.0\", \">=\"))
            else \"absent\" }}"))
      
      (name "virtual_mailbox_maps")
      (value "ldap:/etc/postfix/ldap_virtual_mailbox_maps.cf")
      (section "virtual")
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool and
                postfix__version is version_compare(\"2.0\", \">=\"))
            else \"absent\" }}"))
      
      (name "virtual_uid_maps")
      (value "static:" (jinja "{{ postldap__vmail_posix_uidnumber | mandatory }}"))
      (section "virtual")
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool and
                postfix__version is version_compare(\"2.0\", \">=\"))
            else \"absent\" }}"))
      
      (name "virtual_gid_maps")
      (value "static:" (jinja "{{ postldap__vmail_posix_gidnumber | mandatory }}"))
      (section "virtual")
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool and
                postfix__version is version_compare(\"2.0\", \">=\"))
            else \"absent\" }}"))
      
      (name "virtual_minimum_uid")
      (value (jinja "{{ postldap__vmail_posix_uidnumber | mandatory }}"))
      (section "virtual")
      (state "absent")
      
      (name "smtpd_sender_login_maps")
      (value (list
          "ldap:/etc/postfix/ldap_smtpd_sender_login_maps.cf"))
      (section "base")
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool)
            else \"absent\" }}"))
      
      (name "smtpd_sender_restrictions")
      (value (list
          
          (name "check_sasl_access ldap:${config_directory}/ldap_known_sender_relays.cf")
          (copy_id_from "permit_mynetworks")
          (weight "5")
          
          (name "check_sender_access ldap:${config_directory}/ldap_unauth_sender_access.cf")
          (copy_id_from "permit_sasl_authenticated")
          (weight "10")
          
          (name "check_sender_access ldap:${config_directory}/ldap_unauth_domain_access.cf")
          (copy_id_from "permit_sasl_authenticated")
          (weight "15")))
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool)
            else \"ignore\" }}"))
      
      (name "smtpd_relay_restrictions")
      (value (list
          
          (name "check_sasl_access ldap:${config_directory}/ldap_known_sender_relays.cf")
          (copy_id_from "permit_mynetworks")
          (weight "5")))
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool)
            else \"ignore\" }}"))
      
      (name "smtpd_restriction_classes")
      (value (list
          "smtpd_permit_known_sender_relays"))
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool)
            else \"ignore\" }}"))
      
      (name "smtpd_permit_known_sender_relays")
      (value (list
          "reject_unlisted_sender"
          "permit_sasl_authenticated"
          "reject"))
      (state (jinja "{{ \"present\"
            if (postldap__ldap_enabled | bool)
            else \"ignore\" }}"))))
  (postldap__postfix_ldap_connection 
    (server_host (jinja "{{ postldap__ldap_uri }}"))
    (start_tls (jinja "{{ \"yes\"
                  if (postldap__ldap_start_tls | bool)
                  else \"no\" }}"))
    (version "3")
    (tls_ca_cert_dir (jinja "{{ postldap__tls_ca_cert_dir }}"))
    (bind "yes")
    (bind_dn (jinja "{{ postldap__ldap_binddn }}"))
    (bind_pw (jinja "{{ postldap__ldap_bindpw }}"))
    (scope "sub"))
  (postldap__postfix__dependent_lookup_tables (list
      
      (name "ldap_virtual_alias_maps.cf")
      (state "present")
      (comment "The virtual_alias_maps setting is used to find the final delivery address,
given an alias.
")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (connection (jinja "{{ postldap__postfix_ldap_connection }}"))
      (search_base (jinja "{{ postldap__ldap_base_dn | join(\",\") }}"))
      (query_filter "(& (objectClass=mailRecipient) (mailAlternateAddress=%s) (| (authorizedService=all) (authorizedService=mail:receive) ) )")
      (result_attribute "mailAddress")
      
      (name "ldap_virtual_forward_maps.cf")
      (state "present")
      (comment "The virtual_forward_maps setting is used to find the final delivery address,
given a distribution list.
")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (connection (jinja "{{ postldap__postfix_ldap_connection }}"))
      (search_base (jinja "{{ postldap__ldap_base_dn | join(\",\") }}"))
      (query_filter "(& (| (objectClass=mailAlias) (objectClass=mailDistributionList) ) (mailAddress=%s) (| (authorizedService=all) (authorizedService=mail:receive) ) )")
      (result_attribute "mailForwardTo")
      (special_result_attribute "member")
      (leaf_result_attribute "mailAddress")
      
      (name "ldap_virtual_mailbox_maps.cf")
      (state "present")
      (comment "As we only want to accept mail, where we know the recipients
(and are responsible for them), the virtual_mailbox_maps configuration is used.
")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (connection (jinja "{{ postldap__postfix_ldap_connection }}"))
      (search_base (jinja "{{ postldap__ldap_base_dn | join(\",\") }}"))
      (query_filter "(& (objectClass=mailRecipient) (| (mailAddress=%s) ) (| (authorizedService=all) (authorizedService=mail:receive) ) )")
      (result_attribute (jinja "{{ postldap__virtual_mailbox_maps_attribute }}"))
      (result_format (jinja "{{ postldap__virtual_mailbox_maps_format }}"))
      
      (name "ldap_virtual_mailbox_domains.cf")
      (state "present")
      (comment "The virtual_mailbox_domains configurations performs a lookup,
if the postfix is responsible for the given domain.
")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (connection (jinja "{{ postldap__postfix_ldap_connection }}"))
      (search_base (jinja "{{ postldap__ldap_domains_dn | join(\",\") }}"))
      (query_filter "(& (objectClass=dNSDomain) (dc=%s) )")
      (result_attribute "dc")
      
      (name "ldap_smtpd_sender_login_maps.cf")
      (state "present")
      (comment "The smtpd_sender_login_maps configurations performs a lookup from an incoming
email-sender to a username. Postfix first performs a full lookup
on user@domain, then user and then @domain.
The later one is also used for catchalls where the mailAlternateAddress
is set to e.g. @foobar.com
")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (connection (jinja "{{ postldap__postfix_ldap_connection }}"))
      (search_base (jinja "{{ postldap__ldap_base_dn | join(\",\") }}"))
      (query_filter "(& (| (& (objectClass=mailRecipient) (| (mailAddress=%s) (mailAlternateAddress=%s) ) ) (& (objectClass=account) (uid=%u) (host=%d) ) ) (| (authorizedService=all) (authorizedService=mail:send) ) )")
      (result_attribute "")
      (special_result_attribute "member")
      (leaf_result_attribute (jinja "{{ postldap__virtual_mailbox_maps_attribute }}"))
      (size_limit "1")
      
      (name "ldap_known_sender_relays.cf")
      (state "present")
      (comment "This lookup table checks if a given SASL authenticated login specified as
'user@fqdn' is a service account which can be used to relay e-mails from
other hosts through Postfix. If such service account is found, the lookup
table tells Postfix to use a relaxed sender and relay restrictions which
don't check for sender <-> login mismatch. This is required for accepting
e-mail messages from trusted SMTP services, for example nullmailer, which
can send e-mail messages on behalf of other users but cannot authenticate
as them.
")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (connection (jinja "{{ postldap__postfix_ldap_connection }}"))
      (search_base (jinja "{{ postldap__ldap_base_dn | join(\",\") }}"))
      (query_filter "(& (objectClass=account) (uid=%u) (host=%d) (| (authorizedService=all) (authorizedService=mail:send) ) )")
      (result_attribute "uid")
      (result_format "smtpd_permit_known_sender_relays")
      (size_limit "1")
      
      (name "ldap_unauth_sender_access.cf")
      (state "present")
      (comment "This lookup table is used to check if a sender exists after authenticated
sender has been accepted. If a sender exists, it means that the sender has
not been authenticated properly, or perhaps somebody tries to send e-mail
as one of our own users which is not allowed without authentication. In
such cases, the mail will be rejected with a sensible response indicating
that the sender needs to enable SMTP authentication.
")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (connection (jinja "{{ postldap__postfix_ldap_connection }}"))
      (search_base (jinja "{{ postldap__ldap_base_dn | join(\",\") }}"))
      (query_filter "(| (& (objectClass=mailRecipient) (| (mailAddress=%s) (mailAlternateAddress=%s) ) ) (& (objectClass=account) (uid=%u) (host=%d) ) )")
      (result_attribute "uid, mailAddress, mailAlternateAddress")
      (result_format "550 Authentication Required")
      
      (name "ldap_unauth_domain_access.cf")
      (state "present")
      (comment "This lookup table is used to check if a sender domain is one of our own
domains. This check is performed after authenticated senders have been
accepted, and if the domain is one of our own domains, it means that
somebody tries to send an e-mail with our own DNS domain which is not
allowed. The e-mail will be rejected with a message suggesting that the
SMTP authentication needs to be enabled.
")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (connection (jinja "{{ postldap__postfix_ldap_connection }}"))
      (search_base (jinja "{{ postldap__ldap_base_dn | join(\",\") }}"))
      (query_filter "(| (& (objectClass=dNSDomain) (| (dc=%d) (dc=" (jinja "{{ postldap__domain_rev_pattern }}") ") ) ) (& (objectClass=domainRelatedObject) ( | (associatedDomain=%d) (associatedDomain=" (jinja "{{ postldap__domain_rev_pattern }}") ") ) ) )")
      (result_attribute "dc, associatedDomain")
      (result_format "550 Domain Authentication Required")))
  (postldap__ldap_enabled (jinja "{{ True
                            if (ansible_local | d() and ansible_local.ldap | d() and
                               (ansible_local.ldap.enabled | d()) | bool)
                            else False }}"))
  (postldap__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (postldap__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (postldap__ldap_self_rdn "uid=postfix")
  (postldap__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"
      "authorizedServiceObject"))
  (postldap__ldap_self_attributes 
    (uid (jinja "{{ postldap__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ postldap__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"Postfix\" service to access the LDAP directory")
    (authorizedService "mail:send"))
  (postldap__ldap_binddn (jinja "{{ ([postldap__ldap_self_rdn]
                            + postldap__ldap_device_dn) | join(\",\") }}"))
  (postldap__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                                   + postldap__ldap_binddn | to_uuid + \".password length=32 \"
                                   + \"chars=ascii_letters,digits,!@_#$%^&*\"))
                           if postldap__ldap_enabled | bool
                           else \"\" }}"))
  (postldap__ldap_people_rdn (jinja "{{ ansible_local.ldap.people_rdn | d(\"ou=People\") }}"))
  (postldap__ldap_people_dn (jinja "{{ [postldap__ldap_people_rdn]
                              + postldap__ldap_base_dn }}"))
  (postldap__ldap_uri (jinja "{{ ansible_local.ldap.uri | d([\"\"]) }}"))
  (postldap__ldap_private_subtree "False")
  (postldap__ldap_groups_rdn (jinja "{{ ansible_local.ldap.groups_rdn | d(\"ou=Groups\") }}"))
  (postldap__ldap_domains_rdn (jinja "{{ ansible_local.ldap.domains_rdn | d(\"ou=Domains\") }}"))
  (postldap__ldap_groups_dn (jinja "{{ ([postldap__ldap_groups_rdn, postldap__ldap_self_rdn]
                               + postldap__ldap_device_dn)
                              if postldap__ldap_private_subtree | bool
                              else ([postldap__ldap_groups_rdn]
                                    + postldap__ldap_base_dn) }}"))
  (postldap__ldap_domains_dn (jinja "{{ ([postldap__ldap_domains_rdn, postldap__ldap_self_rdn]
                                + postldap__ldap_device_dn)
                               if postldap__ldap_private_subtree | bool
                               else ([postldap__ldap_domains_rdn]
                                     + postldap__ldap_base_dn) }}"))
  (postldap__ldap_default_virtual_domain_rdn (jinja "{{ ansible_domain }}"))
  (postldap__ldap_default_virtual_domain_dn (jinja "{{ ([\"dc=\"
                                               + postldap__ldap_default_virtual_domain_rdn]
                                               + postldap__ldap_domains_dn) | join(\",\") }}"))
  (postldap__ldap_server_uri (jinja "{{ ansible_local.ldap.uri | d([\"\"]) | first }}"))
  (postldap__ldap_start_tls (jinja "{{ ansible_local.ldap.start_tls | d(True) | bool }}"))
  (postldap__ldap_default_config (list))
  (postldap__ldap_config (list))
  (postldap__group_ldap_config (list))
  (postldap__host_ldap_config (list))
  (postldap__ldap_combined_config (jinja "{{ postldap__ldap_default_config
                                    + postldap__ldap_config
                                    + postldap__group_ldap_config
                                    + postldap__host_ldap_config }}"))
  (postldap__ldap__dependent_tasks (list
      
      (name "Create Postfix account for " (jinja "{{ postldap__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ postldap__ldap_binddn }}"))
      (objectClass (jinja "{{ postldap__ldap_self_object_classes }}"))
      (attributes (jinja "{{ postldap__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\"
                if (postldap__ldap_enabled | bool and
                    postldap__ldap_device_dn | d())
                else \"ignore\" }}"))
      
      (name "Create Postfix group container for " (jinja "{{ postldap__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ postldap__ldap_groups_dn }}"))
      (objectClass "organizationalStructure")
      (attributes 
        (ou (jinja "{{ postldap__ldap_groups_rdn.split(\"=\")[1] }}"))
        (description "User groups used in Postfix"))
      (state (jinja "{{ \"present\"
               if (postldap__ldap_enabled | bool and
                   postldap__ldap_device_dn | d() and
                   postldap__ldap_private_subtree | bool)
               else \"ignore\" }}"))
      
      (name "Create Postfix domains container for " (jinja "{{ postldap__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ postldap__ldap_domains_dn }}"))
      (objectClass "organizationalStructure")
      (attributes 
        (ou (jinja "{{ postldap__ldap_domains_rdn.split(\"=\")[1] }}"))
        (description "Virtual Mail Domains used in Postfix"))
      (state (jinja "{{ \"present\"
               if (postldap__ldap_enabled | bool and
                   postldap__ldap_device_dn | d() and
                   postldap__ldap_private_subtree | bool)
               else \"ignore\" }}"))
      
      (name "Create Postfix Default Virtual Mail Domain for " (jinja "{{ postldap__ldap_default_virtual_domain_dn }}"))
      (dn (jinja "{{ postldap__ldap_default_virtual_domain_dn }}"))
      (objectClass "dNSDomain")
      (state (jinja "{{ \"present\"
               if (postldap__ldap_enabled | bool and
                   postldap__ldap_device_dn | d() and
                   postldap__ldap_private_subtree | bool)
               else \"ignore\" }}")))))
