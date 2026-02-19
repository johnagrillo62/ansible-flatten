(playbook "ansible-for-devops/tests/test-plugin.yml"
  (list
    
    (import_playbook "../test-plugin/main.yml")))
