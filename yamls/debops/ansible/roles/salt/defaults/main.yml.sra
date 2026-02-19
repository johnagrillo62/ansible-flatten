(playbook "debops/ansible/roles/salt/defaults/main.yml"
  (salt__upstream (jinja "{{ True
                    if (ansible_distribution_release in [\"trusty\"])
                    else False }}"))
  (salt__upstream_branch "latest")
  (salt__upstream_arch_map 
    (x86_64 "amd64")
    (armhf "armhf"))
  (salt__upstream_apt_key_id "754A1A7AE731F165D5E6D4BD0E08A149DE57BFBE")
  (salt__upstream_apt_repo_map 
    (Debian (jinja "{{ \"deb http://repo.saltstack.com/apt/debian/\"
              + ansible_distribution_major_version + \"/\" + salt__upstream_arch_map[ansible_architecture]
              + \"/\" + salt__upstream_branch + \" \" + ansible_distribution_release + \" main\" }}"))
    (Ubuntu (jinja "{{ \"deb http://repo.saltstack.com/apt/ubuntu/\"
              + ansible_distribution_version + \"/\" + salt__upstream_arch_map[ansible_architecture]
              + \"/\" + salt__upstream_branch + \" \" + ansible_distribution_release + \" main\" }}")))
  (salt__base_packages (list
      "salt-master"))
  (salt__packages (list))
  (salt__allow (list))
  (salt__configuration "True")
  (salt__configuration_file "/etc/salt/master.d/ansible.conf")
  (salt__interface (jinja "{{ \"::\" if salt__ipv6 | bool else \"0.0.0.0\" }}"))
  (salt__ipv6 "True")
  (salt__publish_port "4505")
  (salt__return_port "4506")
  (salt__worker_threads (jinja "{{ ansible_processor_vcpus }}"))
  (salt__custom_options "")
  (salt__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ salt__upstream_apt_key_id }}"))
      (repo (jinja "{{ salt__upstream_apt_repo_map[ansible_distribution] }}"))
      (state (jinja "{{ \"present\" if salt__upstream | bool else \"absent\" }}"))))
  (salt__python__dependent_packages3 (list
      "python3-tornado"))
  (salt__python__dependent_packages2 (list
      "python-tornado"))
  (salt__etc_services__dependent_list (list
      
      (name "salt-publish")
      (port (jinja "{{ salt__publish_port }}"))
      (comment "Salt Master (publish)")
      
      (name "salt-return")
      (port (jinja "{{ salt__return_port }}"))
      (comment "Salt Master (return)")))
  (salt__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "salt-publish"
          "salt-return"))
      (saddr (jinja "{{ salt__allow }}"))
      (accept_any "True")
      (name "salt_accept"))))
