(playbook "ansible-galaxy/tasks/download.yml"
  (tasks
    (task "Download Galaxy"
      (block (list
          
          (name "Check for Galaxy download receipt")
          (stat 
            (path (jinja "{{ galaxy_server_dir }}") "/" (jinja "{{ galaxy_commit_id }}") "_receipt"))
          (register "download_receipt")
          
          (name "Create Galaxy server directory")
          (file 
            (path (jinja "{{ galaxy_server_dir }}"))
            (state "directory")
            (mode "0755"))
          
          (name "Install current version of Galaxy")
          (unarchive 
            (src (jinja "{{ galaxy_download_url }}"))
            (dest (jinja "{{ galaxy_server_dir }}"))
            (extra_opts "--strip-components=1")
            (remote_src "yes"))
          (when "not download_receipt.stat.exists")
          
          (name "Create Galaxy download receipt")
          (file 
            (path (jinja "{{ galaxy_server_dir }}") "/" (jinja "{{ galaxy_commit_id }}") "_receipt")
            (state "touch")
            (mode "0644"))
          (when "not download_receipt.stat.exists")
          
          (name "Include virtualenv setup tasks")
          (import_tasks "virtualenv.yml")
          
          (name "Remove orphaned .pyc files and compile bytecode")
          (import_tasks "compile.yml")))
      (remote_user (jinja "{{ galaxy_remote_users.privsep | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.privsep is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.privsep | default(__galaxy_become_user) }}")))))
