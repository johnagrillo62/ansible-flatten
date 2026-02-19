(playbook "ansible-for-devops/lamp-infrastructure/playbooks/db/vars.yml"
  (firewall_allowed_tcp_ports (list
      "22"
      "3306"))
  (mysql_replication_user 
    (name "replication")
    (password "secret"))
  (mysql_databases (list
      
      (name "mycompany_database")
      (collation "utf8_general_ci")
      (encoding "utf8"))))
