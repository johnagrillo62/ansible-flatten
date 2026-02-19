(playbook "ansible-examples/windows/deploy-site.yml"
    (play
    (name "Download simple web site")
    (hosts "all")
    (gather_facts "false")
    (tasks
      (task "Download simple web site to 'C:\\inetpub\\wwwroot\\ansible.html'"
        (win_get_url 
          (url "https://raw.githubusercontent.com/thisdavejohnson/mywebapp/master/index.html")
          (dest "C:\\inetpub\\wwwroot\\ansible.html"))))))
