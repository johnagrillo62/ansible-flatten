(playbook "debops/ansible/roles/ansible/defaults/main.yml"
  (ansible__deploy_type (jinja "{{ \"upstream\"
                          if (ansible_distribution_release in
                              [\"trusty\", \"xenial\"])
                          else \"system\" }}"))
  (ansible__upstream_apt_key "6125 E2A8 C77F 2818 FB7B D15B 93C4 A3FD 7BB9 C367")
  (ansible__upstream_apt_repository "deb http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main")
  (ansible__base_packages (list
      (jinja "{{ \"ansible\"
        if (ansible__deploy_type in [\"system\", \"upstream\"])
        else [] }}")))
  (ansible__packages (list))
  (ansible__bootstrap_version "devel")
  (ansible__apt_preferences__dependent_list (list
      
      (package "ansible")
      (backports (list
          "stretch"
          "buster"))
      (reason "Compatibility with upstream release")
      (by_role "debops_ansible")
      (state (jinja "{{ \"absent\"
               if (ansible__deploy_type == \"upstream\")
               else \"present\" }}"))
      
      (package "ansible")
      (pin "release o=LP-PPA-ansible-ansible")
      (priority "600")
      (by_role "debops_ansible")
      (filename "debops_ansible_upstream.pref")
      (reason "Recent version from upstream PPA")
      (state (jinja "{{ \"present\"
               if (ansible__deploy_type == \"upstream\")
               else \"absent\" }}"))))
  (ansible__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ ansible__upstream_apt_key }}"))
      (repo (jinja "{{ ansible__upstream_apt_repository }}"))
      (state (jinja "{{ \"present\" if (ansible__deploy_type == \"upstream\") else \"absent\" }}")))))
