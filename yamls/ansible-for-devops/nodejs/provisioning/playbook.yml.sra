(playbook "ansible-for-devops/nodejs/provisioning/playbook.yml"
    (play
    (hosts "all")
    (become "yes")
    (vars
      (node_apps_location "/usr/local/opt/node"))
    (tasks
      (task "Install EPEL repo."
        (dnf "name=epel-release state=present"))
      (task "Import Remi GPG key."
        (rpm_key 
          (key "https://rpms.remirepo.net/RPM-GPG-KEY-remi2018")
          (state "present")))
      (task "Install Remi repo."
        (dnf 
          (name "https://rpms.remirepo.net/enterprise/remi-release-8.rpm")
          (state "present")))
      (task "Ensure firewalld is stopped (since this is a test server)."
        (service "name=firewalld state=stopped"))
      (task "Install Node.js and npm."
        (dnf "name=npm state=present enablerepo=epel"))
      (task "Install Forever (to run our Node.js app)."
        (npm "name=forever global=yes state=present"))
      (task "Ensure Node.js app folder exists."
        (file "path=" (jinja "{{ node_apps_location }}") " state=directory"))
      (task "Copy example Node.js app to server."
        (copy "src=app dest=" (jinja "{{ node_apps_location }}")))
      (task "Install app dependencies defined in package.json."
        (npm "path=" (jinja "{{ node_apps_location }}") "/app"))
      (task "Check list of running Node.js apps."
        (command "npx forever list")
        (register "forever_list")
        (changed_when "false"))
      (task "Start example Node.js app."
        (command "npx forever start " (jinja "{{ node_apps_location }}") "/app/app.js")
        (when "forever_list.stdout.find(node_apps_location + '/app/app.js') == -1")))))
