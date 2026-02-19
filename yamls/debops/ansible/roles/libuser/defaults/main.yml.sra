(playbook "debops/ansible/roles/libuser/defaults/main.yml"
  (libuser__enabled "True")
  (libuser__base_packages (list
      "libuser"))
  (libuser__packages (list))
  (libuser__original_configuration (list
      
      (name "import")
      (options (list
          
          (name "login_defs")
          (comment "Data from these files is used when libuser.conf does not define a value.
The mapping is documented in the man page.
")
          (value "/etc/login.defs")
          (state "present")
          
          (name "default_useradd")
          (value "/etc/default/useradd")
          (state "present")))
      
      (name "defaults")
      (options (list
          
          (name "moduledir")
          (comment "The default (/usr/lib*/libuser) is usually correct")
          (value "/your/custom/directory")
          (state "comment")
          
          (name "skeleton")
          (comment "The following variables are usually imported:")
          (value "/etc/skel")
          (state "comment")
          (separator "True")
          
          (name "mailspooldir")
          (value "/var/mail")
          (state "comment")
          
          (name "crypt_style")
          (value "sha512")
          (state "present")
          (separator "True")
          
          (name "modules")
          (value "files shadow")
          (state "present")
          
          (name "create_modules")
          (value "files shadow")
          (state "present")
          
          (name "modules_with_ldap")
          (option "modules")
          (value "files shadow ldap")
          (state "comment")
          
          (name "create_modules_with_ldap")
          (option "create_modules")
          (value "ldap")
          (state "comment")))
      
      (name "userdefaults")
      (options (list
          
          (name "LU_USERNAME")
          (value "%n")
          (state "present")
          
          (name "LU_UIDNUMBER")
          (comment "This is better imported from /etc/login.defs:")
          (value "500")
          (state "comment")
          
          (name "LU_GIDNUMBER")
          (value "%u")
          (state "present")
          
          (name "LU_USERPASSWORD")
          (value "!!")
          (state "comment")
          
          (name "LU_GECOS")
          (value "%n")
          (state "comment")
          
          (name "LU_HOMEDIRECTORY")
          (value "/home/%n")
          (state "comment")
          
          (name "LU_LOGINSHELL")
          (value "/bin/bash")
          (state "comment")
          
          (name "LU_SHADOWNAME")
          (value "%n")
          (state "comment")
          (separator "True")
          
          (name "LU_SHADOWPASSWORD")
          (value "!!")
          (state "comment")
          
          (name "LU_SHADOWLASTCHANGE")
          (value "%d")
          (state "comment")
          
          (name "LU_SHADOWMIN")
          (value "0")
          (state "comment")
          
          (name "LU_SHADOWMAX")
          (value "99999")
          (state "comment")
          
          (name "LU_SHADOWWARNING")
          (value "7")
          (state "comment")
          
          (name "LU_SHADOWINACTIVE")
          (value "-1")
          (state "comment")
          
          (name "LU_SHADOWEXPIRE")
          (value "-1")
          (state "comment")
          
          (name "LU_SHADOWFLAG")
          (value "-1")
          (state "comment")))
      
      (name "groupdefaults")
      (options (list
          
          (name "LU_GROUPNAME")
          (value "%n")
          (state "present")
          
          (name "LU_GIDNUMBER")
          (comment "This is better imported from /etc/login.defs:")
          (value "500")
          (state "comment")
          
          (name "LU_GROUPPASSWORD")
          (value "!!")
          (state "comment")
          (separator "True")
          
          (name "LU_MEMBERUID")
          (state "comment")
          
          (name "LU_ADMINISTRATORUID")
          (state "comment")))
      
      (name "files")
      (options (list
          
          (name "directory")
          (comment "This is useful for the case where some master files are used to
populate a different NSS mechanism which this workstation uses.
")
          (value "/etc")
          (state "comment")))
      
      (name "shadow")
      (options (list
          
          (name "directory")
          (comment "This is useful for the case where some master files are used to
populate a different NSS mechanism which this workstation uses.
")
          (value "/etc")
          (state "comment")))
      
      (name "ldap")
      (options (list
          
          (name "server")
          (comment "Setting these is always necessary.")
          (value "ldap")
          (state "comment")
          
          (name "basedn")
          (value "dc=example,dc=com")
          (state "comment")
          
          (name "userBranch")
          (comment "Setting these is rarely necessary, since it's usually correct.")
          (value "ou=People")
          (state "comment")
          (separator "True")
          
          (name "groupBranch")
          (value "ou=Group")
          (state "comment")
          
          (name "binddn")
          (comment "Set only if your administrative user uses simple bind operations to
connect to the server.
")
          (value "cn=Manager,dc=example,dc=com")
          (state "comment")
          (separator "True")
          
          (name "user")
          (comment "Set this only if the default user (as determined by SASL) is incorrect
for SASL bind operations.  Usually, it's correct, so you'll rarely need
to set these.
")
          (value "Manager")
          (state "comment")
          (separator "True")
          
          (name "authuser")
          (value "Manager")
          (state "comment")))
      
      (name "sasl")
      (options (list
          
          (name "appname")
          (comment "Set these only if your sasldb is only used by a particular application, and
in a particular domain.  The default (all applications, all domains) is
probably correct for most installations.
")
          (value "imap")
          (state "comment")
          
          (name "domain")
          (value "EXAMPLE.COM")
          (state "comment")))))
  (libuser__configuration (list))
  (libuser__group_configuration (list))
  (libuser__host_configuration (list))
  (libuser__combined_configuration (jinja "{{ libuser__original_configuration
                                     + libuser__configuration
                                     + libuser__group_configuration
                                     + libuser__host_configuration }}")))
