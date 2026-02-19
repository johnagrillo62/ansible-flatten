(playbook "ansible-for-devops/docker-hubot/roles/hubot-slack/tasks/main.yml"
  (tasks
    (task "Install dependencies."
      (package 
        (name "sudo")
        (state "present")))
    (task "Install required Node.js packages."
      (npm 
        (name (jinja "{{ item }}"))
        (state "present")
        (global "yes"))
      (with_items (list
          "yo"
          "generator-hubot")))
    (task "Ensure hubot user exists."
      (user 
        (name "hubot")
        (create_home "yes")
        (home (jinja "{{ hubot_home }}"))))
    (task "Generate hubot."
      (command "yo hubot --owner=\"" (jinja "{{ hubot_owner }}") "\" --name=\"" (jinja "{{ hubot_name }}") "\" --description=\"" (jinja "{{ hubot_description }}") "\" --adapter=slack --defaults chdir=" (jinja "{{ hubot_home }}") "
")
      (become "yes")
      (become_user "hubot"))
    (task "Remove certain scripts from external-scripts.json."
      (lineinfile 
        (path (jinja "{{ hubot_home }}") "/external-scripts.json")
        (regexp (jinja "{{ item }}"))
        (state "absent"))
      (with_items (list
          "redis-brain"
          "heroku"))
      (become "yes")
      (become_user "hubot"))
    (task "Remove the hubot-scripts.json file."
      (file 
        (path (jinja "{{ hubot_home }}") "/hubot-scripts.json")
        (state "absent")))))
