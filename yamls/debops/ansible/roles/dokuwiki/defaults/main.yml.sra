(playbook "debops/ansible/roles/dokuwiki/defaults/main.yml"
  (dokuwiki__fqdn "wiki." (jinja "{{ ansible_domain }}"))
  (dokuwiki__domains (jinja "{{ [dokuwiki__fqdn] +
                       dokuwiki__farm_animals | d([]) }}"))
  (dokuwiki__nginx_auth_realm "Wiki access is restricted")
  (dokuwiki__nginx_access_policy "")
  (dokuwiki__nginx_filename "debops.dokuwiki")
  (dokuwiki__user "dokuwiki")
  (dokuwiki__group "dokuwiki")
  (dokuwiki__home (jinja "{{ ansible_local.nginx.www | d(\"/srv/www\") + \"/\" + dokuwiki__user }}"))
  (dokuwiki__shell "/bin/false")
  (dokuwiki__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                   + \"/\" + dokuwiki__user }}"))
  (dokuwiki__www (jinja "{{ ansible_local.nginx.www | d(\"/srv/www\") + \"/\" + dokuwiki__user }}"))
  (dokuwiki__webserver_user (jinja "{{ ansible_local.nginx.user | d(\"www-data\") }}"))
  (dokuwiki__git_repo "https://github.com/splitbrain/dokuwiki.git")
  (dokuwiki__git_dest (jinja "{{ dokuwiki__src + \"/\" + dokuwiki__git_repo.split(\"://\")[1] }}"))
  (dokuwiki__git_version "stable")
  (dokuwiki__git_checkout (jinja "{{ dokuwiki__www + \"/sites/\" + dokuwiki__domains[0] + \"/public\" }}"))
  (dokuwiki__ldap_enabled (jinja "{{ True
                            if (ansible_local | d() and ansible_local.ldap | d() and
                                (ansible_local.ldap.enabled | d()) | bool)
                            else False }}"))
  (dokuwiki__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (dokuwiki__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (dokuwiki__ldap_self_rdn "uid=dokuwiki")
  (dokuwiki__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (dokuwiki__ldap_self_attributes 
    (uid (jinja "{{ dokuwiki__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ dokuwiki__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"DokuWiki\" service to access the LDAP directory"))
  (dokuwiki__ldap_binddn (jinja "{{ ([dokuwiki__ldap_self_rdn] + dokuwiki__ldap_device_dn) | join(\",\") }}"))
  (dokuwiki__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                                   + dokuwiki__ldap_binddn | to_uuid + \".password length=32\"))
                           if dokuwiki__ldap_enabled | bool
                           else \"\" }}"))
  (dokuwiki__ldap_people_rdn (jinja "{{ ansible_local.ldap.people_rdn | d(\"ou=People\") }}"))
  (dokuwiki__ldap_people_dn (jinja "{{ [dokuwiki__ldap_people_rdn] + dokuwiki__ldap_base_dn }}"))
  (dokuwiki__ldap_private_groups "True")
  (dokuwiki__ldap_groups_rdn (jinja "{{ ansible_local.ldap.groups_rdn | d(\"ou=Groups\") }}"))
  (dokuwiki__ldap_groups_dn (jinja "{{ ([dokuwiki__ldap_groups_rdn, dokuwiki__ldap_self_rdn]
                               + dokuwiki__ldap_device_dn)
                              if dokuwiki__ldap_private_groups | bool
                              else ([dokuwiki__ldap_groups_rdn] + dokuwiki__ldap_base_dn) }}"))
  (dokuwiki__ldap_admin_group_rdn "cn=DokuWiki Administrators")
  (dokuwiki__ldap_admin_group_dn (jinja "{{ [dokuwiki__ldap_admin_group_rdn]
                                   + dokuwiki__ldap_groups_dn }}"))
  (dokuwiki__ldap_object_owner_rdn "uid=" (jinja "{{ lookup(\"env\", \"USER\") }}"))
  (dokuwiki__ldap_object_ownerdn (jinja "{{ ([dokuwiki__ldap_object_owner_rdn, dokuwiki__ldap_people_rdn]
                                    + dokuwiki__ldap_base_dn) | join(\",\") }}"))
  (dokuwiki__ldap_server_uri (jinja "{{ ansible_local.ldap.uri | d([\"\"]) | first }}"))
  (dokuwiki__ldap_server_port (jinja "{{ ansible_local.ldap.port | d(\"389\" if dokuwiki__ldap_start_tls | bool else \"636\") }}"))
  (dokuwiki__ldap_start_tls (jinja "{{ ansible_local.ldap.start_tls
                              if (ansible_local | d() and ansible_local.ldap | d() and
                                  (ansible_local.ldap.start_tls | d()) | bool)
                              else True }}"))
  (dokuwiki__ldap_user_filter "(& (objectClass=inetOrgPerson) (| (uid=%{user}) (mail=%{user}) ) (| (authorizedService=all) (authorizedService=dokuwiki) (authorizedService=web:public) ) )")
  (dokuwiki__ldap_group_filter "(& (objectClass=groupOfNames) (member=%{dn}) )")
  (dokuwiki__ldap_configuration "$conf['useacl'] = 1;
$conf['authtype'] = 'authldap';
$conf['superuser'] = '" (jinja "{{ \"@\" + dokuwiki__ldap_admin_group_rdn.split(\"=\")[1] }}") "';
$conf['plugin']['authldap']['server'] = '" (jinja "{{ dokuwiki__ldap_server_uri }}") "';
$conf['plugin']['authldap']['port'] = '" (jinja "{{ dokuwiki__ldap_server_port }}") "';
$conf['plugin']['authldap']['usertree'] = '" (jinja "{{ dokuwiki__ldap_people_dn | join(\",\") }}") "';
$conf['plugin']['authldap']['grouptree'] = '" (jinja "{{ dokuwiki__ldap_groups_dn | join(\",\") }}") "';
$conf['plugin']['authldap']['userfilter'] = '" (jinja "{{ dokuwiki__ldap_user_filter }}") "';
$conf['plugin']['authldap']['groupfilter'] = '" (jinja "{{ dokuwiki__ldap_group_filter }}") "';
$conf['plugin']['authldap']['version'] = 3;
$conf['plugin']['authldap']['starttls'] = " (jinja "{{ \"1\" if dokuwiki__ldap_start_tls | bool else \"0\" }}") ";
$conf['plugin']['authldap']['referrals'] = '0';
$conf['plugin']['authldap']['deref'] = '0';
$conf['plugin']['authldap']['binddn'] = '" (jinja "{{ dokuwiki__ldap_binddn }}") "';
$conf['plugin']['authldap']['bindpw'] = '" (jinja "{{ dokuwiki__ldap_bindpw }}") "';
$conf['plugin']['authldap']['userscope'] = 'sub';
$conf['plugin']['authldap']['groupscope'] = 'sub';
$conf['plugin']['authldap']['userkey'] = 'uid';
$conf['plugin']['authldap']['groupkey'] = 'cn';
$conf['plugin']['authldap']['debug'] = 0;
$conf['plugin']['authldap']['modPass'] = 0;
")
  (dokuwiki__protected_conf_php (jinja "{% if dokuwiki__ldap_enabled | bool %}") "
" (jinja "{{ dokuwiki__ldap_configuration }}") "
" (jinja "{% endif %}") "
")
  (dokuwiki__protected_plugins_php (jinja "{% if dokuwiki__ldap_enabled | bool %}") "
$plugins['authldap'] = 1;
" (jinja "{% endif %}") "
")
  (dokuwiki__local_mime_types_conf "# Extra allowed MIME Types
txt     text/plain
tex     text/plain
conf    text/plain
xml     text/xml
csv     text/csv
svg     image/svg+xml
epub    application/epub+zip
")
  (dokuwiki__base_packages (list
      "curl"))
  (dokuwiki__packages (list))
  (dokuwiki__plugins_enabled "True")
  (dokuwiki__plugins (list))
  (dokuwiki__default_plugins (jinja "{{ dokuwiki__plugins_editor +
                               dokuwiki__plugins_syntax +
                               dokuwiki__plugins_git }}"))
  (dokuwiki__plugins_editor (list
      
      (repo "https://github.com/cosmocode/edittable.git")
      (dest "edittable")
      
      (repo "https://gitlab.com/albertgasset/dokuwiki-plugin-codemirror.git")
      (dest "codemirror")))
  (dokuwiki__plugins_syntax (list
      
      (repo "https://github.com/cosmocode/dig.git")
      (dest "dig")
      
      (repo "https://github.com/grantemsley/dokuwiki-plugin-patchpanel.git")
      (dest "patchpanel")
      (state "absent")
      
      (repo "https://github.com/GreenItSolutions/dokuwiki-plugin-switchpanel.git")
      (dest "switchpanel")
      
      (repo "https://github.com/ashrafhasson/dokuwiki-plugin-advrack.git")
      (dest "advrack")
      (state "absent")
      
      (repo "https://github.com/glensc/dokuwiki-plugin-pageredirect.git")
      (dest "pageredirect")
      
      (repo "https://github.com/selfthinker/dokuwiki_plugin_wrap")
      (dest "wrap")
      
      (repo "https://github.com/splitbrain/dokuwiki-plugin-graphviz.git")
      (dest "graphviz")
      
      (repo "https://github.com/leibler/dokuwiki-plugin-todo.git")
      (dest "todo")
      
      (repo "https://github.com/splitbrain/dokuwiki-plugin-gallery")
      (dest "gallery")
      
      (repo "https://github.com/dokufreaks/plugin-tag")
      (dest "tag")
      
      (repo "https://github.com/dokufreaks/plugin-pagelist")
      (dest "pagelist")
      
      (repo "https://github.com/tgarc/dokuwiki-plugin-rst")
      (dest "rst")
      (state "absent")))
  (dokuwiki__plugins_git (list
      
      (repo "https://github.com/kossmac/dokuwiki-plugin-gitlab")
      (dest "gitlab")
      (state "absent")
      
      (repo "https://github.com/ZJ/ghissues.git")
      (dest "ghissues")
      (state "absent")
      
      (repo "https://github.com/splitbrain/dokuwiki-plugin-gh.git")
      (dest "gh")))
  (dokuwiki__templates (list))
  (dokuwiki__default_templates (jinja "{{ dokuwiki__templates_vector }}"))
  (dokuwiki__templates_vector (list
      
      (repo "https://github.com/arsava/dokuwiki-template-vector")
      (dest "vector")))
  (dokuwiki__extra_files (list))
  (dokuwiki__group_extra_files (list))
  (dokuwiki__host_extra_files (list))
  (dokuwiki__farm "True")
  (dokuwiki__farm_path (jinja "{{ dokuwiki__www + \"/farm\" }}"))
  (dokuwiki__farm_animals (list))
  (dokuwiki__max_file_size "30")
  (dokuwiki__python__dependent_packages3 (list
      "python3-docutils"))
  (dokuwiki__python__dependent_packages2 (list
      "python-docutils"))
  (dokuwiki__ldap__dependent_tasks (list
      
      (name "Create DokuWiki account for " (jinja "{{ dokuwiki__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ dokuwiki__ldap_binddn }}"))
      (objectClass (jinja "{{ dokuwiki__ldap_self_object_classes }}"))
      (attributes (jinja "{{ dokuwiki__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\" if dokuwiki__ldap_device_dn | d() else \"ignore\" }}"))
      
      (name "Create DokuWiki group container for " (jinja "{{ dokuwiki__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ dokuwiki__ldap_groups_dn }}"))
      (objectClass "organizationalStructure")
      (attributes 
        (ou (jinja "{{ dokuwiki__ldap_groups_rdn.split(\"=\")[1] }}"))
        (description "User groups used in DokuWiki"))
      (state (jinja "{{ \"present\"
               if (dokuwiki__ldap_device_dn | d() and
                   dokuwiki__ldap_private_groups | bool)
               else \"ignore\" }}"))
      
      (name "Create DokuWiki admin group for " (jinja "{{ dokuwiki__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ dokuwiki__ldap_admin_group_dn }}"))
      (objectClass "groupOfNames")
      (attributes 
        (cn (jinja "{{ dokuwiki__ldap_admin_group_rdn.split(\"=\")[1] }}"))
        (owner (jinja "{{ dokuwiki__ldap_object_ownerdn }}"))
        (member (jinja "{{ dokuwiki__ldap_object_ownerdn }}")))
      (state (jinja "{{ \"present\" if dokuwiki__ldap_device_dn | d() else \"ignore\" }}"))))
  (dokuwiki__php__dependent_packages (list
      (list
        "gmp"
        "curl"
        "ldap"
        "xml")))
  (dokuwiki__php__dependent_pools (list
      
      (name "dokuwiki")
      (user (jinja "{{ dokuwiki__user }}"))
      (group (jinja "{{ dokuwiki__group }}"))
      (owner (jinja "{{ dokuwiki__user }}"))
      (home (jinja "{{ dokuwiki__home }}"))
      (php_admin_values 
        (post_max_size (jinja "{{ dokuwiki__max_file_size }}") "M")
        (upload_max_filesize (jinja "{{ dokuwiki__max_file_size }}") "M"))))
  (dokuwiki__nginx__dependent_upstreams (list
      
      (name "php_dokuwiki")
      (type "php")
      (php_pool "dokuwiki")))
  (dokuwiki__nginx__dependent_servers (list
      
      (name (jinja "{{ dokuwiki__domains }}"))
      (filename (jinja "{{ dokuwiki__nginx_filename }}"))
      (by_role "debops.dokuwiki")
      (type "php")
      (root (jinja "{{ dokuwiki__git_checkout }}"))
      (webroot_create "False")
      (access_policy (jinja "{{ dokuwiki__nginx_access_policy }}"))
      (auth_basic_realm (jinja "{{ dokuwiki__nginx_auth_realm }}"))
      (index "index.html index.htm index.php doku.php")
      (options "autoindex off;
client_max_body_size " (jinja "{{ dokuwiki__max_file_size }}") "M;
client_body_buffer_size 128k;
")
      (location 
        (/ "try_files $uri $uri/ @dokuwiki;
")
        (@dokuwiki "rewrite ^/_media/(.*)           /lib/exe/fetch.php?media=$1   last;
rewrite ^/_detail/(.*)          /lib/exe/detail.php?media=$1  last;
rewrite ^/_export/([^/]+)/(.*)  /doku.php?do=export_$1&id=$2  last;
rewrite ^/(.*)                  /doku.php?id=$1               last;
")
        (~ ^/lib.*\.(gif|png|ico|jpg)$ "expires 31536000s;
add_header Pragma \"public\";
add_header Cache-Control \"max-age=31536000, public, must-revalidate, proxy-revalidate\";
log_not_found off;
")
        (~ /(data|conf|bin|inc|install.php)/ "deny all;
"))
      (php_upstream "php_dokuwiki")
      (php_options "fastcgi_intercept_errors        on;
fastcgi_ignore_client_abort     off;
fastcgi_connect_timeout         60;
fastcgi_send_timeout            180;
fastcgi_read_timeout            180;
fastcgi_buffer_size             128k;
fastcgi_buffers               4 256k;
fastcgi_busy_buffers_size       256k;
fastcgi_temp_file_write_size    256k;
"))))
