(playbook "ansible-for-devops/tests/solr.yml"
  (list
    
    (hosts "all")
    (tasks (list
        
        (name "Ensure 'man' directory exists.")
        (file 
          (path "/usr/share/man/man1")
          (state "directory")
          (recurse "True"))))
    
    (import_playbook "../solr/provisioning/playbook.yml")))
