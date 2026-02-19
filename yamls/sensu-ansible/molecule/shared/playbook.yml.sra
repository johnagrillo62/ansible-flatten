(playbook "sensu-ansible/molecule/shared/playbook.yml"
    (play
    (name "Converge")
    (hosts "all")
    (pre_tasks
      (task "All ansible hostname to sensu_masters group"
        (add_host 
          (name (jinja "{{ item }}"))
          (groups "sensu_masters"))
        (loop (jinja "{{ ansible_play_hosts }}"))
        (changed_when "false"))
      (task "Ensure container hostnames are correct"
        (hostname 
          (name (jinja "{{ inventory_hostname }}")))
        (when "inventory_hostname != 'amazonlinux-1'"))
      (task
        (block (list
            
            (name "Install apt packages for SNI fix")
            (package 
              (name (list
                  "python-pip"
                  "python-dev"
                  "python-urllib3"
                  "python-openssl"
                  "python-pyasn1")))
            
            (name "Install Python packages for SNI fix")
            (pip 
              (name (list
                  "ndg-httpsclient")))))
        (when (list
            "ansible_distribution == 'Ubuntu'"
            "ansible_python_version is version_compare('2.7.9', '<')"))))
    (roles
      
        (role "sensu-ansible"))))
