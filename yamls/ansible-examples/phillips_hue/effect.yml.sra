(playbook "ansible-examples/phillips_hue/effect.yml"
    (play
    (hosts "localhost")
    (gather_facts "no")
    (connection "local")
    (vars
      (ansible_effect 
        (on "true")
        (effect "colorloop"))
      (ansible_none 
        (on "true")
        (effect "none")))
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
      (task "TURN LIGHTS INTO COLORLOOP EFFECT"
        (uri 
          (url "http://" (jinja "{{ip_address}}") "/api/" (jinja "{{username}}") "/lights/" (jinja "{{item}}") "/state")
          (method "PUT")
          (body (jinja "{{ansible_effect|to_json}}")))
        (loop (jinja "{{ range(1, light_info.json.lights | length + 1)|list }}")))
      
      (pause 
        (seconds "5"))
      (task "TURN LIGHTS INTO COLORLOOP EFFECT"
        (uri 
          (url "http://" (jinja "{{ip_address}}") "/api/" (jinja "{{username}}") "/lights/" (jinja "{{item}}") "/state")
          (method "PUT")
          (body (jinja "{{ansible_none|to_json}}")))
        (loop (jinja "{{ range(1, light_info.json.lights | length + 1)|list }}"))))))
