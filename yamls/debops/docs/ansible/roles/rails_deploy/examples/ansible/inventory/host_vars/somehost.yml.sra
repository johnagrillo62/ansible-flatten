(playbook "debops/docs/ansible/roles/rails_deploy/examples/ansible/inventory/host_vars/somehost.yml"
  (rails_deploy_git_location "git@github.com:youraccount/yourappname.git")
  (rails_deploy_git_access_token "xxxxxxxxxxx")
  (rails_deploy_user_groups (list
      "sshusers"))
  (rails_deploy_dependencies (list
      "nginx"))
  (rails_deploy_env 
    (S3_ACCESS_KEY_ID "")
    (S3_SECRET_ACCESS_KEY "")
    (S3_REGION "")
    (TOKEN_RAILS_SECRET "xxxxxxx"))
  (rails_deploy_postgresql_cluster "9.3/main"))
