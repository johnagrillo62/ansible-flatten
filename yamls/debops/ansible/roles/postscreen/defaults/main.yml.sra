(playbook "debops/ansible/roles/postscreen/defaults/main.yml"
  (postscreen__deploy_state "present")
  (postscreen__access (list))
  (postscreen__group_access (list))
  (postscreen__host_access (list))
  (postscreen__combined_access (jinja "{{ postscreen__access
                                 + postscreen__group_access
                                 + postscreen__host_access }}"))
  (postscreen__dnsbl_enabled (jinja "{{ True
                               if ((ansible_all_ipv4_addresses | d([])
                                    + ansible_all_ipv6_addresses | d([]))
                                   | ansible.utils.ipaddr(\"public\"))
                               else False }}"))
  (postscreen__dnsbl_providers (list
      "spamhaus"
      "cbl"
      "spamcop"
      "mailspike"))
  (postscreen__dnsbl_sites (list
      
      (name "zen.spamhaus.org*3")
      (state (jinja "{{ \"present\"
               if \"spamhaus\" in postscreen__dnsbl_providers
               else \"absent\" }}"))
      
      (name "b.barracudacentral.org*2")
      (state (jinja "{{ \"present\"
               if \"barracuda\" in postscreen__dnsbl_providers
               else \"absent\" }}"))
      
      (name "cbl.abuseat.org*2")
      (state (jinja "{{ \"present\"
               if \"cbl\" in postscreen__dnsbl_providers
               else \"absent\" }}"))
      
      (name "bl.spameatingmonkey.net*2")
      (state (jinja "{{ \"present\"
               if \"spameatingmonkey\" in postscreen__dnsbl_providers
               else \"absent\" }}"))
      
      (name "backscatter.spameatingmonkey.net*2")
      (state (jinja "{{ \"present\"
               if \"spameatingmonkey\" in postscreen__dnsbl_providers
               else \"absent\" }}"))
      
      (name "bl.spamcop.net")
      (state (jinja "{{ \"present\"
               if \"spamcop\" in postscreen__dnsbl_providers
               else \"absent\" }}"))
      
      (name "psbl.surriel.com")
      (state (jinja "{{ \"present\"
               if \"psbl\" in postscreen__dnsbl_providers
               else \"absent\" }}"))
      
      (name "bl.mailspike.net")
      (state (jinja "{{ \"present\"
               if \"mailspike\" in postscreen__dnsbl_providers
               else \"absent\" }}"))))
  (postscreen__dnsbl_wl_sites (list
      "list.dnswl.org=127.[0..255].[0..255].0*-2"
      "list.dnswl.org=127.[0..255].[0..255].1*-3"
      "list.dnswl.org=127.[0..255].[0..255].[2..255]*-4"))
  (postscreen__dnsbl_reply_pcre_map (list
      "/^zen\\.spamhaus\\.org$/"
      "/^b\\.barracudacentral\\.org$/"
      "/^bl\\.spameatingmonkey\\.net$/"
      "/^backscatter\\.spameatingmonkey\\.net$/"
      "/^bl\\.spamcop\\.net$/"
      "/^psbl\\.surriel\\.com$/"
      "/^bl\\.mailspike\\.net$/"))
  (postscreen__dnsbl_default_reply "blocked by RBL, see http://multirbl.valli.org/")
  (postscreen__postfix__dependent_packages (list
      "postfix-pcre"))
  (postscreen__postfix__dependent_maincf (list
      
      (name "postscreen_blacklist_action")
      (value "drop")
      (state "present")
      
      (name "postscreen_greet_action")
      (value "enforce")
      (state "present")
      
      (name "postscreen_dnsbl_action")
      (value "enforce")
      (state "present")
      
      (name "postscreen_access_list")
      (value (list
          "permit_mynetworks"
          "cidr:${config_directory}/postscreen_access.cidr"))
      (state "present")
      
      (name "postscreen_dnsbl_sites")
      (value (jinja "{{ postscreen__dnsbl_sites + postscreen__dnsbl_wl_sites }}"))
      (state (jinja "{{ \"present\"
               if postscreen__dnsbl_enabled | bool
               else \"comment\" }}"))
      
      (name "postscreen_dnsbl_reply_map")
      (value (list
          "pcre:${config_directory}/postscreen_dnsbl_reply_map.pcre"))
      (state (jinja "{{ \"present\"
               if postscreen__dnsbl_enabled | bool
               else \"comment\" }}"))
      
      (name "postscreen_dnsbl_threshold")
      (value "3")
      (state (jinja "{{ \"present\"
               if postscreen__dnsbl_enabled | bool
               else \"comment\" }}"))
      
      (name "postscreen_dnsbl_whitelist_threshold")
      (value "-1")
      (state (jinja "{{ \"present\"
               if postscreen__dnsbl_enabled | bool
               else \"comment\" }}"))
      
      (name "postscreen_whitelist_interfaces")
      (value (list
          "static:all"))
      (state "present")
      
      (name "postscreen_pipelining_enable")
      (value "True")
      (state "present")
      
      (name "postscreen_pipelining_action")
      (value "enforce")
      (state "present")
      
      (name "postscreen_non_smtp_command_enable")
      (value "True")
      (state "present")
      
      (name "postscreen_non_smtp_command_action")
      (value "drop")
      (state "present")
      
      (name "postscreen_bare_newline_enable")
      (value "True")
      (state "present")
      
      (name "postscreen_bare_newline_action")
      (value "ignore")
      (state "present")))
  (postscreen__postfix__dependent_mastercf (list
      
      (name "smtp")
      (state (jinja "{{ \"comment\"
               if (postscreen__deploy_state == \"present\")
               else \"ignore\" }}"))
      
      (name "postscreen")
      (state (jinja "{{ \"present\"
               if (postscreen__deploy_state == \"present\")
               else \"ignore\" }}"))
      
      (name "smtpd")
      (state (jinja "{{ \"present\"
               if (postscreen__deploy_state == \"present\")
               else \"ignore\" }}"))
      
      (name "dnsblog")
      (state (jinja "{{ \"present\"
               if (postscreen__deploy_state == \"present\")
               else \"ignore\" }}"))
      
      (name "tlsproxy")
      (state (jinja "{{ \"present\"
               if (postscreen__deploy_state == \"present\")
               else \"ignore\" }}")))))
