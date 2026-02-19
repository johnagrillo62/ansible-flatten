(playbook "sensu-ansible/tasks/CentOS/main.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "setup"))
    (task "Ensure the Sensu Core Yum repo is present"
      (yum_repository 
        (name "sensu")
        (description "The Sensu Core yum repository")
        (baseurl (jinja "{{ sensu_yum_repo_url }}"))
        (gpgkey (jinja "{{ sensu_yum_key_url }}"))
        (gpgcheck (jinja "{{ (
      (ansible_distribution == 'CentOS' or ansible_distribution == 'Red Hat Enterprise Linux') and
      ansible_distribution_major_version == '5'
      ) | ternary('no', 'yes') }}"))
        (enabled "yes"))
      (tags "setup"))
    (task "Ensure the epel present for OracleLinux"
      (yum_repository 
        (name "epel")
        (description "EPEL YUM repo")
        (baseurl (jinja "{{ sensu_ol_yum_repo_url }}"))
        (gpgkey (jinja "{{ sensu_ol_yum_key_url }}"))
        (enabled "yes"))
      (tags "setup")
      (when "ansible_distribution == 'OracleLinux'"))
    (task "Ensure that credential is supplied if installing Sensu Enterprise"
      (assert 
        (that (list
            "se_user"
            "se_pass"))
        (msg "Sensu enterprise credential must not be empty. Did you forget to set se_user and se_pass?"))
      (tags "setup")
      (when "se_enterprise"))
    (task "Ensure the Sensu Enterprise repo is present"
      (copy 
        (dest "/etc/yum.repos.d/sensu-enterprise.repo")
        (content "[sensu-enterprise]
name=sensu-enterprise
baseurl=http://" (jinja "{{ se_user }}") ":" (jinja "{{ se_pass }}") "@enterprise.sensuapp.com/yum/noarch/
gpgcheck=0
enabled=1
")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags "setup")
      (when "se_enterprise"))
    (task "Ensure the Sensu Enterprise Dashboard repo is present"
      (copy 
        (dest "/etc/yum.repos.d/sensu-enterprise-dashboard.repo")
        (content "[sensu-enterprise-dashboard]
name=sensu-enterprise-dashboard
baseurl=http://" (jinja "{{ se_user }}") ":" (jinja "{{ se_pass }}") "@enterprise.sensuapp.com/yum/\\$basearch/
gpgcheck=0
enabled=1
")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags "setup")
      (when "se_enterprise"))
    (task "Ensure Sensu is installed"
      (package 
        (name (jinja "{{ sensu_package }}"))
        (state (jinja "{{ sensu_pkg_state }}")))
      (tags "setup"))
    (task "Ensure Sensu Enterprise is installed"
      (package 
        (name (jinja "{{ sensu_enterprise_package }}"))
        (state (jinja "{{ sensu_pkg_state }}")))
      (tags "setup")
      (when "se_enterprise"))))
