(playbook "sensu-ansible/tasks/plugins.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml")))
    (task "Ensure Sensu plugin directory exists"
      (file 
        (dest (jinja "{{ sensu_config_path }}") "/plugins")
        (state "directory")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))))
    (task "Ensure local directories exist"
      (file 
        (state "directory")
        (dest (jinja "{{ static_data_store }}") "/sensu/" (jinja "{{ item }}")))
      (delegate_to "localhost")
      (become "no")
      (run_once "true")
      (loop (list
          "checks"
          "filters"
          "handlers"
          "mutators"
          "definitions"
          "client_definitions"
          "client_templates")))
    (task "Ensure any remote plugins defined are present"
      (shell "umask 0022; sensu-install -p " (jinja "{{ item }}"))
      (loop (jinja "{{ sensu_remote_plugins }}"))
      (changed_when "false")
      (when "sensu_remote_plugins | length > 0"))
    (task "Register available checks"
      (command "ls " (jinja "{{ static_data_store }}") "/sensu/checks")
      (delegate_to "localhost")
      (register "sensu_available_checks")
      (changed_when "false")
      (become "false")
      (run_once "true"))
    (task "Deploy check plugins"
      (copy 
        (src (jinja "{{ static_data_store }}") "/sensu/checks/" (jinja "{{ item }}") "/")
        (dest (jinja "{{ sensu_config_path }}") "/plugins/")
        (mode "0755")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (when (list
          "sensu_available_checks is defined"
          "sensu_available_checks is not skipped"
          "item in sensu_available_checks.stdout_lines"))
      (loop (jinja "{{ group_names|flatten }}"))
      (notify "restart sensu-client service"))
    (task "Deploy handler plugins"
      (copy 
        (src (jinja "{{ static_data_store }}") "/sensu/handlers/")
        (dest (jinja "{{ sensu_config_path }}") "/plugins/")
        (mode "0755")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (notify "restart sensu-client service"))
    (task "Deploy filter plugins"
      (copy 
        (src (jinja "{{ static_data_store }}") "/sensu/filters/")
        (dest (jinja "{{ sensu_config_path }}") "/plugins/")
        (mode "0755")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (notify "restart sensu-client service"))
    (task "Deploy mutator plugins"
      (copy 
        (src (jinja "{{ static_data_store }}") "/sensu/mutators/")
        (dest (jinja "{{ sensu_config_path }}") "/plugins/")
        (mode "0755")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (notify "restart sensu-client service"))
    (task "Deploy check/handler/filter/mutator definitions to the master"
      (template 
        (src (jinja "{{ item }}"))
        (dest (jinja "{{ sensu_config_path }}") "/conf.d/" (jinja "{{ item | basename | regex_replace('.j2', '') }}"))
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (when "sensu_master")
      (with_fileglob (list
          (jinja "{{ static_data_store }}") "/sensu/definitions/*"))
      (notify (list
          "restart sensu-server service"
          "restart sensu-api service"
          "restart sensu-enterprise service")))
    (task "Register available client definitions"
      (command "ls " (jinja "{{ static_data_store }}") "/sensu/client_definitions")
      (delegate_to "localhost")
      (register "sensu_available_client_definitions")
      (changed_when "false")
      (become "false")
      (run_once "true"))
    (task "Deploy client definitions"
      (copy 
        (src (jinja "{{ static_data_store }}") "/sensu/client_definitions/" (jinja "{{ item }}") "/")
        (dest (jinja "{{ sensu_config_path }}") "/conf.d/" (jinja "{{ item | basename | regex_replace('.j2', '') }}"))
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (when (list
          "sensu_available_client_definitions is defined"
          "sensu_available_client_definitions is not skipped"
          "item in sensu_available_client_definitions.stdout_lines"))
      (loop (jinja "{{ group_names|flatten }}"))
      (notify "restart sensu-client service"))
    (task "Register available client templates"
      (command "ls " (jinja "{{ static_data_store }}") "/sensu/client_templates")
      (delegate_to "localhost")
      (register "sensu_available_client_templates")
      (changed_when "false")
      (become "false")
      (run_once "true"))
    (task "Deploy client template folders"
      (file 
        (path (jinja "{{ sensu_config_path }}") "/conf.d/" (jinja "{{ item | basename }}"))
        (state "directory")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (when (list
          "sensu_available_client_templates is defined"
          "sensu_available_client_templates is not skipped"
          "item in sensu_available_client_templates.stdout_lines"))
      (loop (jinja "{{ group_names|flatten }}"))
      (notify "restart sensu-client service"))
    (task "Deploy client templates"
      (template 
        (src (jinja "{{ static_data_store }}") "/sensu/client_templates/" (jinja "{{ item.path | dirname }}") "/" (jinja "{{ item.path | basename }}"))
        (dest (jinja "{{ sensu_config_path }}") "/conf.d/" (jinja "{{ item.path | dirname }}") "/" (jinja "{{ item.path | basename | regex_replace('.j2', '') }}"))
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (with_filetree (jinja "{{ static_data_store }}") "/sensu/client_templates")
      (when (list
          "item.state == 'file'"
          "item.path | dirname in group_names"))
      (notify "restart sensu-client service"))))
