(playbook "ansible-examples/language_features/conditionals_part2.yml"
    (play
    (hosts "all")
    (remote_user "root")
    (vars
      (favcolor "red")
      (dog "fido")
      (cat "whiskers")
      (ssn "8675309"))
    (tasks
      (task "do this if my favcolor is blue, and my dog is named fido"
        (shell "/bin/false")
        (when "favcolor == 'blue' and dog == 'fido'"))
      (task "do this if my favcolor is not blue, and my dog is named fido"
        (shell "/bin/true")
        (when "favcolor != 'blue' and dog == 'fido'"))
      (task "do this if my SSN is over 9000"
        (shell "/bin/true")
        (when "ssn > 9000"))
      (task "do this if I have one of these SSNs"
        (shell "/bin/true")
        (when "ssn in [ 8675309, 8675310, 8675311 ]"))
      (task "do this if a variable named hippo is NOT defined"
        (shell "/bin/true")
        (when "hippo is not defined"))
      (task "do this if a variable named hippo is defined"
        (shell "/bin/true")
        (when "hippo is defined")))))
