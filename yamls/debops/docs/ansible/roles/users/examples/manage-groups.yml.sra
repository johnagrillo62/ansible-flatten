(playbook "debops/docs/ansible/roles/users/examples/manage-groups.yml"
  (users__groups (list
      
      (name "group1")
      (user "False")
      
      (name "group1_sys")
      (system "True")
      (user "False")
      
      (name "group_removed")
      (user "False")
      (state "absent"))))
