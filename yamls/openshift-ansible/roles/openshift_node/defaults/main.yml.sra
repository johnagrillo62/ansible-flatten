(playbook "openshift-ansible/roles/openshift_node/defaults/main.yml"
  (openshift_node_active_nodes (list))
  (openshift_node_machineconfigpool "worker")
  (openshift_node_tls_verify "false")
  (openshift_node_kubeconfig_path (jinja "{{ openshift_kubeconfig_path | default('~/.kube/config') | expanduser | realpath }}"))
  (openshift_node_kubeconfig (jinja "{{ lookup('file', openshift_node_kubeconfig_path) | from_yaml }}"))
  (openshift_node_bootstrap_port "22623")
  (openshift_node_bootstrap_server (jinja "{{ openshift_node_kubeconfig.clusters.0.cluster.server.split(':')[0:-1] | join(':') | regex_replace('://api-int|://api', '://api-int') }}") ":" (jinja "{{ openshift_node_bootstrap_port }}"))
  (openshift_node_bootstrap_endpoint (jinja "{{ openshift_node_bootstrap_server }}") "/config/" (jinja "{{ openshift_node_machineconfigpool }}"))
  (openshift_package_directory "/tmp/openshift-ansible-packages")
  (openshift_packages (jinja "{{ (openshift_node_packages + openshift_node_support_packages) | join(',') }}"))
  (openshift_node_packages (list
      "afterburn"
      "conmon"
      "cri-o-" (jinja "{{ crio_latest }}")
      "cri-tools"
      "crun"
      "openshift-clients-" (jinja "{{ l_cluster_version }}") "*"
      "openshift-kubelet-" (jinja "{{ l_cluster_version }}") "*"
      "podman"
      "netavark"
      "runc"
      "ose-aws-ecr-image-credential-provider"
      "ose-azure-acr-image-credential-provider"
      "ose-gcp-gcr-image-credential-provider"))
  (openshift_node_support_packages (jinja "{{
  openshift_node_support_packages_base +
  openshift_node_support_packages_by_os_major_version[ansible_distribution_major_version] +
  openshift_node_support_packages_by_arch[ansible_architecture] }}"))
  (openshift_node_support_packages_base (list
      "kernel"
      "systemd"
      "selinux-policy-targeted"
      "setools-console"
      "dracut-network"
      "passwd"
      "openssh-server"
      "openssh-clients"
      "skopeo"
      "containernetworking-plugins"
      "nfs-utils"
      "NetworkManager"
      "NetworkManager-ovs"
      "NetworkManager-libreswan"
      "libreswan"
      "dnsmasq"
      "lvm2"
      "iscsi-initiator-utils"
      "sg3_utils"
      "device-mapper-multipath"
      "xfsprogs"
      "e2fsprogs"
      "mdadm"
      "cryptsetup"
      "chrony"
      "logrotate"
      "sssd"
      "shadow-utils"
      "sudo"
      "coreutils"
      "less"
      "tar"
      "xz"
      "gzip"
      "bzip2"
      "rsync"
      "tmux"
      "nmap-ncat"
      "net-tools"
      "bind-utils"
      "strace"
      "bash-completion"
      "vim-minimal"
      "nano"
      "authconfig"
      "iptables-services"
      "cifs-utils"
      "jq"
      "libseccomp"))
  (openshift_node_support_packages_by_os_major_version 
    (7 (list
        "openvswitch2.13"
        "policycoreutils-python"
        "bridge-utils"
        "container-storage-setup"
        "ceph-common"))
    (8 (list
        "openvswitch3.1"
        "policycoreutils-python-utils"))
    (9 (list
        "openvswitch3.1"
        "policycoreutils-python-utils")))
  (openshift_node_support_packages_by_arch 
    (ppc64le (list
        "irqbalance"))
    (s390x (list
        "s390utils-base"))
    (x86_64 (list
        "microcode_ctl"
        "irqbalance"
        "biosdevname"
        "glusterfs-fuse"))
    (aarch64 (list
        "irqbalance"))))
