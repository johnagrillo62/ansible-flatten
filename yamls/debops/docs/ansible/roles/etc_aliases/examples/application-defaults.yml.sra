(playbook "debops/docs/ansible/roles/etc_aliases/examples/application-defaults.yml"
  (application__etc_aliases__dependent_recipients (list
      
      (name "application")
      (dest (list
          "user1"
          "user2")))))
