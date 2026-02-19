(playbook "ansible-examples/lamp_simple_rhel7/roles/web/tasks/main.yml"
  (list
    
    (include "install_httpd.yml")
    
    (include "copy_code.yml")))
