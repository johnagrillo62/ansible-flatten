(playbook "debops/docs/ansible/roles/kibana/examples/application-defaults.yml"
  (application__deploy_state "present")
  (application__kibana__dependent_configuration (list
      
      (name "application.option")
      (value "True")
      
      (application.other.option "False"))))
