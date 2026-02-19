(playbook "debops/ansible/roles/pgbadger/defaults/main.yml"
  (pgbadger__base_packages (list
      "pgbadger"))
  (pgbadger__packages (list))
  (pgbadger__user "pgbadger")
  (pgbadger__group "pgbadger")
  (pgbadger__additional_groups (list
      "adm"))
  (pgbadger__home (jinja "{{ (ansible_local.fhs.www | d(\"/srv/www\")) + \"/\" + pgbadger__user }}"))
  (pgbadger__comment "pgBadger")
  (pgbadger__ssh_accounts_enabled "True")
  (pgbadger__ssh_inventory_group "debops_service_postgresql_server")
  (pgbadger__ssh_user "pgbadger")
  (pgbadger__ssh_group "pgbadger")
  (pgbadger__ssh_additional_groups (list
      (jinja "{{ (ansible_local.system_groups.local_prefix | d(\"\")) + \"sshusers\" }}")
      "adm"))
  (pgbadger__ssh_home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\")) + \"/\" + pgbadger__user }}"))
  (pgbadger__ssh_public_key_file (jinja "{{ pgbadger__home + \"/.ssh/id_rsa.pub\" }}"))
  (pgbadger__fqdn (jinja "{{ \"pgbadger.\" + ansible_domain }}"))
  (pgbadger__www_root (jinja "{{ pgbadger__home + \"/sites/\" + pgbadger__fqdn + \"/public\" }}"))
  (pgbadger__nginx_access_policy "")
  (pgbadger__nginx_auth_realm "pgBadger access is restricted")
  (pgbadger__scripts_path (jinja "{{ pgbadger__home + \"/scripts\" }}"))
  (pgbadger__scripts_command "pgbadger --quiet --start-monday")
  (pgbadger__cron_deploy_state "present")
  (pgbadger__cron_interval "daily")
  (pgbadger__default_instances (list
      
      (name "local")
      (output "local.html")
      (host "localhost")
      (state (jinja "{{ \"present\"
               if (inventory_hostname in (groups[pgbadger__ssh_inventory_group] | d([])))
               else \"absent\" }}"))))
  (pgbadger__instances (list))
  (pgbadger__group_instances (list))
  (pgbadger__host_instances (list))
  (pgbadger__combined_instances (jinja "{{ pgbadger__default_instances
                                  + pgbadger__instances
                                  + pgbadger__group_instances
                                  + pgbadger__host_instances }}"))
  (pgbadger__nginx__dependent_servers (list
      
      (name (jinja "{{ pgbadger__fqdn }}"))
      (filename "debops.pgbadger")
      (root (jinja "{{ pgbadger__www_root }}"))
      (webroot_create "False")
      (access_policy (jinja "{{ pgbadger__nginx_access_policy }}"))
      (auth_basic_realm (jinja "{{ pgbadger__nginx_auth_realm }}"))
      (location_list (list
          
          (pattern "/")
          (options "try_files $uri $uri/ $uri.html $uri.htm $uri/index.html =404;
autoindex on;
")))
      (state "present"))))
