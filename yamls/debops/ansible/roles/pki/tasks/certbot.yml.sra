(playbook "debops/ansible/roles/pki/tasks/certbot.yml"
  (tasks
    (task "Make sure that the post-hook directory exists"
      (ansible.builtin.file 
        (path "/etc/letsencrypt/renewal-hooks/post")
        (state "directory")
        (mode "0755")))
    (task "Install deploy-hook scripts"
      (ansible.builtin.copy 
        (src "etc/letsencrypt/renewal-hooks/deploy/")
        (dest "/etc/letsencrypt/renewal-hooks/deploy/")
        (mode "0755")))
    (task "Install post-hook scripts"
      (ansible.builtin.copy 
        (src "etc/letsencrypt/renewal-hooks/post/")
        (dest "/etc/letsencrypt/renewal-hooks/post/")
        (mode "0755")))
    (task "Divert the original certbot configuration file"
      (debops.debops.dpkg_divert 
        (path "/etc/letsencrypt/cli.ini")
        (state "present")))
    (task "Generate certbot configuration file"
      (ansible.builtin.template 
        (src "etc/letsencrypt/cli.ini.j2")
        (dest "/etc/letsencrypt/cli.ini")
        (mode "0644")))))
