(playbook "ansible-examples/language_features/netscaler.yml"
    (play
    (hosts "web-pool")
    (serial "3")
    (vars
      (nsc_host "nsc.example.com")
      (nsc_user "admin")
      (nsc_pass "nimda")
      (type "service")
      (name (jinja "{{facter_fqdn}}") ":8080"))
    (tasks
      (task "disable service in the lb"
        (netscaler "nsc_host=" (jinja "{{nsc_host}}") " user=" (jinja "{{nsc_user}}") " password=" (jinja "{{nsc_pass}}") " name=" (jinja "{{name}}") " type=" (jinja "{{type}}") " action=disable"))
      (task "deploy new code"
        (shell "yum upgrade -y"))
      (task "enable in the lb"
        (netscaler "nsc_host=" (jinja "{{nsc_host}}") " user=" (jinja "{{nsc_user}}") " password=" (jinja "{{nsc_pass}}") " name=" (jinja "{{name}}") " type=" (jinja "{{type}}") " action=enable")))))
