(playbook "ansible-for-devops/nodejs-role/playbook.yml"
    (play
    (hosts "all")
    (vars
      (node_apps_location "/usr/local/opt/node"))
    (pre_tasks
      (task "Import Remi GPG key."
        (rpm_key 
          (key "https://rpms.remirepo.net/RPM-GPG-KEY-remi2018")
          (state "present")))
      (task "Install Remi repo."
        (dnf 
          (name "https://rpms.remirepo.net/enterprise/remi-release-8.rpm")
          (state "present")))
      (task "Install EPEL repo."
        (dnf "name=epel-release state=present"))
      (task "Ensure firewalld is stopped (since this is a test server)."
        (service "name=firewalld state=stopped")))
    (roles
      "nodejs")
    (tasks
      (task "Ensure Node.js app folder exists."
        (file "path=" (jinja "{{ node_apps_location }}") " state=directory"))
      (task "Copy example Node.js app to server."
        (copy "src=app dest=" (jinja "{{ node_apps_location }}")))
      (task "Install app dependencies defined in package.json."
        (npm "path=" (jinja "{{ node_apps_location }}") "/app"))
      (task "Check list of running Node.js apps."
        (command "/usr/local/bin/forever list")
        (register "forever_list")
        (changed_when "false"))
      (task "Start example Node.js app."
        (command "/usr/local/bin/forever start " (jinja "{{ node_apps_location }}") "/app/app.js")
        (when "forever_list.stdout.find(node_apps_location + '/app/app.js') == -1")))))
