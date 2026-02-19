(playbook "debops/docs/ansible/roles/elasticsearch/examples/application-defaults.yml"
  (application__deploy_state "present")
  (application__elasticsearch__dependent_configuration (list
      
      (name "application.option")
      (value "True")
      
      (application.other.option "False"))))
