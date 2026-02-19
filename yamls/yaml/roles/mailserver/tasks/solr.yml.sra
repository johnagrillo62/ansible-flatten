(playbook "yaml/roles/mailserver/tasks/solr.yml"
  (tasks
    (task "Install Solr and related packages"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "dovecot-solr"
          "solr-tomcat"))
      (tags (list
          "dependencies")))
    (task "Work around Debian bug and copy Solr schema file into place"
      (copy "src=solr-schema.xml dest=/etc/solr/conf/schema.xml group=root owner=root"))
    (task "Copy tweaked Tomcat config file into place"
      (copy "src=etc_tomcat7_server.xml dest=/etc/tomcat7/server.xml group=tomcat7 owner=root")
      (notify "restart solr"))
    (task "Copy tweaked Solr config file into place"
      (copy "src=etc_solr_conf_solrconfig.xml dest=/etc/solr/conf/solrconfig.xml group=root owner=root")
      (notify "restart solr"))
    (task "Create Solr index directory"
      (file "state=directory path=/decrypted/solr group=tomcat7 owner=tomcat7")
      (notify "restart solr"))))
