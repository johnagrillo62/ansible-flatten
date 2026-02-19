(playbook "ansible-examples/language_features/get_url.yml"
    (play
    (hosts "webservers")
    (vars (list
        
        (jquery_directory "/var/www/html/javascript")
        
        (person "Susie%20Smith")))
    (tasks
      (task "Create directory for jQuery"
        (file "dest=" (jinja "{{jquery_directory}}") " state=directory mode=0755"))
      (task "Grab a bunch of jQuery stuff"
        (get_url "url=http://code.jquery.com/" (jinja "{{item}}") "  dest=" (jinja "{{jquery_directory}}") " mode=0444")
        (with_items (list
            "jquery.min.js"
            "mobile/latest/jquery.mobile.min.js"
            "ui/jquery-ui-git.css"))))))
