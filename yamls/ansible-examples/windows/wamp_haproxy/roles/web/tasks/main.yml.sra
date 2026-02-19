(playbook "ansible-examples/windows/wamp_haproxy/roles/web/tasks/main.yml"
  (tasks
    (task "Download simple web site to 'C:\\inetpub\\wwwroot\\ansible.html'"
      (win_get_url 
        (url "https://raw.githubusercontent.com/thisdavejohnson/mywebapp/master/index.html")
        (dest "C:\\inetpub\\wwwroot\\ansible.html")))))
