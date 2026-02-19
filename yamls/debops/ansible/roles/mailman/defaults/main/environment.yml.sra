(playbook "debops/ansible/roles/mailman/defaults/main/environment.yml"
  (mailman__base_packages (list
      "mailman3-full"
      "lynx"
      (jinja "{{ \"dbconfig-pgsql\"
        if (mailman__database_type == \"postgresql\")
        else [] }}")
      (jinja "{{ \"dbconfig-mysql\"
        if (mailman__database_type == \"mysql\")
        else [] }}")))
  (mailman__packages (list))
  (mailman__user "list")
  (mailman__group "list")
  (mailman__domain (jinja "{{ ansible_domain }}"))
  (mailman__fqdn "lists." (jinja "{{ mailman__domain }}"))
  (mailman__additional_domains (list))
  (mailman__database_type (jinja "{{ ansible_local.mailman.database_class.split(\".\")[2]
                            if (ansible_local | d() and ansible_local.mailman is defined)
                            else (\"postgresql\"
                                  if (ansible_local.postgresql is defined)
                                  else (\"mysql\"
                                        if (ansible_local.mariadb is defined)
                                        else \"sqlite\")) }}"))
  (mailman__superuser_name (jinja "{{ ansible_local.core.admin_users[0]
                             if (ansible_local.core.admin_users | d())
                             else \"admin\" }}"))
  (mailman__superuser_email (jinja "{{ ansible_local.core.admin_private_email[0]
                              if (ansible_local.core.admin_private_email | d())
                              else (\"postmaster@\" + mailman__domain) }}")))
