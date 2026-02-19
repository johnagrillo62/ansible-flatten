(playbook "debops/ansible/roles/gitlab/defaults/main.yml"
  (gitlab__edition "community")
  (gitlab__preferred_version "*")
  (gitlab__base_packages (list
      (jinja "{{ \"gitlab-ce\"
        if (gitlab__edition == \"community\")
        else (\"gitlab-ee\"
              if (gitlab__edition == \"enterprise\")
              else []) }}")))
  (gitlab__packages (list))
  (gitlab__user "git")
  (gitlab__group "git")
  (gitlab__additional_groups (list
      (jinja "{{ (ansible_local.system_groups.local_prefix | d(\"\")) + \"sshusers\" }}")))
  (gitlab__comment "GitLab Omnibus main account")
  (gitlab__home "/var/opt/gitlab")
  (gitlab__shell "/bin/sh")
  (gitlab__fqdn "code." (jinja "{{ gitlab__domain }}"))
  (gitlab__domain (jinja "{{ ansible_domain }}"))
  (gitlab__registry_port "5050")
  (gitlab__firewall_ports (list
      "http"
      "https"
      "container-registry"))
  (gitlab__allow (list))
  (gitlab__group_allow (list))
  (gitlab__host_allow (list))
  (gitlab__initial_root_password (jinja "{{ lookup(\"password\", secret + \"/gitlab/credentials/\"
                                                      + \"root/initial_password\") }}"))
  (gitlab__pki_enabled (jinja "{{ (ansible_local.pki.enabled | d(False)) | bool }}"))
  (gitlab__pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (gitlab__pki_hook_path (jinja "{{ ansible_local.pki.hooks | d(\"/etc/pki/hooks\") }}"))
  (gitlab__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (gitlab__ssl_default_symlinks (list
      
      (link (jinja "{{ gitlab__fqdn + \".key\" }}"))
      (src (jinja "{{ gitlab__pki_path + \"/\" + gitlab__pki_realm + \"/private/key.pem\" }}"))
      
      (link (jinja "{{ gitlab__fqdn + \".crt\" }}"))
      (src (jinja "{{ gitlab__pki_path + \"/\" + gitlab__pki_realm + \"/public/chain.pem\" }}"))))
  (gitlab__ssl_symlinks (list))
  (gitlab__ssl_default_cacerts (list
      
      (link (jinja "{{ gitlab__pki_realm + \"-root.crt\" }}"))
      (src (jinja "{{ gitlab__pki_path + \"/\" + gitlab__pki_realm + \"/public/root.pem\" }}"))))
  (gitlab__ssl_cacerts (list))
  (gitlab__ldap_enabled (jinja "{{ True
                          if (ansible_local | d() and ansible_local.ldap | d() and
                              (ansible_local.ldap.enabled | d()) | bool)
                          else False }}"))
  (gitlab__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (gitlab__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (gitlab__ldap_self_rdn "uid=gitlab")
  (gitlab__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (gitlab__ldap_self_attributes 
    (uid (jinja "{{ gitlab__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ gitlab__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"GitLab\" service to access the LDAP directory"))
  (gitlab__ldap_binddn (jinja "{{ ([gitlab__ldap_self_rdn] + gitlab__ldap_device_dn) | join(\",\") }}"))
  (gitlab__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                                 + gitlab__ldap_binddn | to_uuid + \".password length=32\"))
                         if gitlab__ldap_enabled | bool
                         else \"\" }}"))
  (gitlab__ldap_label "LDAP")
  (gitlab__ldap_host (jinja "{{ ansible_local.ldap.hosts | d([\"\"]) | first }}"))
  (gitlab__ldap_port (jinja "{{ ansible_local.ldap.port | d(\"389\") }}"))
  (gitlab__ldap_encryption (jinja "{{ \"start_tls\"
                             if ((ansible_local.ldap.start_tls | d()) | bool)
                             else \"simple_tls\" }}"))
  (gitlab__ldap_timeout "10")
  (gitlab__ldap_activedirectory "False")
  (gitlab__ldap_account_attribute (jinja "{{ \"sAMAccountName\"
                                    if (gitlab__ldap_activedirectory | bool)
                                    else \"uid\" }}"))
  (gitlab__ldap_user_filter "(& (objectClass=inetOrgPerson) (| (authorizedService=all) (authorizedService=gitlab) (authorizedService=web:public) ) )")
  (gitlab__ldap_username_or_email_login (jinja "{{ True
                                          if (gitlab__ldap_account_attribute in
                                              [\"uid\", \"sAMAccountName\"])
                                          else False }}"))
  (gitlab__ldap_block_auto_created_users "False")
  (gitlab__ldap_lowercase_usernames "True")
  (gitlab__backup_enabled "True")
  (gitlab__backup_frequency "daily")
  (gitlab__backup_keep_time (jinja "{{ (60 * 60 * 24 * 7) | int }}"))
  (gitlab__backup_path "/var/opt/gitlab/backups")
  (gitlab__backup_exclude_directories (list))
  (gitlab__backup_default_environment 
    (CRON "1")
    (SKIP (jinja "{{ gitlab__backup_exclude_directories | join(\",\") }}")))
  (gitlab__backup_environment )
  (gitlab__default_configuration (list
      
      (name "preamble-comment")
      (title "GitLab configuration settings")
      (comment "This file is generated during initial installation and **is not** modified
during upgrades.
Check out the latest version of this file to know about the different
settings that can be configured, when they were introduced and why:
https://gitlab.com/gitlab-org/omnibus-gitlab/blame/master/files/gitlab-config-template/gitlab.rb.template

Locally, the complete template corresponding to the installed version can be found at:
/opt/gitlab/etc/gitlab.rb.template

You can run `gitlab-ctl diff-config` to compare the contents of the current gitlab.rb with
the gitlab.rb.template from the currently running version.

You can run `gitlab-ctl show-config` to display the configuration that will be generated by
running `gitlab-ctl reconfigure`
")
      (state "present")
      
      (name "external_url")
      (title "GitLab URL")
      (comment "URL on which GitLab will be reachable.
For more details on configuring external_url see:
https://docs.gitlab.com/omnibus/settings/configuration.html#configuring-the-external-url-for-gitlab
")
      (value (jinja "{{ ((\"https://\") if gitlab__pki_enabled | bool else (\"http://\"))
               + gitlab__fqdn }}"))
      
      (name "registry_external_url")
      (title "GitLab Container Registry URL")
      (comment "URL on which GitLab Container Registry will be reachable. By default we
use the same FQDN as the main GitLab installation with a separate TCP
port; see the documentation to find out how to publish the Registry on
a separate FQDN.
")
      (value (jinja "{{ ((\"https://\") if gitlab__pki_enabled | bool else (\"http://\"))
               + gitlab__fqdn + \":\" + gitlab__registry_port }}"))
      
      (name "roles")
      (title "Roles for multi-instance GitLab")
      (comment "The default is to have no roles enabled, which results in GitLab running as an all-in-one instance.
Options:
  redis_sentinel_role redis_master_role redis_replica_role geo_primary_role geo_secondary_role
  postgres_role consul_role application_role monitoring_role
For more details on each role, see:
https://docs.gitlab.com/omnibus/roles/README.html#roles
")
      (value (list
          "redis_sentinel_role"
          "redis_master_role"))
      (state "comment")
      
      (name "legend-comment")
      (title "Legend")
      (comment "The following notations at the beginning of each line may be used to
differentiate between components of this file and to easily select them using
a regex.
## Titles, subtitles etc
##! More information - Description, Docs, Links, Issues etc.
Configuration settings have a single # followed by a single space at the
beginning; Remove them to enable the setting.

**Configuration settings below are optional.**
")
      (state "present")
      
      (name "header-comment")
      (raw "################################################################################
################################################################################
##                Configuration Settings for GitLab CE and EE                 ##
################################################################################
################################################################################

################################################################################
## gitlab.yml configuration
##! Docs: https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/gitlab.yml.md
################################################################################
")
      (state "present")
      (separator "True")
      
      (name "gitlab_rails")
      (options (list
          
          (name "time_zone")
          (title "Set the time zone of the GitLab Omnibus installation")
          (value (jinja "{{ ansible_local.tzdata.timezone | d(\"UTC\") }}"))
          (state "present")
          
          (name "backup_path")
          (title "Absolute path where GitLab backups are stored")
          (value (jinja "{{ gitlab__backup_path }}"))
          (state (jinja "{{ \"present\"
                   if (gitlab__backup_path != \"/var/opt/gitlab/backups\")
                   else \"comment\" }}"))
          
          (name "backup_keep_time")
          (title "The duration in seconds to keep backups before they are allowed to be deleted")
          (value (jinja "{{ gitlab__backup_keep_time }}"))
          (state (jinja "{{ \"present\"
                   if (gitlab__backup_keep_time | string != \"604800\")
                   else \"comment\" }}"))
          
          (name "ldap_enabled")
          (title "LDAP Settings")
          (comment "Docs: https://docs.gitlab.com/omnibus/settings/ldap.html
**Be careful not to break the indentation in the ldap_servers block. It is
  in yaml format and the spaces must be retained. Using tabs will not work.**
")
          (value (jinja "{{ ansible_local.ldap.enabled | d(False) }}"))
          (state (jinja "{{ \"present\" if gitlab__ldap_enabled | bool else \"comment\" }}"))
          
          (name "prevent_ldap_sign_in")
          (value "False")
          (state "comment")
          
          (name "ldap_servers")
          (title "**remember to close this block with 'EOS' below**")
          (raw "gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
  main:  # 'main' is the GitLab 'provider ID' of this LDAP server
    label: '" (jinja "{{ gitlab__ldap_label }}") "'
    host: '" (jinja "{{ gitlab__ldap_host }}") "'
    port: " (jinja "{{ gitlab__ldap_port }}") "
    uid: '" (jinja "{{ gitlab__ldap_account_attribute }}") "'
    bind_dn: '" (jinja "{{ gitlab__ldap_binddn }}") "'
    password: '" (jinja "{{ gitlab__ldap_bindpw }}") "'
    encryption: '" (jinja "{{ gitlab__ldap_encryption }}") "' # \"start_tls\" or \"simple_tls\" or \"plain\"
    verify_certificates: true
    smartcard_auth: false
    active_directory: " (jinja "{{ gitlab__ldap_activedirectory | lower }}") "
    allow_username_or_email_login: " (jinja "{{ gitlab__ldap_username_or_email_login | lower }}") "
    lowercase_usernames: " (jinja "{{ gitlab__ldap_lowercase_usernames | lower }}") "
    block_auto_created_users: " (jinja "{{ gitlab__ldap_block_auto_created_users | lower }}") "
    base: '" (jinja "{{ gitlab__ldap_base_dn | join(\",\") }}") "'
    user_filter: '" (jinja "{{ gitlab__ldap_user_filter }}") "'
    ## EE only
    group_base: ''
    admin_group: ''
    sync_ssh_keys: false
EOS
")
          (state (jinja "{{ \"present\" if gitlab__ldap_enabled | bool else \"comment\" }}"))))
      
      (name "nginx")
      (options (list
          
          (name "redirect_http_to_https")
          (title "Enable HTTP to HTTPS redirection in nginx")
          (value (jinja "{{ True if gitlab__pki_enabled | bool else False }}"))
          (state "present")))
      
      (name "package")
      (options (list
          
          (name "modify_kernel_parameters")
          (comment "Attempt to modify kernel parameters. To skip this in containers where
the relevant file system is read-only, set the value to false.
")
          (value (jinja "{{ False
                   if (\"container\" in (ansible_virtualization_tech_guest | d([])))
                   else True }}"))
          (state (jinja "{{ \"present\"
                   if (\"container\" in (ansible_virtualization_tech_guest | d([])))
                   else \"comment\" }}"))))))
  (gitlab__configuration (list))
  (gitlab__group_configuration (list))
  (gitlab__host_configuration (list))
  (gitlab__combined_configuration (jinja "{{ gitlab__default_configuration
                                    + gitlab__configuration
                                    + gitlab__group_configuration
                                    + gitlab__host_configuration }}"))
  (gitlab__apt_preferences__dependent_list (list
      
      (filename "gitlab.pref")
      (package (jinja "{{ \"gitlab-ce\"
                 if (gitlab__edition == \"community\")
                 else (\"gitlab-ee\"
                       if (gitlab__edition == \"enterprise\")
                       else \"\") }}"))
      (version (jinja "{{ gitlab__preferred_version }}"))
      (state "present")))
  (gitlab__etc_services__dependent_list (list
      
      (name "container-registry")
      (port (jinja "{{ gitlab__registry_port }}"))
      (protocols (list
          "tcp"))
      (comment "GitLab Omnibus Container Registry")))
  (gitlab__keyring__dependent_apt_keys (list
      
      (id "F640 3F65 44A3 8863 DAA0  B6E0 3F01 618A 5131 2F3F")
      (repo "deb https://packages.gitlab.com/gitlab/gitlab-ee/debian/ " (jinja "{{ ansible_distribution_release }}") " main")
      (filename "gitlab_ee")
      (state (jinja "{{ \"present\"
               if (gitlab__edition == \"enterprise\")
               else \"absent\" }}"))))
  (gitlab__extrepo__dependent_sources (list
      
      (name "gitlab_ce")
      (state (jinja "{{ \"present\"
               if (gitlab__edition == \"community\")
               else \"absent\" }}"))))
  (gitlab__ferm__dependent_rules (list
      
      (name "gitlab_services")
      (type "accept")
      (by_role "debops.gitlab")
      (dport (jinja "{{ gitlab__firewall_ports }}"))
      (saddr (jinja "{{ gitlab__allow + gitlab__group_allow + gitlab__host_allow }}"))
      (accept_any "True")
      (rule_state "present")))
  (gitlab__ldap__dependent_tasks (list
      
      (name "Create GitLab account for " (jinja "{{ gitlab__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ gitlab__ldap_binddn }}"))
      (objectClass (jinja "{{ gitlab__ldap_self_object_classes }}"))
      (attributes (jinja "{{ gitlab__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\" if gitlab__ldap_device_dn | d() else \"ignore\" }}")))))
