(playbook "ansible-examples/language_features/roletest2.yml"
    (play
    (hosts "all")
    (roles
      
        (role "foo")
        (param1 (jinja "{{ foo }}"))
        (param2 (jinja "{{ some_var1 + \"/\" + some_var2 }}"))
        (when "ansible_os_family == 'RedHat'"))
    (tasks
      (task
        (shell "echo 'this is a loose task'")))))
