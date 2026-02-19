(playbook "ansible-examples/lamp_simple/roles/web/tasks/main.yml"
  (list
    
    (include "install_httpd.yml")
    
    (include "copy_code.yml")))
