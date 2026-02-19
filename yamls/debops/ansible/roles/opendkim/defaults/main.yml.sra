(playbook "debops/ansible/roles/opendkim/defaults/main.yml"
  (opendkim__base_packages (list
      "opendkim"
      "opendkim-tools"))
  (opendkim__packages (list))
  (opendkim__version (jinja "{{ ansible_local.opendkim.version | d(\"0.0.0\") }}"))
  (opendkim__user "opendkim")
  (opendkim__group "opendkim")
  (opendkim__postfix_integration (jinja "{{ ansible_local.postfix.installed
                                   if (ansible_local | d() and ansible_local.postfix | d() and
                                       ansible_local.postfix.installed is defined)
                                   else False }}"))
  (opendkim__postfix_group (jinja "{{ ansible_local.postfix.system_group | d(\"postfix\") }}"))
  (opendkim__pidfile "/var/run/opendkim/opendkim.pid")
  (opendkim__socket (jinja "{{ \"/var/spool/postfix/opendkim/opendkim.sock\"
                      if opendkim__postfix_integration | bool
                      else \"/var/run/opendkim/opendkim.sock\" }}"))
  (opendkim__domain (jinja "{{ ansible_domain }}"))
  (opendkim__fqdn (jinja "{{ ansible_fqdn }}"))
  (opendkim__dkimkeys_path "/etc/dkimkeys")
  (opendkim__default_key_size "2048")
  (opendkim__default_keys (list
      
      (name "mail")))
  (opendkim__keys (list))
  (opendkim__group_keys (list))
  (opendkim__host_keys (list))
  (opendkim__combined_keys (jinja "{{ opendkim__default_keys
                             + opendkim__keys
                             + opendkim__group_keys
                             + opendkim__host_keys }}"))
  (opendkim__default_signing_table (list
      
      (name "mail")
      (from (jinja "{{ opendkim__domain }}"))
      (domain (jinja "{{ opendkim__domain }}"))
      (subdomains "True")))
  (opendkim__signing_table (list))
  (opendkim__group_signing_table (list))
  (opendkim__host_signing_table (list))
  (opendkim__combined_signing_table (jinja "{{ opendkim__default_signing_table
                                      + opendkim__signing_table
                                      + opendkim__group_signing_table
                                      + opendkim__host_signing_table }}"))
  (opendkim__default_trusted_hosts (list
      "127.0.0.1"
      "::1"
      "localhost"
      (jinja "{{ opendkim__fqdn }}")))
  (opendkim__trusted_hosts (list))
  (opendkim__group_trusted_hosts (list))
  (opendkim__host_trusted_hosts (list))
  (opendkim__combined_trusted_hosts (jinja "{{ opendkim__default_trusted_hosts
                                      + opendkim__trusted_hosts
                                      + opendkim__group_trusted_hosts
                                      + opendkim__host_trusted_hosts }}"))
  (opendkim__original_config (list
      
      (name "config-header")
      (comment "This is a basic configuration that can easily be adapted to suit a standard
installation. For more advanced options, see opendkim.conf(5) and/or
/usr/share/doc/opendkim/examples/opendkim.conf.sample.
")
      (state "hidden")
      
      (name "Syslog")
      (comment "Log to syslog")
      (value "True")
      
      (name "UMask")
      (comment "Required to use local socket with MTAs that access the socket as a non-
privileged user (e. g. Postfix)
")
      (value "002")
      
      (name "Domain")
      (comment "Sign for example.com with key in /etc/mail/dkim.key using
selector '2007' (e. g. 2007._domainkey.example.com)
")
      (value "example.com")
      (state "comment")
      
      (name "KeyFile")
      (value "/etc/mail/dkim.key")
      (state "comment")
      
      (name "Selector")
      (value "2007")
      (state "comment")
      
      (name "Canonicalization")
      (comment "Commonly-used options; the commented-out versions show the defaults.")
      (value "simple")
      (state "comment")
      
      (name "Mode")
      (value "sv")
      (state "comment")
      
      (name "Subdomains")
      (value "False")
      (state "comment")
      
      (name "OversignHeaders")
      (comment "Always oversign From (sign using actual From and a null From to prevent
malicious signatures header fields (From and/or others) between the signer
and the verifier.  From is oversigned by default in the Debian package
because it is often the identity key used by reputation systems and thus
somewhat security sensitive.
")
      (value (list
          "From"))
      
      (name "ResolverConfiguration")
      (comment "ResolverConfiguration filename
    default (none)

Specifies a configuration file to be passed to the Unbound library that
performs DNS queries applying the DNSSEC protocol.  See the Unbound
documentation at https://unbound.net/ for the expected content of this file.
The results of using this and the TrustAnchorFile setting at the same
time are undefined.
In Debian, /etc/unbound/unbound.conf is shipped as part of the Suggested
unbound package
")
      (value "/etc/unbound/unbound.conf")
      (state "comment")
      
      (name "TrustAnchorFile")
      (comment "TrustAnchorFile filename
    default (none)

Specifies a file from which trust anchor data should be read when doing
DNS queries and applying the DNSSEC protocol.  See the Unbound documentation
at https://unbound.net/ for the expected format of this file.
")
      (value "/usr/share/dns/root.key")))
  (opendkim__default_config (list
      
      (name "ResolverConfiguration")
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.unbound | d() and
                   (ansible_local.unbound.installed | d()) | bool)
               else \"ignore\" }}"))
      
      (name "TrustAnchorFile")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and ansible_local.unbound | d() and
                   (ansible_local.unbound.installed | d()) | bool)
               else \"ignore\" }}"))
      
      (name "Socket")
      (comment "Listen for connections in the Postfix chroot")
      (value "local:" (jinja "{{ opendkim__socket }}"))
      (state (jinja "{{ \"present\" if opendkim__postfix_integration | bool else \"ignore\" }}"))
      
      (name "UserID")
      (comment "Required by the systemd opendkim.service unit")
      (value (jinja "{{ opendkim__user + \":\" + opendkim__group }}"))
      
      (name "PidFile")
      (comment "Required by the systemd opendkim.service unit")
      (value "/run/opendkim/opendkim.pid")
      
      (name "KeyTable")
      (value (jinja "{{ opendkim__dkimkeys_path + \"/KeyTable\" }}"))
      (copy_id_from "Selector")
      (weight "1")
      
      (name "SigningTable")
      (value (jinja "{{ opendkim__dkimkeys_path + \"/SigningTable\" }}"))
      (copy_id_from "KeyTable")
      (weight "2")
      
      (name "InternalHosts")
      (value (jinja "{{ opendkim__dkimkeys_path + \"/TrustedHosts\" }}"))
      (copy_id_from "KeyTable")
      (weight "3")
      
      (name "ExternalIgnoreList")
      (value (jinja "{{ opendkim__dkimkeys_path + \"/TrustedHosts\" }}"))
      (copy_id_from "KeyTable")
      (weight "4")))
  (opendkim__config (list))
  (opendkim__group_config (list))
  (opendkim__host_config (list))
  (opendkim__combined_config (jinja "{{ opendkim__original_config
                               + opendkim__default_config
                               + opendkim__config
                               + opendkim__group_config
                               + opendkim__host_config }}"))
  (opendkim__postfix__dependent_maincf (list
      
      (name "smtpd_milters")
      (value (list
          
          (name "unix:/opendkim/opendkim.sock")
          (weight "-300")))
      (state "present")
      
      (name "non_smtpd_milters")
      (value (list
          
          (name "unix:/opendkim/opendkim.sock")
          (weight "-300")))
      (state "present"))))
