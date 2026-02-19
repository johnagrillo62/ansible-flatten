(playbook "ansible-for-devops/lamp-infrastructure/playbooks/db/main.yml"
    (play
    (hosts "lamp_db")
    (become "yes")
    (vars_files (list
        "vars.yml"))
    (pre_tasks
      (task "Create dynamic MySQL variables."
        (set_fact 
          (mysql_users (list
              
              (name "mycompany_user")
              (host (jinja "{{ groups['lamp_www'][0] }}"))
              (password "secret")
              (priv "*.*:SELECT")
              
              (name "mycompany_user")
              (host (jinja "{{ groups['lamp_www'][1] }}"))
              (password "secret")
              (priv "*.*:SELECT")))
          (mysql_replication_master (jinja "{{ groups['a4d.lamp.db.1'][0] }}")))))
    (roles
      "geerlingguy.firewall"
      "geerlingguy.mysql")))
