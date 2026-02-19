(playbook "debops/ansible/roles/sks/tasks/sks_frontend.yml"
  (tasks
    (task "Ensure that webpage directory exists"
      (ansible.builtin.file 
        (path "/srv/www/sites/" (jinja "{{ sks_domain[0] }}") "/public")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Check if index.html page exists"
      (ansible.builtin.stat 
        (path "/srv/www/sites/" (jinja "{{ sks_domain[0] }}") "/public/index.html"))
      (register "sks_register_index_html"))
    (task "Configure SKS Keyserver webpage if not present"
      (ansible.builtin.copy 
        (src "srv/www/sites/default/public/" (jinja "{{ item }}"))
        (dest "/srv/www/sites/" (jinja "{{ sks_domain[0] }}") "/public/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "index.html"
          "robots.txt"))
      (when "sks_register_index_html is defined and not sks_register_index_html.stat.exists"))))
