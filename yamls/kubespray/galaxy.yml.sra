(playbook "kubespray/galaxy.yml"
  (namespace "kubernetes_sigs")
  (description "Deploy a production ready Kubernetes cluster")
  (name "kubespray")
  (version "2.31.0")
  (readme "README.md")
  (authors (list
      "The Kubespray maintainers (https://kubernetes.slack.com/channels/kubespray)"))
  (tags (list
      "infrastructure"))
  (repository "https://github.com/kubernetes-sigs/kubespray")
  (issues "https://github.com/kubernetes-sigs/kubespray/issues")
  (documentation "https://kubespray.io")
  (license_file "LICENSE")
  (dependencies 
    (ansible.utils ">=2.5.0")
    (community.crypto ">=2.22.3")
    (community.general ">=7.0.0")
    (ansible.netcommon ">=5.3.0")
    (ansible.posix ">=1.5.4")
    (community.docker ">=3.11.0")
    (kubernetes.core ">=2.4.2"))
  (manifest 
    (directives (list
        "recursive-exclude tests **"
        "recursive-include roles **/files/*"))))
