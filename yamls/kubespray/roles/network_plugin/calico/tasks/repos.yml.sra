(playbook "kubespray/roles/network_plugin/calico/tasks/repos.yml"
  (tasks
    (task "Calico | Add wireguard yum repo"
      (block (list
          
          (name "Calico | Add wireguard yum repo")
          (yum_repository 
            (name "copr:copr.fedorainfracloud.org:jdoss:wireguard")
            (file "_copr:copr.fedorainfracloud.org:jdoss:wireguard")
            (description "Copr repo for wireguard owned by jdoss")
            (baseurl (jinja "{{ calico_wireguard_repo }}"))
            (gpgcheck "true")
            (gpgkey "https://download.copr.fedorainfracloud.org/results/jdoss/wireguard/pubkey.gpg")
            (skip_if_unavailable "true")
            (enabled "true")
            (repo_gpgcheck "false"))
          (when (list
              "ansible_os_family in ['RedHat']"
              "ansible_distribution not in ['Fedora']"
              "ansible_facts['distribution_major_version'] | int < 9"))))
      (when (list
          "calico_wireguard_enabled")))))
