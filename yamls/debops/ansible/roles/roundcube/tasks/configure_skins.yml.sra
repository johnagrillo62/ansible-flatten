(playbook "debops/ansible/roles/roundcube/tasks/configure_skins.yml"
  (tasks
    (task "Generate CSS files for the 'elastic' skin"
      (block (list
          
          (name "Set 'elastic' skin CSS files")
          (ansible.builtin.set_fact 
            (roundcube__fact_skin_elastic_css_files (list
                
                (src "styles/styles.less")
                (dest "styles/styles.css")
                
                (src "styles/print.less")
                (dest "styles/print.css")
                
                (src "styles/embed.less")
                (dest "styles/embed.css"))))
          
          (name "Generate CSS files for the 'elastic' skin")
          (ansible.builtin.command "lessc --compress " (jinja "{{ item.src }}") " " (jinja "{{ item.dest }}"))
          (args 
            (chdir (jinja "{{ roundcube__git_dest }}") "/skins/" (jinja "{{ roundcube__skin_folder }}"))
            (creates (jinja "{{ item.dest }}")))
          (loop (jinja "{{ roundcube__fact_skin_elastic_css_files }}"))
          
          (name "Adjust permissions of CSS files")
          (ansible.builtin.file 
            (path (jinja "{{ roundcube__git_dest }}") "/skins/" (jinja "{{ roundcube__skin_folder }}") "/" (jinja "{{ item.dest }}"))
            (owner (jinja "{{ roundcube__user }}"))
            (group (jinja "{{ roundcube__group }}"))
            (mode "0644"))
          (loop (jinja "{{ roundcube__fact_skin_elastic_css_files }}"))))
      (when "roundcube__skin_folder is defined and roundcube__skin_folder == 'elastic' and roundcube__git_dest is defined")
      (tags (list
          "role::roundcube:skin:elastic")))))
