(playbook "ansible-examples/phillips_hue/on_off.yml"
    (play
    (hosts "localhost")
    (gather_facts "no")
    (connection "local")
    (vars
      (off_state 
        (on "false"))
      (on_state 
        (on "true")))
    (tasks
      (task "INCLUDE UNIQUE USERNAME FROM REGISTER.YML"
        (include_vars 
          (file "username_info.yml")))
      (task "GRAB HUE LIGHT INFORMATION"
        (uri 
          (url "http://" (jinja "{{ip_address}}") "/api/" (jinja "{{username}}"))
          (method "GET")
          (body (jinja "{{body_info|to_json}}")))
        (register "light_info"))
      (task "PRINT DATA TO TERMINAL WINDOW"
        (debug 
          (var "light_info.json.lights")))
      (task "PRINT AMOUNT OF LIGHTS TO TERMINAL WINDOW"
        (debug 
          (msg "THERE ARE " (jinja "{{light_info.json.lights | length}}") " HUE LIGHTS PRESENT")))
      (task "TURN LIGHTS OFF"
        (uri 
          (url "http://" (jinja "{{ip_address}}") "/api/" (jinja "{{username}}") "/lights/" (jinja "{{item}}") "/state")
          (method "PUT")
          (body (jinja "{{off_state|to_json}}")))
        (loop (jinja "{{ range(1, light_info.json.lights | length + 1)|list }}")))
      (task "PROMPT USER TO TURN BACK ON"
        (pause 
          (prompt "Turn them back on?")))
      (task "TURN LIGHTS ON"
        (uri 
          (url "http://" (jinja "{{ip_address}}") "/api/" (jinja "{{username}}") "/lights/" (jinja "{{item}}") "/state")
          (method "PUT")
          (body (jinja "{{on_state|to_json}}")))
        (loop (jinja "{{ range(1, light_info.json.lights | length + 1)|list }}"))))))
