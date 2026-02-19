(playbook "ansible-for-devops/tests/security.yml"
  (list
    
    (hosts "all")
    (vars 
      (ansible_python_interpreter "python3"))
    (tasks (list
        
        (name "Install test dependencies.")
        (dnf 
          (name (list
              "python3-libselinux"
              "python3-policycoreutils"
              "selinux-policy"
              "selinux-policy-targeted"
              "openssh-server"
              "firewalld"))
          (state "present"))
        
        (name "Ensure sshd is started.")
        (service 
          (name "sshd")
          (state "started"))
        
        (name "Ensure /var/log/messages exists.")
        (copy 
          (content "")
          (dest "/var/log/messages")
          (force "no")
          (mode "0600"))))
    
    (import_playbook "../security/main.yml")
    (vars 
      (ansible_python_interpreter "python3"))))
