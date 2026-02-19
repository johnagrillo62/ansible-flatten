(playbook "ansible-for-devops/deployments-rolling/playbooks/deploy.yml"
    (play
    (hosts "nodejs-api")
    (gather_facts "no")
    (become "yes")
    (vars_files (list
        "vars.yml"))
    (tasks
      (task "Ensure Node.js API app is present."
        (git 
          (repo (jinja "{{ app_repository }}"))
          (version (jinja "{{ app_version }}"))
          (dest (jinja "{{ app_directory }}"))
          (accept_hostkey "true"))
        (register "app_updated")
        (notify "restart forever apps"))
      (task "Stop all running instances of the app."
        (command "forever stopall")
        (when "app_updated.changed"))
      (task "Ensure Node.js API app dependencies are present."
        (npm "path=" (jinja "{{ app_directory }}"))
        (when "app_updated.changed"))
      (task "Run Node.js API app tests."
        (command "npm test chdir=" (jinja "{{ app_directory }}"))
        (when "app_updated.changed"))
      (task "Get list of all running Node.js apps."
        (command "forever list")
        (register "forever_list")
        (changed_when "false"))
      (task "Ensure Node.js API app is started."
        (command "forever start " (jinja "{{ app_directory }}") "/app.js")
        (when "forever_list.stdout.find('app.js') == -1"))
      (task "Add cron entry to start Node.js API app on reboot."
        (cron 
          (name "Start Node.js API app")
          (special_time "reboot")
          (job "forever start " (jinja "{{ app_directory }}") "/app.js"))))
    (handlers
      (task "restart forever apps"
        (command "forever restartall")))))
