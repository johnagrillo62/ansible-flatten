(playbook "ansible-examples/phillips_hue/register.yml"
    (play
    (hosts "localhost")
    (gather_facts "no")
    (connection "local")
    (tasks
      (task "PROMPT USER TO PRESS PHYSICAL BUTTON HUE HUB"
        (pause 
          (prompt "Press the button on the hub now...")))
      (task "INCLUDE IP ADDRESS FROM username_info.yml"
        (include_vars 
          (file "username_info.yml")))
      (task "GRAB UNIQUE USERNAME"
        (uri 
          (url "http://" (jinja "{{ip_address}}") "/api")
          (method "POST")
          (body (jinja "{{body_info|to_json}}")))
        (register "username_info"))
      (task "PRINT DATA TO TERMINAL WINDOW"
        (debug 
          (var "username_info.json")))
      (task
        (lineinfile 
          (path "./username_info.yml")
          (regexp "^username")
          (insertafter "EOF")
          (line "username: " (jinja "{{username_info.json[0][\"success\"][\"username\"]}}")))))))
