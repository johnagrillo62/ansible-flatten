(playbook "debops/docs/ansible/roles/users/examples/manage-accounts.yml"
  (users__accounts (list
      
      (name "user1")
      
      (name "user2")
      (group "user2")
      (groups (list
          "sshusers"))
      (shell "/bin/zsh")
      (dotfiles_enabled "True")
      (dotfiles_repo "https://git.example.org/user2/dotfiles")
      
      (name "user3")
      (group "users")
      (update_password "on_create")
      (password (jinja "{{ lookup(\"password\", secret + \"/credentials/\" + ansible_fqdn
                  + \"/users/user3/password encrypt=sha512_crypt length=30\") }}"))
      
      (name "user_removed")
      (state "absent")
      
      (name "application")
      (group "application")
      (chroot "True")
      (comment "SFTPonly application account")
      (home "/home/application")
      (home_mode "0750")
      (home_acl (list
          
          (entity "www-data")
          (etype "group")
          (permissions "x")))
      (resources (list
          "files"
          "sites/example.org/public")))))
