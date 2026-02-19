(playbook "debops/ansible/roles/mariadb_server/tasks/configure_server.yml"
  (tasks
    (task "Configure database server"
      (ansible.builtin.template 
        (src "etc/mysql/conf.d/mysqld.cnf.j2")
        (dest (jinja "{{ mariadb_server__mysqld_cnf_file }}"))
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Setup automysqlbackup configuration"
      (ansible.builtin.template 
        (src "etc/default/automysqlbackup.j2")
        (dest "/etc/default/automysqlbackup")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "mariadb_server__backup | d()"))
    (task "Enable events table backup in mysqldump"
      (community.general.ini_file 
        (dest "/etc/mysql/debian.cnf")
        (section "mysqldump")
        (option "events")
        (value "true")
        (mode "0600")))))
