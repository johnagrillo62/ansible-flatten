(playbook "debops/docs/ansible/roles/rails_deploy/examples/ansible/playbook/yourappname.yml"
    (play
    (name "Support yourappname")
    (hosts "debops_rails_yourappname")
    (become "true")
    (roles
      
        (role "rails_deploy")
        (tags "yourappname"))))
