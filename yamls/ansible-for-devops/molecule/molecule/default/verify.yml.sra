(playbook "ansible-for-devops/molecule/molecule/default/verify.yml"
    (play
    (name "Verify")
    (hosts "all")
    (tasks
      (task "Verify Apache is serving web requests."
        (ansible.builtin.uri 
          (url "http://localhost/")
          (status_code "200"))))))
