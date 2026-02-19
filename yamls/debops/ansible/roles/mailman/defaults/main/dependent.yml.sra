(playbook "debops/ansible/roles/mailman/defaults/main/dependent.yml"
  (mailman__python__dependent_packages3 (list
      (jinja "{{ [\"python3-django-auth-ldap\"]
        if mailman__ldap_enabled | bool
        else [] }}")
      (jinja "{{ [\"python3-psycopg2\"]
        if (mailman__database_type == \"postgresql\")
        else [] }}")
      (jinja "{{ [\"python3-pymysql\", \"python3-mysqldb\"]
        if (mailman__database_type == \"mysql\")
        else [] }}")))
  (mailman__python__dependent_packages2 (list
      (jinja "{{ [\"python-django-auth-ldap\"]
        if mailman__ldap_enabled | bool
        else [] }}")
      (jinja "{{ [\"python-psycopg2\"]
        if (mailman__database_type == \"postgresql\")
        else [] }}")
      (jinja "{{ [\"python-pymysql\", \"python-mysqldb\"]
        if (mailman__database_type == \"mysql\")
        else [] }}")))
  (mailman__ldap__dependent_tasks (list
      
      (name (jinja "{{ \"Create Mailman 3 account for \"
              + mailman__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ mailman__ldap_bind_dn }}"))
      (objectClass (jinja "{{ mailman__ldap_self_object_classes }}"))
      (attributes (jinja "{{ mailman__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))))
  (mailman__postfix__dependent_maincf (list
      
      (name "owner_request_special")
      (value "False")
      (state "present")
      
      (name "transport_maps")
      (value (list
          "hash:/var/lib/mailman3/data/postfix_lmtp"))
      (state "present")
      
      (name "local_recipient_maps")
      (value (list
          "proxy:unix:passwd.byname"
          "$alias_maps"
          "hash:/var/lib/mailman3/data/postfix_lmtp"))
      (state "present")
      
      (name "relay_domains")
      (value (list
          "hash:/var/lib/mailman3/data/postfix_domains"))
      (state "present")))
  (mailman__nginx__dependent_upstreams (list
      
      (name "mailman3")
      (server "unix:/run/mailman3-web/uwsgi.sock fail_timeout=0")))
  (mailman__nginx__dependent_servers (list
      
      (by_role "debops.mailman")
      (enabled "True")
      (name (jinja "{{ [mailman__fqdn] + mailman__additional_domains }}"))
      (redirect_from "True")
      (filename "debops.mailman")
      (location_list (list
          
          (pattern "^/mailman/?$")
          (pattern_prefix "~* ")
          (options "return 301 /postorius/lists/;")
          (state "present")
          
          (pattern "^/mailman/listinfo/?$")
          (pattern_prefix "~* ")
          (options "return 301 /postorius/lists/;")
          (state "present")
          
          (pattern "^/mailman/listinfo/(.+)/?$")
          (pattern_prefix "~* ")
          (options "return 301 /postorius/lists/$1." (jinja "{{ mailman__fqdn }}") "/;")
          (state "present")
          
          (pattern "^/pipermail/?$")
          (pattern_prefix "~* ")
          (options "return 301 /hyperkitty/;")
          (state "present")
          
          (pattern "^/pipermail/(.+)/?$")
          (pattern_prefix "~* ")
          (options "return 301 /hyperkitty/list/$1@" (jinja "{{ mailman__fqdn }}") "/;")
          (state "present")
          
          (pattern "/")
          (options "uwsgi_pass mailman3;
include /etc/nginx/uwsgi_params;
")
          (state "present")
          
          (pattern "/mailman3/static")
          (options "alias /var/lib/mailman3/web/static;
")
          (state "present")
          
          (pattern "/mailman3/static/favicon.ico")
          (options "alias /var/lib/mailman3/web/static/postorius/img/favicon.ico;
")
          (state "present"))))))
