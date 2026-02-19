(playbook "awx_collection/tools/template_galaxy.yml"
    (play
    (name "Template the collection galaxy.yml")
    (hosts "localhost")
    (gather_facts "false")
    (connection "local")
    (vars
      (collection_package "awx")
      (collection_namespace "awx")
      (collection_version "0.0.1")
      (collection_source (jinja "{{ playbook_dir }}") "/../")
      (collection_path (jinja "{{ playbook_dir }}") "/../../awx_collection_build"))
    (pre_tasks
      (task
        (file 
          (path (jinja "{{ collection_path }}"))
          (state "absent")))
      (task
        (copy 
          (src (jinja "{{ collection_source }}"))
          (dest (jinja "{{ collection_path }}"))
          (remote_src "true"))))
    (roles
      "template_galaxy")
    (tasks
      (task "Make substitutions in source to sync with templates"
        (set_fact 
          (collection_version_override "0.0.1-devel")))
      (task "Template the galaxy.yml source file (should be commited with your changes)"
        (template 
          (src (jinja "{{ collection_source }}") "/tools/roles/template_galaxy/templates/galaxy.yml.j2")
          (dest (jinja "{{ collection_source }}") "/galaxy.yml")
          (force "true")))
      (task "Template the README.md source file (should be commited with your changes)"
        (template 
          (src (jinja "{{ collection_source }}") "/tools/roles/template_galaxy/templates/README.md.j2")
          (dest (jinja "{{ collection_source }}") "/README.md")
          (force "true"))))))
