(playbook "debops/docs/ansible/roles/users/examples/manage-resources.yml"
  (users__accounts (list
      
      (name "user1")
      (group "user1")
      (resources (list
          "Documents"
          
          (dest "tmp")
          (state "link")
          (src "/tmp")
          (owner "root")
          (group "root")
          
          (path ".ssh/github_id_rsa")
          (src "~/.ssh/github_id_rsa")
          (state "file")
          (mode "0600")
          (parent_mode "0700")
          
          (path ".ssh/github_id_rsa.pub")
          (src "~/.ssh/github_id_rsa.pub")
          (state "file")
          (mode "0644")
          (parent_mode "0700")
          
          (path ".ssh/config")
          (state "file")
          (mode "0640")
          (parent_mode "0700")
          (content "Host github.com
    User git
    IdentityFile ~/.ssh/github_id_rsa")
          
          (path "removed")
          (state "absent"))))))
