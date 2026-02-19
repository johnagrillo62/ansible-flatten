(playbook "ansible-galaxy/tasks/errordocs.yml"
  (tasks
    (task "Manage error documents"
      (block (list
          
          (name "Create error document directories")
          (file 
            (path (jinja "{{ galaxy_errordocs_dest }}") "/" (jinja "{{ item }}"))
            (mode "0755")
            (state "directory"))
          (with_items (list
              "413"
              "502"))
          
          (name "Install error documents static files")
          (copy 
            (src "errordocs/" (jinja "{{ item }}"))
            (dest (jinja "{{ galaxy_errordocs_dest }}") "/" (jinja "{{ item }}"))
            (mode "0644"))
          (with_items (list
              "content_bg.png"
              "error_message_icon.png"
              "masthead_bg.png"))
          
          (name "Install error document templates")
          (template 
            (src "errordocs/" (jinja "{{ item }}") ".j2")
            (dest (jinja "{{ galaxy_errordocs_dest }}") "/" (jinja "{{ item }}"))
            (mode "0644"))
          (with_items (list
              "413/index.html"
              "502/index.shtml"))
          
          (name "Create maintenance message link")
          (file 
            (path (jinja "{{ galaxy_errordocs_dest }}") "/502/maint")
            (src (jinja "{{ galaxy_errordocs_maint_file | default('~/maint') }}"))
            (state "link")
            (force "yes"))))
      (remote_user (jinja "{{ galaxy_remote_users.errdocs | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.errdocs is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.errdocs | default(__galaxy_become_user) }}")))))
