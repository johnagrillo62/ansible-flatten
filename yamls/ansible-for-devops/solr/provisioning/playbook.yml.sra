(playbook "ansible-for-devops/solr/provisioning/playbook.yml"
    (play
    (hosts "all")
    (become "true")
    (vars_files (list
        "vars.yml"))
    (pre_tasks
      (task "Update apt cache if needed."
        (apt "update_cache=true cache_valid_time=3600")))
    (tasks
      (task "Install Java."
        (apt "name=openjdk-11-jdk state=present"))
      (task "Download Solr."
        (get_url 
          (url "https://archive.apache.org/dist/lucene/solr/" (jinja "{{ solr_version }}") "/solr-" (jinja "{{ solr_version }}") ".tgz")
          (dest (jinja "{{ download_dir }}") "/solr-" (jinja "{{ solr_version }}") ".tgz")
          (checksum (jinja "{{ solr_checksum }}"))))
      (task "Expand Solr."
        (unarchive 
          (src (jinja "{{ download_dir }}") "/solr-" (jinja "{{ solr_version }}") ".tgz")
          (dest (jinja "{{ download_dir }}"))
          (remote_src "true")
          (creates (jinja "{{ download_dir }}") "/solr-" (jinja "{{ solr_version }}") "/README.txt")))
      (task "Run Solr installation script."
        (command (jinja "{{ download_dir }}") "/solr-" (jinja "{{ solr_version }}") "/bin/install_solr_service.sh " (jinja "{{ download_dir }}") "/solr-" (jinja "{{ solr_version }}") ".tgz -i /opt -d /var/solr -u solr -s solr -p 8983 creates=" (jinja "{{ solr_dir }}") "/bin/solr
"))
      (task "Ensure solr is started and enabled on boot."
        (service "name=solr state=started enabled=yes")))))
