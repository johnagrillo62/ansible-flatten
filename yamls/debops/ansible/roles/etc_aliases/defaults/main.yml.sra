(playbook "debops/ansible/roles/etc_aliases/defaults/main.yml"
  (etc_aliases__rfc2142_compliant "True")
  (etc_aliases__admin_private_email (jinja "{{ ansible_local.core.admin_private_email | d(\"root@\" + etc_aliases__domain) }}"))
  (etc_aliases__domain (jinja "{{ ansible_domain }}"))
  (etc_aliases__rfc2142_recipients (list
      
      (name "info")
      (dest "staff")
      (comment "Packaged information about the organization,
products and/or services, as appropriate.
")
      (section "business")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "marketing")
      (dest "staff")
      (comment "Product marketing and marketing communications.")
      (section "business")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "sales")
      (dest "staff")
      (comment "Product purchase information.")
      (section "business")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "support")
      (dest "staff")
      (comment "Problems with products or services.")
      (section "business")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "abuse")
      (dest "root")
      (comment "Inappropriate public behaviour.")
      (section "network")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "noc")
      (to "root")
      (comment "Network infrastructure.")
      (section "network")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (alias "security")
      (to "root")
      (comment "Security bulletins or queries.")
      (section "network")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "postmaster")
      (dest "root")
      (section "support")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "hostmaster")
      (dest "root")
      (section "support")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "usenet")
      (dest "root")
      (section "support")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "news")
      (dest "usenet")
      (section "support")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "webmaster")
      (dest "root")
      (section "support")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "www")
      (dest "webmaster")
      (section "support")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "uucp")
      (dest "root")
      (section "support")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "ftp")
      (dest "root")
      (section "support")
      (state (jinja "{{ \"present\"
               if etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))))
  (etc_aliases__default_recipients (list
      
      (name "root")
      (dest (jinja "{{ etc_aliases__admin_private_email }}"))
      (section "admin")
      (weight "-10")
      
      (name "admin")
      (dest "root")
      (section "admin")
      (weight "-8")
      
      (name "hostmaster")
      (dest "root")
      (section "admin")
      (weight "-8")
      (state (jinja "{{ \"present\"
               if not etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "operator")
      (dest "root")
      (section "admin")
      (weight "-8")
      
      (name "backup")
      (dest "root")
      (section "admin")
      (weight "-5")
      
      (name "monitoring")
      (dest "root")
      (section "admin")
      (weight "-5")
      
      (name "staff")
      (dest "root")
      (section "admin")
      
      (name "postmaster")
      (dest "root")
      (section "system")
      (state (jinja "{{ \"present\"
               if not etc_aliases__rfc2142_compliant | bool
               else \"ignore\" }}"))
      
      (name "MAILER-DAEMON")
      (dest "postmaster")
      (section "system")
      
      (name "noreply")
      (dest "devnull")
      (section "system")
      (weight "10")
      
      (name "devnull")
      (dest "/dev/null")
      (section "system")
      (weight "20")))
  (etc_aliases__recipients (list))
  (etc_aliases__group_recipients (list))
  (etc_aliases__host_recipients (list))
  (etc_aliases__dependent_recipients (list))
  (etc_aliases__dependent_recipients_filter (jinja "{{ lookup(\"template\",
                                              \"lookup/etc_aliases__dependent_recipients_filter.j2\")
                                              | from_yaml }}"))
  (etc_aliases__combined_recipients (jinja "{{ etc_aliases__rfc2142_recipients
                                       + etc_aliases__default_recipients
                                       + etc_aliases__dependent_recipients_filter
                                       + etc_aliases__recipients
                                       + etc_aliases__group_recipients
                                       + etc_aliases__host_recipients }}"))
  (etc_aliases__sections (list
      
      (name "admin")
      (title "IT Operations mail aliases")
      
      (name "unknown")
      (title "User mail aliases")
      
      (name "business")
      (title "RFC 2142: Business-related mail aliases")
      
      (name "network")
      (title "RFC 2142: Network Operations mail aliases")
      
      (name "support")
      (title "RFC 2142: Mail aliases for specific host services")
      
      (name "system")
      (title "Internal mail system aliases"))))
