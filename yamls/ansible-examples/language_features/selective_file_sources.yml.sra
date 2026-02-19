(playbook "ansible-examples/language_features/selective_file_sources.yml"
    (play
    (hosts "all")
    (tasks
      (task "template a config file"
        (template "dest=/etc/imaginary_file.conf")
        (first_available_file (list
            "/srv/whatever/" (jinja "{{ansible_hostname}}") ".conf"
            "/srv/whatever/" (jinja "{{ansible_distribution}}") (jinja "{{ansible_distribution_version}}") ".conf"
            "/srv/whatever/" (jinja "{{ansible_distribution}}") ".conf"
            "/srv/whatever/default"))))))
