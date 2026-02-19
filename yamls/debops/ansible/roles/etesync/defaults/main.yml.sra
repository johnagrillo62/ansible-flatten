(playbook "debops/ansible/roles/etesync/defaults/main.yml"
  (etesync__domain (jinja "{{ ansible_domain }}"))
  (etesync__fqdn "etesync." (jinja "{{ etesync__domain }}"))
  (etesync__base_packages (list
      "git"))
  (etesync__packages (list))
  (etesync__user "etesync")
  (etesync__group "etesync")
  (etesync__gecos "EteSync")
  (etesync__shell "/usr/sbin/nologin")
  (etesync__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                   + \"/\" + etesync__user }}"))
  (etesync__etc "/etc/etesync-server")
  (etesync__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                  + \"/\" + etesync__user }}"))
  (etesync__lib (jinja "{{ (ansible_local.fhs.lib | d(\"/usr/local/lib\"))
                  + \"/\" + etesync__user }}"))
  (etesync__data (jinja "{{ (ansible_local.fhs.data | d(\"/srv\"))
                   + \"/\" + etesync__user }}"))
  (etesync__git_gpg_key_id "9E21 F091 FC39 5F36 6A47  43E2 D2E5 84C3 7C47 7933")
  (etesync__git_repo "https://github.com/etesync/server.git")
  (etesync__git_version "b026643cceae07b039942bf0c990ccf917eb072a")
  (etesync__git_dest (jinja "{{ etesync__src + \"/\" + etesync__git_repo.split(\"://\")[1] }}"))
  (etesync__git_checkout (jinja "{{ etesync__lib + \"/app\" }}"))
  (etesync__virtualenv (jinja "{{ etesync__lib + \"/virtualenv\" }}"))
  (etesync__config_allowed_hosts (list
      (jinja "{{ ansible_hostname }}")
      (jinja "{{ ansible_fqdn }}")
      (jinja "{{ etesync__fqdn }}")
      "localhost"
      "[::1]"
      "127.0.0.1"))
  (etesync__config_secret_key (jinja "{{ lookup(\"password\", secret + \"/etesync/\" +
                                etesync__domain + \"/config/secret_key length=64\") }}"))
  (etesync__config_secret_key_filepath (jinja "{{ etesync__etc + \"/secret.txt\" }}"))
  (etesync__superuser_name (jinja "{{ ansible_local.core.admin_users[0]
                             if (ansible_local.core.admin_users | d())
                             else \"admin\" }}"))
  (etesync__superuser_email (jinja "{{ ansible_local.core.admin_private_email[0]
                              if (ansible_local.core.admin_private_email | d())
                              else (\"root@\" + etesync__domain) }}"))
  (etesync__superuser_password (jinja "{{ lookup(\"password\", secret + \"/etesync/\" +
                                 inventory_hostname + \"/superuser/\" +
                                 etesync__superuser_name + \"/password\") }}"))
  (etesync__app_name (jinja "{{ etesync__user }}"))
  (etesync__app_runtime_dir (jinja "{{ \"gunicorn\"
                              if (ansible_distribution_release in
                                  [\"trusty\", \"xenial\"])
                              else \"gunicorn-etesync\" }}"))
  (etesync__app_bind "unix:/run/" (jinja "{{ etesync__app_runtime_dir }}") "/etesync.sock")
  (etesync__app_workers (jinja "{{ ansible_processor_vcpus | int + 1 }}"))
  (etesync__app_timeout "900")
  (etesync__app_params (list
      "--name=" (jinja "{{ etesync__app_name }}")
      "--bind=" (jinja "{{ etesync__app_bind }}")
      "--workers=" (jinja "{{ etesync__app_workers }}")
      "--timeout=" (jinja "{{ etesync__app_timeout }}")
      "etesync_server.wsgi"))
  (etesync__max_file_size "5")
  (etesync__python_version (jinja "{{ ansible_local.python.version3 | d(\"3.x\") }}"))
  (etesync__http_psk_subpath_enabled "False")
  (etesync__http_psk_subpath (jinja "{{ lookup(\"password\", secret + \"/etesync/\" +
                                 inventory_hostname + \"/config/subpath chars=ascii_letters,digits length=23\")
                               if etesync__http_psk_subpath_enabled | bool
                               else \"\" }}"))
  (etesync__url (jinja "{{ \"https://\" + etesync__fqdn + \"/\" + etesync__http_psk_subpath }}"))
  (etesync__admin_auth_basic_realm "Access to EteSync admin interface is restricted")
  (etesync__admin_auth_basic_filename "")
  (etesync__mail_to (list
      "root@" (jinja "{{ ansible_domain }}")))
  (etesync__mail_subject "PSK subpath URL to EteSync on " (jinja "{{ ansible_fqdn }}"))
  (etesync__mail_body "EteSync has been deployed for the first time on " (jinja "{{ ansible_fqdn }}") ".
You have chosen to deploy the service on a random subpath thus the URL is
needed to access the service.

URL: " (jinja "{{ etesync__url }}") "

You can continue the user setup in the Django administration interface of EteSync over at:
" (jinja "{{ etesync__url }}") "/admin

Have a nice day :)
")
  (etesync__keyring__dependent_gpg_keys (list
      
      (user (jinja "{{ etesync__user }}"))
      (group (jinja "{{ etesync__group }}"))
      (home (jinja "{{ etesync__home }}"))
      (id (jinja "{{ etesync__git_gpg_key_id }}"))))
  (etesync__python__dependent_packages3 (list
      "python3-setproctitle"
      "python3-dev"
      "python3-tz"))
  (etesync__gunicorn__dependent_applications (list
      
      (name "etesync")
      (mode "wsgi")
      (working_dir (jinja "{{ etesync__git_checkout }}"))
      (python (jinja "{{ etesync__virtualenv + \"/bin/python3\" }}"))
      (user (jinja "{{ etesync__user }}"))
      (group (jinja "{{ etesync__group }}"))
      (home (jinja "{{ etesync__home }}"))
      (system "True")
      (timeout (jinja "{{ etesync__app_timeout }}"))
      (workers (jinja "{{ etesync__app_workers }}"))
      (args (jinja "{{ etesync__app_params }}"))))
  (etesync__nginx__dependent_upstreams (list
      
      (name "etesync")
      (server (jinja "{{ etesync__app_bind }}"))))
  (etesync__nginx__dependent_servers (list
      
      (name (jinja "{{ etesync__fqdn }}"))
      (by_role "debops.etesync")
      (filename "debops.etesync")
      (favicon "False")
      (http_referrer_policy "same-origin")
      (options "client_max_body_size " (jinja "{{ etesync__max_file_size }}") "M;
")
      (location_list (list
          
          (pattern "/")
          (options "deny all;")
          (enabled (jinja "{{ etesync__http_psk_subpath_enabled | bool }}"))
          
          (pattern "/static/admin/")
          (options "alias " (jinja "{{ etesync__virtualenv + \"/lib/python\" + (etesync__python_version.split('.')[:2] | join('.')) }}") "/site-packages/django/contrib/admin/static/admin/;")
          
          (pattern "/static/rest_framework/")
          (options "alias " (jinja "{{ etesync__virtualenv + \"/lib/python\" + (etesync__python_version.split('.')[:2] | join('.')) }}") "/site-packages/rest_framework/static/rest_framework/;")
          
          (pattern "/" (jinja "{{ etesync__http_psk_subpath }}"))
          (options "proxy_pass http://etesync;
proxy_set_header X-Forwarded-Host $server_name;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-Proto $scheme;
" (jinja "{% if etesync__http_psk_subpath %}") "
proxy_set_header SCRIPT_NAME /" (jinja "{{ etesync__http_psk_subpath }}") ";
" (jinja "{% endif %}") "
proxy_connect_timeout " (jinja "{{ etesync__app_timeout }}") ";
proxy_send_timeout " (jinja "{{ etesync__app_timeout }}") ";
proxy_read_timeout " (jinja "{{ etesync__app_timeout }}") ";")
          
          (pattern (jinja "{{ ((\"/\" + etesync__http_psk_subpath)
                      if (etesync__http_psk_subpath_enabled | bool)
                      else \"\") + \"/admin\" }}"))
          (options "proxy_pass http://etesync;
proxy_set_header X-Forwarded-Host $server_name;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-Proto $scheme;
" (jinja "{% if etesync__http_psk_subpath_enabled | bool %}") "
proxy_set_header SCRIPT_NAME /" (jinja "{{ etesync__http_psk_subpath }}") ";
" (jinja "{% endif %}") "
proxy_connect_timeout " (jinja "{{ etesync__app_timeout }}") ";
proxy_send_timeout " (jinja "{{ etesync__app_timeout }}") ";
proxy_read_timeout " (jinja "{{ etesync__app_timeout }}") ";

auth_basic \"" (jinja "{{ etesync__admin_auth_basic_realm }}") "\";
auth_basic_user_file " (jinja "{{ etesync__admin_auth_basic_filename }}") ";")
          (enabled (jinja "{{ True if (etesync__admin_auth_basic_filename != \"\") else False }}")))))))
