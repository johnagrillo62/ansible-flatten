(playbook "openshift-ansible/hack/libvirt/playbooks/localrepo.yml"
    (play
    (hosts "nodes")
    (tasks
      (task
        (command (jinja "{{ ansible_pkg_mgr }}") " install buildah -y"))
      (task "Transfer the buildah script"
        (template 
          (src "buildah_repo.sh")
          (dest "/root")))
      (task "Execute buildah script"
        (command "sh /root/buildah_repo.sh"))
      (task "Create local repo file"
        (copy 
          (src "openshift-local.repo")
          (dest "/etc/yum.repos.d/openshift-local.repo"))))))
