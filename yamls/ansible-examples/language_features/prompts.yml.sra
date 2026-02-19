(playbook "ansible-examples/language_features/prompts.yml"
    (play
    (hosts "all")
    (remote_user "root")
    (vars
      (this_is_a_regular_var "moo")
      (so_is_this "quack"))
    (vars_prompt (list
        
        (name "some_password")
        (prompt "Enter password")
        (private "yes")
        
        (name "release_version")
        (prompt "Product release version")
        (default "my_default_version")
        (private "no")
        
        (name "my_password2")
        (prompt "Enter password2")
        (private "yes")
        (encrypt "md5_crypt")
        (confirm "yes")
        (salt_size "7")
        (salt "foo")))
    (tasks
      (task "imagine this did something interesting with " (jinja "{{release_version}}")
        (shell "echo foo >> /tmp/" (jinja "{{release_version}}") "-alpha"))
      (task "look we crypted a password"
        (shell "echo my password is " (jinja "{{my_password2}}"))))))
