(playbook "ansible-examples/phillips_hue/ansible_colors.yml"
    (play
    (hosts "localhost")
    (gather_facts "no")
    (connection "local")
    (vars
      (ansible_mango 
        (on "true")
        (bri "254")
        (xy (list
            "0.5701"
            "0.313")))
      (ansible_pool 
        (on "true")
        (bri "254")
        (xy (list
            "0.1593"
            "0.2522"))))
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
      (task "TURN LIGHTS TO MANGO"
        (uri 
          (url "http://" (jinja "{{ip_address}}") "/api/" (jinja "{{username}}") "/lights/" (jinja "{{item}}") "/state")
          (method "PUT")
          (body (jinja "{{ansible_mango|to_json}}")))
        (loop (jinja "{{ range(1, light_info.json.lights | length + 1)|list }}")))
      (task "TURN LIGHTS TO POOL"
        (uri 
          (url "http://" (jinja "{{ip_address}}") "/api/" (jinja "{{username}}") "/lights/" (jinja "{{item}}") "/state")
          (method "PUT")
          (body (jinja "{{ansible_pool|to_json}}")))
        (loop (jinja "{{ range(1, light_info.json.lights | length + 1)|list }}")))
      (task "TURN LIGHTS TO MANGO"
        (uri 
          (url "http://" (jinja "{{ip_address}}") "/api/" (jinja "{{username}}") "/lights/" (jinja "{{item}}") "/state")
          (method "PUT")
          (body (jinja "{{ansible_mango|to_json}}")))
        (loop (jinja "{{ range(1, light_info.json.lights | length + 1)|list }}")))
      (task "TURN LIGHTS TO POOL"
        (uri 
          (url "http://" (jinja "{{ip_address}}") "/api/" (jinja "{{username}}") "/lights/" (jinja "{{item}}") "/state")
          (method "PUT")
          (body (jinja "{{ansible_pool|to_json}}")))
        (loop (jinja "{{ range(1, light_info.json.lights | length + 1)|list }}"))))))
