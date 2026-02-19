(playbook "kubespray/contrib/offline/generate_list.yml"
    (play
    (name "Collect container images for offline deployment")
    (hosts "localhost")
    (become "false")
    (roles
      
        (role "kubespray_defaults")
        (when "false")
      
        (role "download")
        (when "false"))
    (tasks
      (task "Collect container images for offline deployment"
        (template 
          (src "./contrib/offline/temp/" (jinja "{{ item }}") ".list.template")
          (dest "./contrib/offline/temp/" (jinja "{{ item }}") ".list")
          (mode "0644"))
        (with_items (list
            "files"
            "images"))))))
