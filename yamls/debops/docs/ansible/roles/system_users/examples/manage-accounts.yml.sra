(playbook "debops/docs/ansible/roles/system_users/examples/manage-accounts.yml"
  (system_users__accounts (list
      
      (name "user1")
      (group "user1")
      
      (name "user2")
      (group "user2")
      (admin "True")
      (shell "/bin/zsh")
      (dotfiles_enabled "True")
      (dotfiles_repo "https://git.example.org/user2/dotfiles")
      
      (name "user3")
      (group "users")
      (update_password "on_create")
      (password (jinja "{{ lookup(\"password\", secret + \"/credentials/\" + ansible_fqdn
                  + \"/users/user3/password encrypt=sha512_crypt length=30\") }}"))
      
      (name "user_removed")
      (state "absent"))))
