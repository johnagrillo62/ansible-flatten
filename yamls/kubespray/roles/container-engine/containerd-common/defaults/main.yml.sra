(playbook "kubespray/roles/container-engine/containerd-common/defaults/main.yml"
  (containerd_package "containerd.io")
  (yum_repo_dir "/etc/yum.repos.d"))
