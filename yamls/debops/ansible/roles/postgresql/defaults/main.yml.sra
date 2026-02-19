(playbook "debops/ansible/roles/postgresql/defaults/main.yml"
  (postgresql__upstream "False")
  (postgresql__upstream_key_id "B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8")
  (postgresql__upstream_apt_repo "deb http://apt.postgresql.org/pub/repos/apt " (jinja "{{ ansible_distribution_release }}") "-pgdg main")
  (postgresql__base_packages (list
      "postgresql-client"))
  (postgresql__python_packages (list))
  (postgresql__packages (list))
  (postgresql__preferred_version "")
  (postgresql__user "postgres")
  (postgresql__server (jinja "{{ ansible_local.postgresql.server
                        if (ansible_local.postgresql.server | d() and
                            ansible_local.postgresql.server != \"localhost\")
                        else \"\" }}"))
  (postgresql__port "5432")
  (postgresql__delegate_to (jinja "{{ postgresql__server
                             if (postgresql__server | d() and
                                 postgresql__server != \"localhost\")
                             else inventory_hostname }}"))
  (postgresql__password_hostname (jinja "{{ postgresql__delegate_to
                                   if (postgresql__delegate_to != omit)
                                   else inventory_hostname }}"))
  (postgresql__password_length "64")
  (postgresql__password_characters "ascii_letters,digits,.-_~&()*=")
  (postgresql__default_database "*")
  (postgresql__default_user_clusters (list
      
      (user "*")
      (group "*")
      (cluster (jinja "{{ (postgresql__server + \":\" + postgresql__port)
                  if (postgresql__server | d() and postgresql__server)
                  else \"main\" }}"))
      (database (jinja "{{ postgresql__default_database }}"))))
  (postgresql__user_clusters (list))
  (postgresql__roles (list))
  (postgresql__dependent_roles (list))
  (postgresql__groups (list))
  (postgresql__dependent_groups (list))
  (postgresql__databases (list))
  (postgresql__dependent_databases (list))
  (postgresql__privileges (list))
  (postgresql__dependent_privileges (list))
  (postgresql__extensions (list))
  (postgresql__dependent_extensions (list))
  (postgresql__pgpass (list))
  (postgresql__dependent_pgpass (list))
  (postgresql__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ postgresql__upstream_key_id }}"))
      (repo (jinja "{{ postgresql__upstream_apt_repo }}"))
      (state (jinja "{{ \"present\" if postgresql__upstream | bool else \"absent\" }}"))))
  (postgresql__python__dependent_packages3 (list
      "python3-psycopg2"))
  (postgresql__python__dependent_packages2 (list
      "python-psycopg2")))
