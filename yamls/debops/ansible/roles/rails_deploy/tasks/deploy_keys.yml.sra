(playbook "debops/ansible/roles/rails_deploy/tasks/deploy_keys.yml"
  (tasks
    (task "Slurp the deploy key"
      (ansible.builtin.slurp 
        (src (jinja "{{ rails_deploy_home }}") "/.ssh/id_rsa.pub"))
      (register "rails_deploy_register_deploy_key")
      (when "rails_deploy_service is defined and rails_deploy_service and rails_deploy_register_deploy_key is undefined"))
    (task "Create a json formatted deploy key"
      (ansible.builtin.set_fact 
        (rails_deploy_key_data 
          (title (jinja "{{ rails_deploy_service }}") "@" (jinja "{{ ansible_hostname }}") " deployed by Ansible")
          (key (jinja "{{ rails_deploy_register_deploy_key.content | b64decode | trim }}"))))
      (when "rails_deploy_service is defined and rails_deploy_service and rails_deploy_register_deploy_key is defined"))
    (task "Transfer the deploy key to Github"
      (ansible.builtin.command "curl --silent --header 'Authorization: token " (jinja "{{ rails_deploy_git_access_token }}") "' --data '" (jinja "{{ rails_deploy_key_data | to_nice_json }}") "' https://api.github.com/repos/" (jinja "{{ rails_deploy_git_account }}") "/" (jinja "{{ rails_deploy_git_repo }}") "/keys")
      (changed_when "False")
      (when "rails_deploy_git_access_token and 'file://' not in rails_deploy_git_location and rails_deploy_register_deploy_key is defined and 'github' in rails_deploy_git_host"))
    (task "Get the Gitlab repo id"
      (ansible.builtin.uri 
        (url "https://" (jinja "{{ rails_deploy_git_host }}") "/api/v3/projects/" (jinja "{{
                     rails_deploy_git_account }}") "%2F" (jinja "{{ rails_deploy_git_repo }}"))
        (headers 
          (PRIVATE-TOKEN (jinja "{{ rails_deploy_git_access_token }}"))))
      (register "rails_deploy_register_gitlab_response")
      (when "rails_deploy_git_access_token and 'file://' not in rails_deploy_git_location and rails_deploy_register_deploy_key is defined and not 'github' in rails_deploy_git_host"))
    (task "Transfer the deploy key to Gitlab"
      (ansible.builtin.command "curl --insecure --header 'PRIVATE-TOKEN: " (jinja "{{ rails_deploy_git_access_token }}") "' --data '" (jinja "{{ rails_deploy_key_data | to_nice_json }}") "' https://" (jinja "{{ rails_deploy_git_host }}") "/api/v3/projects/" (jinja "{{
                   rails_deploy_register_gitlab_response.json.id }}") "/keys")
      (changed_when "False")
      (register "rails_deploy_register_gitlab_access_token")
      (when "rails_deploy_git_access_token and 'file://' not in rails_deploy_git_location and rails_deploy_register_deploy_key is defined and not 'github' in rails_deploy_git_host"))))
