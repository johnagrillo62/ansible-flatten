(playbook "debops/ansible/roles/imapproxy/defaults/main.yml"
  (imapproxy__packages (list))
  (imapproxy__base_packages (list
      "imapproxy"))
  (imapproxy__domain (jinja "{{ ansible_domain }}"))
  (imapproxy__imap_srv_rr (jinja "{{ q(\"dig_srv\", \"_imap._tcp.\" + imapproxy__domain,
                              \"imap.\" + imapproxy__domain, 143) }}"))
  (imapproxy__imaps_srv_rr (jinja "{{ q(\"dig_srv\", \"_imaps._tcp.\" + imapproxy__domain,
                               \"imap.\" + imapproxy__domain, 993) }}"))
  (imapproxy__imap_fqdn (jinja "{{ ansible_fqdn
                          if (ansible_local | d() and ansible_local.dovecot | d() and
                             (ansible_local.dovecot.installed | d()) | bool)
                          else imapproxy__imap_srv_rr[0][\"target\"]
                              if imapproxy__imap_srv_rr[0][\"dig_srv_src\"] | d(\"\") != \"fallback\"
                              else imapproxy__imaps_srv_rr[0][\"target\"] }}"))
  (imapproxy__imap_port (jinja "{{ \"143\"
                          if (imapproxy__imap_fqdn == ansible_fqdn)
                          else imapproxy__imap_srv_rr[0][\"port\"]
                              if imapproxy__imap_srv_rr[0][\"dig_srv_src\"] | d(\"\") != \"fallback\"
                              else imapproxy__imaps_srv_rr[0][\"port\"] }}"))
  (imapproxy__listen_address "127.0.0.1")
  (imapproxy__listen_port "1143")
  (imapproxy__allow (list))
  (imapproxy__group_allow (list))
  (imapproxy__host_allow (list))
  (imapproxy__pki (jinja "{{ ansible_local.pki.enabled | d() | bool }}"))
  (imapproxy__pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (imapproxy__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (imapproxy__pki_ca (jinja "{{ ansible_local.pki.ca | d(\"CA.crt\") }}"))
  (imapproxy__pki_crt (jinja "{{ ansible_local.pki.crt | d(\"default.crt\") }}"))
  (imapproxy__pki_key (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (imapproxy__tls_ca_path "/etc/ssl/certs")
  (imapproxy__tls_ca_file (jinja "{{ imapproxy__tls_ca_path + \"/ca-certificates.crt\" }}"))
  (imapproxy__tls_cert_file (jinja "{{ (imapproxy__pki_path + \"/\" + imapproxy__pki_realm + \"/\" + imapproxy__pki_crt)
                            if imapproxy__pki | bool else \"/etc/ssl/certs/ssl-cert-snakeoil.pem\" }}"))
  (imapproxy__tls_key_file (jinja "{{ (imapproxy__pki_path + \"/\" + imapproxy__pki_realm + \"/\" + imapproxy__pki_key)
                           if imapproxy__pki | bool else \"/etc/ssl/private/ssl-cert-snakeoil.key\" }}"))
  (imapproxy__tls_force (jinja "{{ \"no\" if (imapproxy__imap_fqdn == ansible_fqdn or
                                   not imapproxy_pki | d(True))
                          else \"yes\" }}"))
  (imapproxy__pki_hook_name "imapproxy")
  (imapproxy__pki_hook_path (jinja "{{ ansible_local.pki.hooks | d(\"/etc/pki/hooks\") }}"))
  (imapproxy__pki_hook_action "restart")
  (imapproxy__default_configuration (list
      
      (name "server_hostname")
      (comment "This setting controls which IMAP server we proxy our connections to.
")
      (value (jinja "{{ imapproxy__imap_fqdn }}"))
      
      (name "server_port")
      (comment "This setting specifies the port that server_hostname is listening on.
This is the TCP port that we proxy inbound connections to.

The original config file contains this note:
If you are using SSL with IMAP Proxy, note that unless the server is
highly non-standard, this should still be set to the server's normal,
unencrypted IMAP port and should NOT be set to port 993, since IMAP
Proxy uses STARTTLS to encrypt a \"normal\" IMAP connection.

But note that there is nothing \"non-standard\" about only supporting
IMAPS over 993 (see RFC8314).

If the server is only available via (encrypted) port 993, please
consult the README.ssl file for help.
")
      (value (jinja "{{ imapproxy__imap_port }}"))
      
      (name "listen_address")
      (comment "This setting specifies which address the proxy server will bind to and
accept incoming connections to.  If undefined, bind to all.
Must be a dotted decimal IP address.
")
      (value (jinja "{{ imapproxy__listen_address }}"))
      
      (name "listen_port")
      (comment "This setting specifies which port the proxy server will bind to and
accept incoming connections from.
")
      (value (jinja "{{ imapproxy__listen_port }}"))
      
      (name "connect_retries")
      (comment "This setting controls how many times we retry connecting to our server.
")
      (value "10")
      
      (name "connect_delay")
      (comment "This setting controls the delay between retries in seconds.
")
      (value "5")
      
      (name "cache_size")
      (comment "This setting determines how many in-core IMAP connection structures
will be allocated.  As such, it determines not only how many cached
connections will be allowed, but really the total number of simultaneous
connections, cached and active.
")
      (value "3072")
      
      (name "cache_expiration_time")
      (comment "This setting controls how many seconds an inactive connection will be
cached.
")
      (value "300")
      
      (name "proc_username")
      (comment "This setting controls which username the IMAP proxy process will run as.
It is not allowed to run as \"root\".
")
      (value "nobody")
      
      (name "proc_groupname")
      (comment "This setting controls which groupname the IMAP proxy process will run as.
")
      (value "nogroup")
      
      (name "stat_filename")
      (comment "This is the path to the filename that the proxy server mmap()s to
write statistical data to.  This is the file that pimpstat needs to
look at to be able to provide its useful stats.
")
      (value "/var/run/pimpstats")
      
      (name "protocol_log_filename")
      (comment "protocol logging may only be turned on for one user at a time.  All
protocol logging data is written to the file specified by this path.
")
      (value "/dev/null")
      
      (name "syslog_facility")
      (comment "The logging facility to be used for all syslog calls.  If nothing is
specified here, it will default to LOG_MAIL.  Any of the possible
facilities listed in the syslog(3) manpage may be used here except
LOG_KERN.
")
      (value "LOG_MAIL")
      
      (name "syslog_prioritymask")
      (comment "This configuration option is provided as a way to limit the verbosity
of imapproxy.  If no value is specified, it will default to no priority
mask and you'll see all possible log messages.  Any of the possible
priority values listed in the syslog(3) manpage may be used here.  By
default, you will see all possible log messages.
")
      (value "LOG_WARNING")
      
      (name "send_tcp_keepalives")
      (comment "This determines whether the SO_KEEPALIVE option will be set on all
sockets.
")
      (value "no")
      
      (name "enable_select_cache")
      (comment "This configuration option allows you to turn select caching on or off.
When select caching is enabled, imapproxy will cache SELECT responses
from an IMAP server.
")
      (value "no")
      
      (name "foreground_mode")
      (comment "This will prevent imapproxy from detaching from its parent process and
controlling terminal on startup.
")
      (value "no")
      
      (name "force_tls")
      (comment "Force imapproxy to use STARTTLS even if LOGIN is not disabled (unsecured
connections will not be used).
")
      (value (jinja "{{ imapproxy__tls_force }}"))
      
      (name "chroot_directory")
      (comment "This allows imapproxy to run in a chroot jail if desired.
If commented out, imapproxy will not run chroot()ed.  If a directory is
specified here, imapproxy will chroot() to that directory.
")
      (value "/var/lib/imapproxy/chroot")
      
      (name "preauth_command")
      (comment "Arbitrary command that can be sent to the server before
authenticating users.  This can be useful to access non-
standard IMAP servers such as Yahoo!, which requires
(required?) the following command to be sent before
authentication is allowed:
   ID (\"GUID\" \"1\")
(See: http://en.wikipedia.org/wiki/Yahoo!_Mail&oldid=447046431#Free_IMAP_and_SMTPs_access )
To use such a command, this setting should look like this:
   preauth_command ID (\"GUID\" \"1\")
No matter what this command is, it is expected to return an
OK response
")
      (value "")
      (state "comment")
      
      (name "enable_admin_commands")
      (comment "Used to enable or disable the internal imapproxy administrative commands.
")
      (value "no")
      
      (name "tls_ca_path")
      (comment "TLS configuration options
")
      (value (jinja "{{ imapproxy__tls_ca_path }}"))
      (state (jinja "{{ \"present\" if imapproxy__pki | d(True) else \"comment\" }}"))
      
      (name "tls_ca_file")
      (value (jinja "{{ imapproxy__tls_ca_file }}"))
      (state (jinja "{{ \"present\" if imapproxy__pki | d(True) else \"comment\" }}"))
      
      (name "tls_cert_file")
      (value (jinja "{{ imapproxy__tls_cert_file }}"))
      (state (jinja "{{ \"present\" if imapproxy__pki | d(True) else \"comment\" }}"))
      
      (name "tls_key_file")
      (value (jinja "{{ imapproxy__tls_key_file }}"))
      (state (jinja "{{ \"present\" if imapproxy__pki | d(True) else \"comment\" }}"))
      
      (name "tls_verify_server")
      (value "yes")
      (state (jinja "{{ \"present\" if imapproxy__pki | d(True) else \"comment\" }}"))
      
      (name "tls_ciphers")
      (value "ALL:!aNULL:!eNULL")
      (state (jinja "{{ \"present\" if imapproxy__pki | d(True) else \"comment\" }}"))
      
      (name "tls_no_tlsv1")
      (comment "Set any of these to \"yes\" if the corresponding TLS version is not
sufficiently secure for your needs.
")
      (value "yes")
      (state (jinja "{{ \"present\" if imapproxy__pki | d(True) else \"comment\" }}"))
      
      (name "tls_no_tlsv1.1")
      (value "yes")
      (state (jinja "{{ \"present\" if imapproxy__pki | d(True) else \"comment\" }}"))
      
      (name "tls_no_tlsv1.2")
      (value "no")
      (state (jinja "{{ \"present\" if imapproxy__pki | d(True) else \"comment\" }}"))
      
      (name "auth_sasl_plain_username")
      (comment "Authenticate using SASL AUTHENTICATE PLAIN

The following authentication username and password are used
along with the username from the client as the authorization
identity.  In order to avoid having the service wide open (no
password needed from the client), the client is required to
send the auth_shared_secret in leiu of a user password.

NOTE: This functionality *assumes* that the server supports
      AUTHENTICATE PLAIN, and it does *not* verify this by
      looking at the server's capabilities list.
")
      (value "")
      (state "comment")
      
      (name "auth_sasl_plain_password")
      (value "")
      (state "comment")
      
      (name "auth_shared_secret")
      (value "")
      (state "comment")
      
      (name "dns_rr")
      (comment "Use DNS round robin to cycle through all returned RRs we
got when looking up the IMAP server with getaddrinfo().
Default is no.
")
      (value "yes")
      (state "comment")
      
      (name "ipversion_only")
      (comment "Limit DNS requests to AF_INET or AF_INET6

Set ipversion_only to 4 or 6 accordingly.
Default if unset is AF_UNSPEC for both A and AAAA.
")
      (value "6")
      (state "comment")))
  (imapproxy__configuration (list))
  (imapproxy__group_configuration (list))
  (imapproxy__host_configuration (list))
  (imapproxy__combined_configuration (jinja "{{ imapproxy__default_configuration
                                        + imapproxy__configuration
                                        + imapproxy__group_configuration
                                        + imapproxy__host_configuration }}"))
  (imapproxy__etc_services__dependent_list (list
      
      (name "imapproxy")
      (port (jinja "{{ imapproxy__listen_port }}"))
      (comment "IMAP Proxy Server")
      (protocol (list
          "tcp"))))
  (imapproxy__ferm__dependent_rules (list
      
      (name "imapproxy")
      (type "accept")
      (dport (list
          "imapproxy"))
      (saddr (jinja "{{ imapproxy__allow + imapproxy__group_allow + imapproxy__host_allow }}"))
      (weight "40")
      (accept_any "False")
      (by_role "debops.imapproxy"))))
