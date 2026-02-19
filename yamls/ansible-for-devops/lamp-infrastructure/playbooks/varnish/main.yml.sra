(playbook "ansible-for-devops/lamp-infrastructure/playbooks/varnish/main.yml"
    (play
    (hosts "lamp_varnish")
    (become "yes")
    (vars_files (list
        "vars.yml"))
    (roles
      "geerlingguy.firewall"
      "geerlingguy.repo-epel"
      "geerlingguy.varnish")
    (tasks
      (task "Copy Varnish default.vcl."
        (template 
          (src "templates/default.vcl.j2")
          (dest "/etc/varnish/default.vcl"))
        (notify "restart varnish")))))
