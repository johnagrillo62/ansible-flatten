(playbook "sensu-ansible/tasks/Amazon/main.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "setup"))
    (task "Set epel_version override when AmazonLinux AMIv2"
      (set_fact 
        (epel_version "7"))
      (tags "setup")
      (when "ansible_distribution_version == 'Candidate'"))
    (task "Ensure the Sensu Core Yum repo is present"
      (yum_repository 
        (name "sensu")
        (description "The Sensu Core yum repository")
        (baseurl (jinja "{{ sensu_yum_repo_url }}"))
        (gpgkey (jinja "{{ sensu_yum_key_url }}"))
        (gpgcheck "yes")
        (enabled "yes"))
      (tags "setup"))
    (task "Ensure Sensu is installed"
      (yum 
        (name (jinja "{{ sensu_package }}"))
        (state (jinja "{{ sensu_pkg_state }}")))
      (tags "setup"))))
