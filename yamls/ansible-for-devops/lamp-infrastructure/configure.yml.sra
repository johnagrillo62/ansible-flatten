(playbook "ansible-for-devops/lamp-infrastructure/configure.yml"
  (list
    
    (import_playbook "playbooks/varnish/main.yml")
    
    (import_playbook "playbooks/www/main.yml")
    
    (import_playbook "playbooks/db/main.yml")
    
    (import_playbook "playbooks/memcached/main.yml")))
