═══════════════════════════════════════════════════════════
  VARS AUDIT: .
═══════════════════════════════════════════════════════════

⚠ COLLISIONS (126 variables defined with different values):

  __bash_path:
      [role default] yamls/sensu-ansible/defaults/main.yml: /bin/bash
    → [role vars] yamls/sensu-ansible/vars/FreeBSD.yml: /usr/local/bin/bash  ← WINS
    → [role vars] yamls/sensu-ansible/vars/OpenBSD.yml: /usr/local/bin/bash  ← WINS

  __galaxy_cache_dir:
    → [role vars] yamls/ansible-galaxy/vars/layout-custom.yml: {{ galaxy_mutable_data_dir }}/cache  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy-improved.yml: {{ galaxy_mutable_data_dir }}  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy.yml: {{ galaxy_mutable_data_dir }}  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: {{ galaxy_mutable_data_dir }}/cache  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_mutable_data_dir }}/cache  ← WINS

  __galaxy_config_dir:
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy-improved.yml: {{ galaxy_server_dir }}/config  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy.yml: {{ galaxy_server_dir }}  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: /etc/opt/galaxy  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_root }}/config  ← WINS

  __galaxy_file_path:
    → [role vars] yamls/ansible-galaxy/vars/layout-custom.yml: {{ galaxy_mutable_data_dir }}/datasets  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy-improved.yml: {{ galaxy_mutable_data_dir }}/datasets  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy.yml: {{ galaxy_mutable_data_dir }}/datasets  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: /srv/galaxy/datasets  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_root }}/datasets  ← WINS

  __galaxy_job_working_directory:
    → [role vars] yamls/ansible-galaxy/vars/layout-custom.yml: {{ galaxy_mutable_data_dir }}/jobs  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy-improved.yml: {{ galaxy_mutable_data_dir }}/jobs  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy.yml: {{ galaxy_mutable_data_dir }}/jobs  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: {{ galaxy_mutable_data_dir }}/jobs  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_root }}/jobs  ← WINS

  __galaxy_local_tools_dir:
    → [role vars] yamls/ansible-galaxy/vars/layout-custom.yml: ~  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy-improved.yml: ~  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy.yml: ~  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: /var/opt/galaxy/local_tools  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_root }}/local_tools  ← WINS

  __galaxy_mutable_config_dir:
    → [role vars] yamls/ansible-galaxy/vars/layout-custom.yml: {{ galaxy_mutable_data_dir }}/config  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy-improved.yml: {{ galaxy_server_dir }}/config  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy.yml: {{ galaxy_server_dir }}  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: {{ galaxy_mutable_data_dir }}/config  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_mutable_data_dir }}/config  ← WINS

  __galaxy_mutable_data_dir:
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy-improved.yml: {{ galaxy_server_dir }}/database  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy.yml: {{ galaxy_server_dir }}/database  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: /var/opt/galaxy/data  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_root }}/var  ← WINS

  __galaxy_server_dir:
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: /opt/galaxy  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_root }}/server  ← WINS

  __galaxy_shed_tools_dir:
    → [role vars] yamls/ansible-galaxy/vars/layout-custom.yml: {{ galaxy_mutable_data_dir }}/shed_tools  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy-improved.yml: {{ galaxy_mutable_data_dir }}/shed_tools  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy.yml: {{ galaxy_server_dir }}/../shed_tools  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: {{ galaxy_mutable_data_dir }}/shed_tools  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_mutable_data_dir }}/shed_tools  ← WINS

  __galaxy_tool_data_path:
    → [role vars] yamls/ansible-galaxy/vars/layout-custom.yml: {{ galaxy_mutable_data_dir }}/tool_data  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy-improved.yml: {{ galaxy_mutable_data_dir }}/tool_data  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy.yml: {{ galaxy_server_dir }}/tool_data  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: {{ galaxy_mutable_data_dir }}/tool_data  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_mutable_data_dir }}/tool_data  ← WINS

  __galaxy_venv_dir:
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy-improved.yml: {{ galaxy_server_dir }}/.venv  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-legacy.yml: {{ galaxy_server_dir }}/.venv  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-opt.yml: /var/opt/galaxy/venv  ← WINS
    → [role vars] yamls/ansible-galaxy/vars/layout-root-dir.yml: {{ galaxy_root }}/venv  ← WINS

  __root_group:
      [role default] yamls/sensu-ansible/defaults/main.yml: root
    → [role vars] yamls/sensu-ansible/vars/FreeBSD.yml: wheel  ← WINS
    → [role vars] yamls/sensu-ansible/vars/OpenBSD.yml: wheel  ← WINS

  addusers:
      [role default] yamls/kubespray/roles/adduser/defaults/main.yml: etcd:
  name: etcd
  comment: Etcd user
  create_home: fa...
    → [role vars] yamls/kubespray/roles/adduser/vars/coreos.yml: - name: kube
  comment: Kubernetes user
  shell: /sbin/no...  ← WINS
    → [role vars] yamls/kubespray/roles/adduser/vars/debian.yml: - name: etcd
  comment: Etcd user
  create_home: true
  h...  ← WINS
    → [role vars] yamls/kubespray/roles/adduser/vars/redhat.yml: - name: etcd
  comment: Etcd user
  create_home: true
  h...  ← WINS

  ansible_ssh_pipelining:
    → [play vars] yamls/kubespray/extra_playbooks/upgrade-only-k8s.yml: false  ← WINS
    → [play vars] yamls/kubespray/scripts/collect-info.yaml: true  ← WINS

  apache:
    → [role vars] yamls/ansible-examples/language_features/vars/CentOS.yml: httpd  ← WINS
    → [role vars] yamls/ansible-examples/language_features/vars/defaults.yml: apache  ← WINS

  apparmor__var_template_operator:
    → [play vars] yamls/debops/ansible/roles/apparmor/tasks/handle_locals.yml:    ← WINS
    → [play vars] yamls/debops/ansible/roles/apparmor/tasks/handle_tunables.yml: =  ← WINS

  apparmor__var_template_suffix:
    → [play vars] yamls/debops/ansible/roles/apparmor/tasks/handle_locals.yml: ,  ← WINS
    → [play vars] yamls/debops/ansible/roles/apparmor/tasks/handle_tunables.yml:   ← WINS

  apparmor__var_template_title:
    → [play vars] yamls/debops/ansible/roles/apparmor/tasks/handle_locals.yml: AppArmor local modification  ← WINS
    → [play vars] yamls/debops/ansible/roles/apparmor/tasks/handle_tunables.yml: AppArmor tunable  ← WINS

  argocd_version:
    → [role default] yamls/kubespray/roles/kubernetes-apps/argocd/defaults/main.yml: 2.14.5  ← WINS
    → [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/download.yml: {{ (argocd_install_checksums.no_arch | dict2items)[0].key }}  ← WINS

  aws_ebs_csi_plugin_image_tag:
    → [role default] yamls/kubespray/roles/kubernetes-apps/csi_driver/aws_ebs/defaults/main.yml: latest  ← WINS
    → [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/download.yml: v{{ aws_ebs_csi_plugin_version }}  ← WINS

  awx_host:
    → [play vars] yamls/tools/docker-compose/ansible/plumb_splunk.yml: https://localhost:8043  ← WINS
    → [play vars] yamls/tools/docker-compose/ansible/plumb_vault.yml: https://127.0.0.1:8043  ← WINS

  azure_csi_plugin_image_tag:
    → [role default] yamls/kubespray/roles/kubernetes-apps/csi_driver/azuredisk/defaults/main.yml: latest  ← WINS
    → [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/download.yml: v{{ azure_csi_plugin_version }}  ← WINS

  bin_dir:
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: /usr/local/bin
      [role default] yamls/kubespray/roles/recover_control_plane/control-plane/defaults/main.yml: /usr/local/bin
      [group_vars] yamls/kubespray/inventory/sample/group_vars/all/all.yml: /usr/local/bin
      [role vars] yamls/kubespray/roles/bootstrap_os/vars/flatcar.yml: /opt/bin
    → [play vars] yamls/kubespray/scripts/collect-info.yaml: /usr/local/bin  ← WINS

  build_root:
    → [play vars] yamls/ansible-for-devops/docker-flask/provisioning/main.yml: /vagrant/provisioning  ← WINS
    → [play vars] yamls/ansible-for-devops/tests/docker-flask.yml: {{ playbook_dir }}  ← WINS

  calico_wireguard_packages:
      [role default] yamls/kubespray/roles/network_plugin/calico_defaults/defaults/main.yml: []
    → [role vars] yamls/kubespray/roles/network_plugin/calico/vars/amazon.yml: - wireguard-dkms
- wireguard-tools  ← WINS
    → [role vars] yamls/kubespray/roles/network_plugin/calico/vars/centos-9.yml: - wireguard-tools  ← WINS
    → [role vars] yamls/kubespray/roles/network_plugin/calico/vars/debian.yml: - wireguard  ← WINS
    → [role vars] yamls/kubespray/roles/network_plugin/calico/vars/fedora.yml: - wireguard-tools  ← WINS
    → [role vars] yamls/kubespray/roles/network_plugin/calico/vars/opensuse.yml: - wireguard-tools  ← WINS
    → [role vars] yamls/kubespray/roles/network_plugin/calico/vars/redhat-9.yml: - wireguard-tools  ← WINS
    → [role vars] yamls/kubespray/roles/network_plugin/calico/vars/redhat.yml: - wireguard-dkms
- wireguard-tools  ← WINS
    → [role vars] yamls/kubespray/roles/network_plugin/calico/vars/rocky-9.yml: - wireguard-tools  ← WINS

  calico_wireguard_repo:
      [role default] yamls/kubespray/roles/network_plugin/calico_defaults/defaults/main.yml: https://download.copr.fedorainfracloud.org/results/jdoss/...
    → [role vars] yamls/kubespray/roles/network_plugin/calico/vars/amazon.yml: https://download.copr.fedorainfracloud.org/results/jdoss/...  ← WINS

  clusterIP:
    → [play vars] yamls/kubespray/roles/kubernetes-apps/ansible/tasks/main.yml: {{ skydns_server }}  ← WINS
    → [play vars] yamls/kubespray/roles/kubernetes-apps/ansible/tasks/main.yml: {{ skydns_server_secondary }}  ← WINS

  container_manager:
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: containerd
      [group_vars] yamls/kubespray/inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml: containerd
    → [play vars] yamls/kubespray/roles/container-engine/containerd/molecule/default/converge.yml: containerd  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/containerd/molecule/default/verify.yml: containerd  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/cri-dockerd/molecule/default/converge.yml: docker  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/cri-dockerd/molecule/default/verify.yml: cri-dockerd  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/gvisor/molecule/default/converge.yml: containerd  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/kata-containers/molecule/default/converge.yml: containerd  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/kata-containers/molecule/default/verify.yml: containerd  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/youki/molecule/default/converge.yml: crio  ← WINS

  container_runtime:
    → [play vars] yamls/kubespray/roles/container-engine/cri-dockerd/molecule/default/verify.yml: docker  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/cri-o/molecule/default/verify.yml: crun  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/gvisor/molecule/default/verify.yml: runsc  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/kata-containers/molecule/default/verify.yml: kata-qemu  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/youki/molecule/default/verify.yml: youki  ← WINS

  containerd_package:
      [role default] yamls/kubespray/roles/container-engine/containerd-common/defaults/main.yml: containerd.io
    → [role vars] yamls/kubespray/roles/container-engine/containerd-common/vars/amazon.yml: containerd  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/containerd-common/vars/suse.yml: containerd  ← WINS

  containerd_versioned_pkg:
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/debian.yml: latest: {{ containerd_package }}
1.3.7: {{ containerd_pac...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/fedora.yml: latest: {{ containerd_package }}
1.3.7: {{ containerd_pac...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/kylin.yml: latest: {{ containerd_package }}
1.3.7: {{ containerd_pac...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/redhat.yml: latest: {{ containerd_package }}
1.3.7: {{ containerd_pac...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/ubuntu.yml: latest: {{ containerd_package }}
1.6.4: {{ containerd_pac...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/uniontech.yml: latest: {{ containerd_package }}
1.3.7: {{ containerd_pac...  ← WINS

  coredns_ordinal_suffix:
      [role default] yamls/kubespray/roles/kubernetes-apps/ansible/defaults/main.yml: 
    → [play vars] yamls/kubespray/roles/kubernetes-apps/ansible/tasks/main.yml: -secondary  ← WINS

  cri_name:
    → [play vars] yamls/kubespray/roles/container-engine/containerd/molecule/default/verify.yml: containerd  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/cri-dockerd/molecule/default/verify.yml: docker  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/cri-o/molecule/default/verify.yml: cri-o  ← WINS

  cri_socket:
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: {%- if container_manager == 'crio' -%} unix:///var/run/cr...
    → [play vars] yamls/kubespray/roles/container-engine/containerd/molecule/default/verify.yml: unix:///var/run/containerd/containerd.sock  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/cri-dockerd/molecule/default/verify.yml: unix:///var/run/cri-dockerd.sock  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/cri-o/molecule/default/verify.yml: unix:///var/run/crio/crio.sock  ← WINS

  crio_bin_files:
    → [role vars] yamls/kubespray/roles/container-engine/cri-o/vars/v1.29.yml: - crio-conmon
- crio-conmonrs
- crio-crun
- crio-runc
- c...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/cri-o/vars/v1.31.yml: - crio
- pinns  ← WINS

  crio_conmon:
      [role default] yamls/kubespray/roles/container-engine/cri-o/defaults/main.yml: {{ bin_dir }}/conmon
    → [role vars] yamls/kubespray/roles/container-engine/cri-o/vars/v1.29.yml: {{ bin_dir }}/crio-conmon  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/cri-o/vars/v1.31.yml: {{ crio_libexec_dir }}/conmon  ← WINS

  crio_runtime_bin_dir:
    → [role vars] yamls/kubespray/roles/container-engine/cri-o/vars/v1.29.yml: {{ bin_dir }}  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/cri-o/vars/v1.31.yml: {{ crio_libexec_dir }}  ← WINS

  discovery_timeout:
    → [role default] yamls/kubespray/roles/kubernetes/control-plane/defaults/main/main.yml: 5m0s  ← WINS
    → [role default] yamls/kubespray/roles/kubernetes/kubeadm/defaults/main.yml: 60s  ← WINS

  docker_cli_version:
      [role default] yamls/kubespray/roles/container-engine/docker/defaults/main.yml: {{ docker_version }}
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/kylin.yml: {{ docker_version }}  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/uniontech.yml: 19.03  ← WINS

  docker_cli_versioned_pkg:
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/debian.yml: latest: docker-ce-cli
18.09: docker-ce-cli=5:18.09.9~3-0~...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/fedora.yml: latest: docker-ce-cli
19.03: docker-ce-cli-19.03.15-3.fc{...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/kylin.yml: latest: docker-ce-cli
18.09: docker-ce-cli-1:18.09.9-3.el...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/redhat.yml: latest: docker-ce-cli
18.09: docker-ce-cli-1:18.09.9-3.el...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/ubuntu.yml: latest: docker-ce-cli
18.09: docker-ce-cli=5:18.09.9~3-0~...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/uniontech.yml: latest: docker-ce-cli
18.09: docker-ce-cli-1:18.09.9-3.el...  ← WINS

  docker_package_info:
      [role default] yamls/kubespray/roles/container-engine/docker/defaults/main.yml: pkgs: ~
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/amazon.yml: pkgs:
  - {{ docker_versioned_pkg[docker_version | string...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/clearlinux.yml: pkgs:
  - containers-basic  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/debian.yml: pkgs:
  - {{ containerd_versioned_pkg[docker_containerd_v...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/fedora.yml: enablerepo: docker-ce
pkgs:
  - {{ containerd_versioned_p...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/kylin.yml: enablerepo: docker-ce
pkgs:
  - {{ containerd_versioned_p...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/redhat.yml: enablerepo: docker-ce
pkgs:
  - {{ containerd_versioned_p...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/suse.yml: state: latest
pkgs:
  - docker
  - containerd  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/ubuntu.yml: pkgs:
  - {{ containerd_versioned_pkg[docker_containerd_v...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/uniontech.yml: enablerepo: docker-ce
disablerepo: UniontechOS-20-AppStre...  ← WINS

  docker_repo_info:
      [role default] yamls/kubespray/roles/container-engine/docker/defaults/main.yml: repos: ~
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/debian.yml: repos:
  - deb {{ docker_debian_repo_base_url }} {{ ansib...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/ubuntu.yml: repos:
  - deb [arch={{ host_architecture }}] {{ docker_u...  ← WINS

  docker_repo_key_info:
      [role default] yamls/kubespray/roles/container-engine/docker/defaults/main.yml: repo_keys: ~
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/debian.yml: url: {{ docker_debian_repo_gpgkey }}
repo_keys:
  - {{ do...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/ubuntu.yml: url: {{ docker_ubuntu_repo_gpgkey }}
repo_keys:
  - {{ do...  ← WINS

  docker_rh_repo_base_url:
      [role default] yamls/kubespray/roles/container-engine/docker/defaults/main.yml: https://download.docker.com/linux/rhel/{{ ansible_distrib...
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/kylin.yml: https://download.docker.com/linux/centos/8/$basearch/stable  ← WINS

  docker_version:
      [role default] yamls/kubespray/roles/container-engine/docker/defaults/main.yml: 28.3
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/amazon.yml: latest  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/kylin.yml: 26.1  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/uniontech.yml: 19.03  ← WINS

  docker_versioned_pkg:
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/amazon.yml: latest: docker
18.09: docker-18.09.9ce-2.amzn2
19.03: doc...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/debian.yml: latest: docker-ce
18.09: docker-ce=5:18.09.9~3-0~debian-{...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/fedora.yml: latest: docker-ce
19.03: docker-ce-19.03.15-3.fc{{ ansibl...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/kylin.yml: latest: docker-ce
18.09: docker-ce-3:18.09.9-3.el8
19.03:...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/redhat.yml: latest: docker-ce
18.09: docker-ce-3:18.09.9-3.el7
19.03:...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/ubuntu.yml: latest: docker-ce
18.09: docker-ce=5:18.09.9~3-0~ubuntu-{...  ← WINS
    → [role vars] yamls/kubespray/roles/container-engine/docker/vars/uniontech.yml: latest: docker-ce
18.09: docker-ce-3:18.09.9-3.el7
19.03:...  ← WINS

  download:
    → [play vars] yamls/kubespray/roles/container-engine/skopeo/tasks/main.yml: {{ download_defaults | combine(downloads.skopeo) }}  ← WINS
    → [play vars] yamls/kubespray/roles/kubernetes-apps/helm/tasks/main.yml: {{ download_defaults | combine(downloads.helm) }}  ← WINS
    → [play vars] yamls/kubespray/roles/kubernetes-apps/common_crds/prometheus_operator_crds/tasks/main.yml: {{ download_defaults | combine(downloads.prometheus_opera...  ← WINS
    → [play vars] yamls/kubespray/roles/kubernetes-apps/common_crds/gateway_api/tasks/main.yml: {{ download_defaults | combine(downloads.gateway_api_crds...  ← WINS
    → [play vars] yamls/kubespray/roles/kubernetes-apps/argocd/tasks/main.yml: {{ download_defaults | combine(item.download) }}  ← WINS
    → [play vars] yamls/kubespray/roles/kubernetes-apps/argocd/tasks/main.yml: {{ download_defaults | combine(downloads.yq) }}  ← WINS
    → [play vars] yamls/kubespray/roles/etcdctl_etcdutl/tasks/main.yml: {{ download_defaults | combine(downloads.etcd) }}  ← WINS
    → [play vars] yamls/kubespray/roles/download/tasks/prep_kubeadm_images.yml: {{ download_defaults | combine(downloads.kubeadm) }}  ← WINS
    → [play vars] yamls/kubespray/roles/download/tasks/main.yml: {{ download_defaults | combine(item.value) }}  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/youki/tasks/main.yml: {{ download_defaults | combine(downloads.youki) }}  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/containerd/tasks/main.yml: {{ download_defaults | combine(downloads.containerd) }}  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/runc/tasks/main.yml: {{ download_defaults | combine(downloads.runc) }}  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/nerdctl/tasks/main.yml: {{ download_defaults | combine(downloads.nerdctl) }}  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/kata-containers/tasks/main.yml: {{ download_defaults | combine(downloads.kata_containers) }}  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/gvisor/tasks/main.yml: {{ download_defaults | combine(downloads.gvisor_container...  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/gvisor/tasks/main.yml: {{ download_defaults | combine(downloads.gvisor_runsc) }}  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/crun/tasks/main.yml: {{ download_defaults | combine(downloads.crun) }}  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/crictl/tasks/main.yml: {{ download_defaults | combine(downloads.crictl) }}  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/cri-o/tasks/main.yaml: {{ download_defaults | combine(downloads.crio) }}  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/cri-dockerd/tasks/main.yml: {{ download_defaults | combine(downloads.cri_dockerd) }}  ← WINS

  dpkg_cleanup__dependent_packages:
      [role default] yamls/debops/ansible/roles/dpkg_cleanup/defaults/main.yml: []
    → [play vars] yamls/debops/ansible/roles/nullmailer/tasks/main.yml: - {{ nullmailer__dpkg_cleanup__dependent_packages }}  ← WINS
    → [play vars] yamls/debops/ansible/roles/resolved/tasks/main.yml: - {{ resolved__dpkg_cleanup__dependent_packages }}  ← WINS
    → [play vars] yamls/debops/ansible/roles/rsyslog/tasks/main.yml: - {{ rsyslog__dpkg_cleanup__dependent_packages }}  ← WINS
    → [play vars] yamls/debops/ansible/roles/timesyncd/tasks/main.yml: - {{ timesyncd__dpkg_cleanup__dependent_packages }}  ← WINS
    → [play vars] yamls/debops/ansible/roles/zabbix_agent/tasks/main.yml: - {{ zabbix_agent__dpkg_cleanup__dependent_packages }}  ← WINS

  endpoint:
    → [play vars] yamls/kubespray/roles/kubernetes/control-plane/handlers/main.yml: {{ kube_scheduler_bind_address if kube_scheduler_bind_add...  ← WINS
    → [play vars] yamls/kubespray/roles/kubernetes/control-plane/handlers/main.yml: {{ kube_controller_manager_bind_address if kube_controlle...  ← WINS

  etcd_cert_dir:
      [role default] yamls/kubespray/roles/etcd_defaults/defaults/main.yml: {{ etcd_config_dir }}/ssl
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: {{ etcd_config_dir }}/ssl
    → [play vars] yamls/kubespray/scripts/collect-info.yaml: /etc/ssl/etcd/ssl  ← WINS

  etcd_cluster_setup:
      [role default] yamls/kubespray/roles/etcd_defaults/defaults/main.yml: true
    → [play vars] yamls/kubespray/playbooks/cluster.yml: true  ← WINS
    → [play vars] yamls/kubespray/playbooks/scale.yml: false  ← WINS
    → [play vars] yamls/kubespray/playbooks/upgrade_cluster.yml: true  ← WINS

  etcd_events_cluster_setup:
      [role default] yamls/kubespray/roles/etcd_defaults/defaults/main.yml: false
    → [play vars] yamls/kubespray/playbooks/cluster.yml: {{ etcd_events_cluster_enabled }}  ← WINS
    → [play vars] yamls/kubespray/playbooks/scale.yml: false  ← WINS
    → [play vars] yamls/kubespray/playbooks/upgrade_cluster.yml: {{ etcd_events_cluster_enabled }}  ← WINS

  etcd_events_peer_addresses:
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: {% for item in groups['etcd'] -%}
  {{ hostvars[item].etc...
    → [play vars] yamls/kubespray/roles/etcd/tasks/join_etcd-events_member.yml: {% for host in groups['etcd'] -%}
  {%- if hostvars[host]...  ← WINS

  etcd_peer_addresses:
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: {% for item in groups['etcd'] -%}
  {{ hostvars[item].etc...
    → [play vars] yamls/kubespray/roles/etcd/tasks/join_etcd_member.yml: {% for host in groups['etcd'] -%}
  {%- if hostvars[host]...  ← WINS

  expected_files:
    → [play vars] yamls/kubespray/roles/etcd/tasks/check_certs.yml: ['{{ etcd_cert_dir }}/ca.pem', {% set etcd_members = grou...  ← WINS
    → [play vars] yamls/kubespray/roles/etcd/tasks/check_certs.yml: ['{{ etcd_cert_dir }}/ca.pem', {% set etcd_members = grou...  ← WINS

  ferm__dependent_rules:
      [role default] yamls/debops/ansible/roles/ferm/defaults/main.yml: []
    → [play vars] yamls/debops/ansible/playbooks/service/postconf.yml: - {{ postfix__ferm__dependent_rules }}  ← WINS

  filebeat_inputs:
    → [role vars] yamls/ansible-for-devops/elk/provisioning/elk/vars/main.yml: - type: log
  paths:
    - /var/log/auth.log  ← WINS
    → [role vars] yamls/ansible-for-devops/elk/provisioning/web/vars/main.yml: - type: log
  paths:
    - /var/log/auth.log
- type: log
...  ← WINS

  firewall_allowed_tcp_ports:
      [role vars] yamls/ansible-for-devops/https-letsencrypt/vars/main.yml: - 22
- 80
- 443
      [role vars] yamls/ansible-for-devops/https-nginx-proxy/provisioning/vars/main.yml: - 22
- 80
- 443
      [role vars] yamls/ansible-for-devops/https-self-signed/provisioning/vars/main.yml: - 22
- 80
- 443
    → [play vars] yamls/ansible-for-devops/deployments-balancer/playbooks/provision.yml: - 22
- 80  ← WINS
    → [play vars] yamls/ansible-for-devops/deployments-rolling/playbooks/provision.yml: - 22
- 8080  ← WINS
    → [play vars] yamls/ansible-for-devops/jenkins/provision.yml: - 22
- 8080  ← WINS

  galaxy_client_use_prebuilt:
      [role default] yamls/ansible-galaxy/defaults/main.yml: false
    → [play vars] yamls/ansible-galaxy/molecule/prebuilt_client/converge.yml: true  ← WINS

  galaxy_create_user:
      [role default] yamls/ansible-galaxy/defaults/main.yml: no
    → [play vars] yamls/ansible-galaxy/molecule/default/converge.yml: yes  ← WINS
    → [play vars] yamls/ansible-galaxy/molecule/prebuilt_client/converge.yml: yes  ← WINS

  galaxy_manage_gravity:
      [role default] yamls/ansible-galaxy/defaults/main.yml: {{ false if __galaxy_major_version is version('22.05', '<...
    → [play vars] yamls/ansible-galaxy/molecule/default/converge.yml: {{ false if __galaxy_major_version is version('22.01', '<...  ← WINS
    → [play vars] yamls/ansible-galaxy/molecule/prebuilt_client/converge.yml: {{ false if __galaxy_major_version is version('22.01', '<...  ← WINS

  galaxy_manage_paths:
      [role default] yamls/ansible-galaxy/defaults/main.yml: no
    → [play vars] yamls/ansible-galaxy/molecule/default/converge.yml: yes  ← WINS
    → [play vars] yamls/ansible-galaxy/molecule/prebuilt_client/converge.yml: yes  ← WINS

  galaxy_manage_systemd:
      [role default] yamls/ansible-galaxy/defaults/main.yml: no
    → [play vars] yamls/ansible-galaxy/molecule/default/converge.yml: yes  ← WINS
    → [play vars] yamls/ansible-galaxy/molecule/prebuilt_client/converge.yml: yes  ← WINS

  galaxy_privsep_user:
      [role default] yamls/ansible-galaxy/defaults/main.yml: root
    → [play vars] yamls/ansible-galaxy/molecule/default/converge.yml: gxpriv  ← WINS
    → [play vars] yamls/ansible-galaxy/molecule/prebuilt_client/converge.yml: gxpriv  ← WINS

  galaxy_separate_privileges:
      [role default] yamls/ansible-galaxy/defaults/main.yml: no
    → [play vars] yamls/ansible-galaxy/molecule/default/converge.yml: yes  ← WINS
    → [play vars] yamls/ansible-galaxy/molecule/prebuilt_client/converge.yml: yes  ← WINS

  galaxy_systemd_mode:
      [role default] yamls/ansible-galaxy/defaults/main.yml: {{ 'mule' if __galaxy_major_version is version('22.05', '...
    → [play vars] yamls/ansible-galaxy/molecule/default/converge.yml: {{ 'mule' if __galaxy_major_version is version('22.01', '...  ← WINS
    → [play vars] yamls/ansible-galaxy/molecule/prebuilt_client/converge.yml: {{ 'mule' if __galaxy_major_version is version('22.01', '...  ← WINS

  galaxy_user:
      [role default] yamls/ansible-galaxy/defaults/main.yml: {{ ansible_user_id }}
    → [play vars] yamls/ansible-galaxy/molecule/default/converge.yml: galaxy  ← WINS
    → [play vars] yamls/ansible-galaxy/molecule/prebuilt_client/converge.yml: galaxy  ← WINS

  gvisor_enabled:
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: false
    → [play vars] yamls/kubespray/roles/container-engine/gvisor/molecule/default/converge.yml: true  ← WINS

  haproxy_backend_weight:
    → [host_vars] yamls/ansible-tuto/step-11/host_vars/host0.yml: 150  ← WINS
    → [host_vars] yamls/ansible-tuto/step-11/host_vars/host1.yml: 100  ← WINS
    → [host_vars] yamls/ansible-tuto/step-11/host_vars/host2.yml: 150  ← WINS
    → [host_vars] yamls/ansible-tuto/step-12/host_vars/host0.yml: 150  ← WINS
    → [host_vars] yamls/ansible-tuto/step-12/host_vars/host1.yml: 100  ← WINS
    → [host_vars] yamls/ansible-tuto/step-12/host_vars/host2.yml: 150  ← WINS
    → [host_vars] yamls/ansible-tuto/step-13/host_vars/host0.yml: 150  ← WINS
    → [host_vars] yamls/ansible-tuto/step-13/host_vars/host1.yml: 100  ← WINS
    → [host_vars] yamls/ansible-tuto/step-13/host_vars/host2.yml: 150  ← WINS

  ignore_assert_errors:
      [role default] yamls/kubespray/roles/kubernetes/preinstall/defaults/main.yml: false
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: false
    → [play vars] yamls/kubespray/roles/container-engine/molecule/prepare.yml: true  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/molecule/prepare.yml: true  ← WINS

  is_fedora_coreos:
      [role default] yamls/kubespray/roles/bootstrap_os/defaults/main.yml: false
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: false
    → [role vars] yamls/kubespray/roles/bootstrap_os/vars/fedora-coreos.yml: true  ← WINS

  k8s_namespace:
      [role default] yamls/kubespray/roles/kubernetes-apps/utils/defaults/main.yml: kube-system
    → [play vars] yamls/kubespray/roles/kubernetes-apps/ansible/tasks/main.yml: {{ netcheck_namespace }}  ← WINS

  kata_containers_enabled:
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: false
      [group_vars] yamls/kubespray/inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml: false
    → [play vars] yamls/kubespray/roles/container-engine/kata-containers/molecule/default/converge.yml: true  ← WINS

  kube_network_plugin:
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: calico
      [group_vars] yamls/kubespray/inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml: calico
    → [play vars] yamls/kubespray/roles/container-engine/molecule/prepare.yml: cni  ← WINS
    → [play vars] yamls/kubespray/scripts/collect-info.yaml: calico  ← WINS

  kube_resolv_conf:
      [role default] yamls/kubespray/roles/kubernetes/node/defaults/main.yml: /etc/resolv.conf
    → [role vars] yamls/kubespray/roles/kubernetes/node/vars/fedora.yml: /run/systemd/resolve/resolv.conf  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes/node/vars/ubuntu-18.yml: /run/systemd/resolve/resolv.conf  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes/node/vars/ubuntu-20.yml: /run/systemd/resolve/resolv.conf  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes/node/vars/ubuntu-22.yml: /run/systemd/resolve/resolv.conf  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes/node/vars/ubuntu-24.yml: /run/systemd/resolve/resolv.conf  ← WINS

  ldap__admin_binddn:
      [role default] yamls/debops/ansible/roles/ldap/defaults/main.yml: {{ lookup("env", "DEBOPS_LDAP_ADMIN_BINDDN")
            ...
    → [play vars] yamls/debops/ansible/playbooks/ldap/init-directory.yml: {{ ([ "cn=admin" ] + ldap__base_dn) | join(",") }}  ← WINS

  ldap__admin_bindpw:
      [role default] yamls/debops/ansible/roles/ldap/defaults/main.yml: {{ (lookup("env", "DEBOPS_LDAP_ADMIN_BINDPW")
           ...
    → [play vars] yamls/debops/ansible/playbooks/ldap/init-directory.yml: {{ lookup("password", secret + "/slapd/credentials/"
    ...  ← WINS

  ldap__configured:
      [role default] yamls/debops/ansible/roles/ldap/defaults/main.yml: {{ ansible_local.ldap.configured
                      if...
    → [play vars] yamls/debops/ansible/playbooks/ldap/init-directory.yml: True  ← WINS

  ldap__dependent_play:
      [role default] yamls/debops/ansible/roles/ldap/defaults/main.yml: {{ True
                          if (ldap__configured | ...
    → [play vars] yamls/debops/ansible/playbooks/ldap/init-directory.yml: True  ← WINS

  ldap__dependent_tasks:
      [role default] yamls/debops/ansible/roles/ldap/defaults/main.yml: []
    → [play vars] yamls/debops/ansible/playbooks/ldap/init-directory.yml: - name: Create personal account for {{ admin_user }}
  dn...  ← WINS

  ldap__enabled:
      [role default] yamls/debops/ansible/roles/ldap/defaults/main.yml: {{ ansible_local.ldap.enabled
                   if (ansi...
    → [play vars] yamls/debops/ansible/playbooks/bootstrap-ldap.yml: True  ← WINS
    → [play vars] yamls/debops/ansible/playbooks/bootstrap-sss.yml: True  ← WINS
    → [play vars] yamls/debops/ansible/playbooks/ldap/init-directory.yml: True  ← WINS
    → [play vars] yamls/debops/ansible/playbooks/ldap/save-credential.yml: False  ← WINS

  ldap__servers:
      [role default] yamls/debops/ansible/roles/ldap/defaults/main.yml: {{ ldap__servers_srv_rr | map(attribute="target") }}
    → [play vars] yamls/debops/ansible/playbooks/ldap/init-directory.yml: [{{ ansible_fqdn }}]  ← WINS

  local_volume_provisioner_storage_classes:
    → [role default] yamls/kubespray/roles/kubernetes-apps/external_provisioner/local_volume_provisioner/defaults/main.yml: {
  "{{ local_volume_provisioner_storage_class | default(...  ← WINS
    → [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: {
  "{{ local_volume_provisioner_storage_class | default(...  ← WINS

  lvm__config_base:
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.02.111.yml: config:
  checks: 1
  abort_on_errors: 0
  profile_dir: /...  ← WINS
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.02.168.yml: config:
  checks: 1
  abort_on_errors: 0
  profile_dir: /...  ← WINS
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.02.66.yml: devices:
  dir: /dev
  scan: [/dev]
  preferred_names: []...  ← WINS
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.02.95.yml: devices:
  dir: /dev
  scan: [/dev]
  obtain_device_list_...  ← WINS
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.02.98.yml: devices:
  dir: /dev
  scan: [/dev]
  obtain_device_list_...  ← WINS
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.03.02.yml: config:
  checks: 1
  abort_on_errors: 0
  profile_dir: /...  ← WINS

  lvm__config_base_version:
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.02.111.yml: 2.02.111-2.2  ← WINS
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.02.168.yml: 2.02.168-2  ← WINS
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.02.66.yml: 2.02.66-4ubuntu7.4  ← WINS
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.02.95.yml: 2.02.95-8  ← WINS
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.02.98.yml: 2.02.98-6ubuntu2  ← WINS
    → [role vars] yamls/debops/ansible/roles/lvm/vars/lvm_config_2.03.02.yml: 2.03.02-3  ← WINS

  macvlan_interface:
      [role default] yamls/kubespray/roles/network_plugin/macvlan/defaults/main.yml: eth0
    → [group_vars] yamls/kubespray/inventory/sample/group_vars/k8s_cluster/k8s-net-macvlan.yml: eth1  ← WINS

  nginx_remove_default_vhost:
    → [role vars] yamls/ansible-for-devops/elk/provisioning/elk/vars/main.yml: true  ← WINS
    → [role vars] yamls/ansible-for-devops/elk/provisioning/web/vars/main.yml: true  ← WINS
    → [role vars] yamls/ansible-for-devops/https-letsencrypt/vars/main.yml: true  ← WINS
    → [role vars] yamls/ansible-for-devops/https-nginx-proxy/provisioning/vars/main.yml: True  ← WINS
    → [role vars] yamls/ansible-for-devops/https-self-signed/provisioning/vars/main.yml: True  ← WINS

  nginx_vhosts:
    → [role vars] yamls/ansible-for-devops/elk/provisioning/elk/vars/main.yml: - listen: 80 default_server
  filename: kibana.conf
  ser...  ← WINS
    → [role vars] yamls/ansible-for-devops/https-letsencrypt/vars/main.yml: []  ← WINS
    → [role vars] yamls/ansible-for-devops/https-nginx-proxy/provisioning/vars/main.yml: []  ← WINS
    → [role vars] yamls/ansible-for-devops/https-self-signed/provisioning/vars/main.yml: []  ← WINS

  ntp_servers:
      [role default] yamls/kubespray/roles/kubernetes/preinstall/defaults/main.yml: - 0.pool.ntp.org iburst
- 1.pool.ntp.org iburst
- 2.pool....
      [role default] yamls/yaml/roles/common/defaults/main.yml: - 0.pool.ntp.org
- 1.pool.ntp.org
- 2.pool.ntp.org
- 3.po...
    → [group_vars] yamls/kubespray/inventory/sample/group_vars/all/all.yml: - 0.pool.ntp.org iburst
- 1.pool.ntp.org iburst
- 2.pool....  ← WINS

  nvidia_driver_install_container:
      [role default] yamls/kubespray/roles/kubernetes-apps/container_engine_accelerator/nvidia_gpu/defaults/main.yml: false
    → [role vars] yamls/kubespray/roles/kubernetes-apps/container_engine_accelerator/nvidia_gpu/vars/ubuntu-16.yml: {{ nvidia_driver_install_ubuntu_container }}  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes-apps/container_engine_accelerator/nvidia_gpu/vars/ubuntu-18.yml: {{ nvidia_driver_install_ubuntu_container }}  ← WINS

  nvidia_driver_install_supported:
      [role default] yamls/kubespray/roles/kubernetes-apps/container_engine_accelerator/nvidia_gpu/defaults/main.yml: false
    → [role vars] yamls/kubespray/roles/kubernetes-apps/container_engine_accelerator/nvidia_gpu/vars/ubuntu-16.yml: true  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes-apps/container_engine_accelerator/nvidia_gpu/vars/ubuntu-18.yml: true  ← WINS

  packager:
    → [role vars] yamls/ansible-examples/language_features/vars/CentOS.yml: yum  ← WINS
    → [role vars] yamls/ansible-examples/language_features/vars/defaults.yml: apt  ← WINS

  pip_install_packages:
      [role vars] yamls/ansible-for-devops/https-nginx-proxy/provisioning/vars/main.yml: [pyopenssl]
      [role vars] yamls/ansible-for-devops/https-self-signed/provisioning/vars/main.yml: [pyopenssl]
    → [play vars] yamls/ansible-for-devops/tests/docker-hubot.yml: - docker  ← WINS
    → [play vars] yamls/ansible-for-devops/tests/docker.yml: - docker  ← WINS

  postfix__dependent_lookup_tables:
      [role default] yamls/debops/ansible/roles/postfix/defaults/main.yml: []
    → [play vars] yamls/debops/ansible/playbooks/service/postconf.yml: - {{ postconf__postfix__dependent_lookup_tables }}  ← WINS

  postfix__dependent_maincf:
      [role default] yamls/debops/ansible/roles/postfix/defaults/main.yml: []
    → [play vars] yamls/debops/ansible/playbooks/service/postconf.yml: - role: postconf
  config: {{ postconf__postfix__dependen...  ← WINS

  postfix__dependent_mastercf:
      [role default] yamls/debops/ansible/roles/postfix/defaults/main.yml: []
    → [play vars] yamls/debops/ansible/playbooks/service/postconf.yml: - role: postconf
  config: {{ postconf__postfix__dependen...  ← WINS

  postfix__dependent_packages:
      [role default] yamls/debops/ansible/roles/postfix/defaults/main.yml: []
    → [play vars] yamls/debops/ansible/playbooks/service/postconf.yml: - {{ postconf__postfix__dependent_packages }}  ← WINS

  pyyaml_package:
    → [role vars] yamls/kubespray/roles/kubernetes-apps/helm/vars/amazon.yml: PyYAML  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes-apps/helm/vars/centos-7.yml: PyYAML  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes-apps/helm/vars/centos.yml: python3-pyyaml  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes-apps/helm/vars/debian.yml: python3-yaml  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes-apps/helm/vars/fedora.yml: python3-pyyaml  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes-apps/helm/vars/redhat-7.yml: PyYAML  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes-apps/helm/vars/redhat.yml: python3-pyyaml  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes-apps/helm/vars/suse.yml: python3-PyYAML  ← WINS
    → [role vars] yamls/kubespray/roles/kubernetes-apps/helm/vars/ubuntu.yml: python3-yaml  ← WINS

  rails_deploy_dependencies:
      [role default] yamls/debops/ansible/roles/rails_deploy/defaults/main.yml: [database, redis, nginx, ruby, monit]
    → [host_vars] yamls/debops/docs/ansible/roles/rails_deploy/examples/ansible/inventory/host_vars/somehost.yml: [nginx]  ← WINS

  rails_deploy_env:
      [role default] yamls/debops/ansible/roles/rails_deploy/defaults/main.yml: {}
    → [host_vars] yamls/debops/docs/ansible/roles/rails_deploy/examples/ansible/inventory/host_vars/somehost.yml: S3_ACCESS_KEY_ID: ""
S3_SECRET_ACCESS_KEY: ""
S3_REGION: ...  ← WINS

  rails_deploy_git_access_token:
      [role default] yamls/debops/ansible/roles/rails_deploy/defaults/main.yml: False
    → [host_vars] yamls/debops/docs/ansible/roles/rails_deploy/examples/ansible/inventory/host_vars/somehost.yml: xxxxxxxxxxx  ← WINS

  rails_deploy_git_location:
      [role default] yamls/debops/ansible/roles/rails_deploy/defaults/main.yml: 
    → [host_vars] yamls/debops/docs/ansible/roles/rails_deploy/examples/ansible/inventory/host_vars/somehost.yml: git@github.com:youraccount/yourappname.git  ← WINS

  rails_deploy_postgresql_cluster:
      [role default] yamls/debops/ansible/roles/rails_deploy/defaults/main.yml: 9.1/main
    → [host_vars] yamls/debops/docs/ansible/roles/rails_deploy/examples/ansible/inventory/host_vars/somehost.yml: 9.3/main  ← WINS

  rails_deploy_user_groups:
      [role default] yamls/debops/ansible/roles/rails_deploy/defaults/main.yml: []
    → [host_vars] yamls/debops/docs/ansible/roles/rails_deploy/examples/ansible/inventory/host_vars/somehost.yml: [sshusers]  ← WINS

  rrules:
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- frequency: month
  inter...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
  byweekday: monday, Tuesd...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: month
  interval: 1
  byweekday: saturday
  ...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: minute
  byweekday:
    - monday
    - tuesd...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: minute
  interval: 5
- frequency: minute
  i...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- frequency: day
  interva...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- frequency: day
  interva...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
  include: False
- frequen...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- frequency: day
  interva...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- interval: 1
  byweekday:...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- frequency: month
  inter...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- frequency: month
  inter...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- frequency: month
  inter...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- frequency: day
  interva...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
  byweekday: monday  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- frequency: day
  interva...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- frequency: asdf
  interv...  ← WINS
    → [play vars] yamls/awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml: - frequency: day
  interval: 1
- interval: 1
  byweekday:...  ← WINS

  secret:
    → [role default] yamls/debops/ansible/roles/secret/defaults/main.yml: {{ (secret__root + "/" + ((secret__levels + "/") if secre...  ← WINS
    → [role default] yamls/yaml/roles/common/defaults/main.yml: {{ secret_root + "/" + secret_name }}  ← WINS
    → [role default] yamls/yaml/roles/mailserver/defaults/main.yml: {{ secret_root + "/" + secret_name }}  ← WINS
    → [role default] yamls/yaml/roles/news/defaults/main.yml: {{ secret_root + "/" + secret_name }}  ← WINS
    → [role default] yamls/yaml/roles/owncloud/defaults/main.yml: {{ secret_root + "/" + secret_name }}  ← WINS
    → [role default] yamls/yaml/roles/readlater/defaults/main.yml: {{ secret_root + "/" + secret_name }}  ← WINS

  secret__directories:
      [role default] yamls/debops/ansible/roles/secret/defaults/main.yml: []
    → [play vars] yamls/debops/ansible/playbooks/service/postconf.yml: - {{ postfix__secret__directories }}  ← WINS
    → [play vars] yamls/debops/ansible/roles/journald/tasks/main.yml: - {{ (journald__fss_verify_key_path | dirname)
          ...  ← WINS

  sensu_client_service_name:
      [role default] yamls/sensu-ansible/defaults/main.yml: sensu-client
    → [role vars] yamls/sensu-ansible/vars/OpenBSD.yml: sensuclient  ← WINS

  sensu_config_path:
      [role default] yamls/sensu-ansible/defaults/main.yml: /etc/sensu
    → [role vars] yamls/sensu-ansible/vars/FreeBSD.yml: /usr/local/etc/sensu  ← WINS
    → [role vars] yamls/sensu-ansible/vars/OpenBSD.yml: /etc/sensu  ← WINS
    → [role vars] yamls/sensu-ansible/vars/SmartOS.yml: /opt/local/etc/sensu  ← WINS

  sensu_rabbitmq_baseurl:
    → [role vars] yamls/sensu-ansible/vars/Amazon.yml: https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/{{ se...  ← WINS
    → [role vars] yamls/sensu-ansible/vars/CentOS.yml: https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/{{ se...  ← WINS
    → [role vars] yamls/sensu-ansible/vars/Fedora.yml: https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/{{ se...  ← WINS

  sensu_rabbitmq_config_path:
      [role default] yamls/sensu-ansible/defaults/main.yml: /etc/rabbitmq
    → [role vars] yamls/sensu-ansible/vars/FreeBSD.yml: /usr/local/etc/rabbitmq  ← WINS
    → [role vars] yamls/sensu-ansible/vars/OpenBSD.yml: /etc/rabbitmq  ← WINS
    → [role vars] yamls/sensu-ansible/vars/SmartOS.yml: /opt/local/etc/rabbitmq  ← WINS

  sensu_rabbitmq_erlang_baseurl:
    → [role vars] yamls/sensu-ansible/vars/Amazon.yml: https://dl.bintray.com/rabbitmq-erlang/rpm/erlang/{{ sens...  ← WINS
    → [role vars] yamls/sensu-ansible/vars/CentOS.yml: https://dl.bintray.com/rabbitmq-erlang/rpm/erlang/{{ sens...  ← WINS
    → [role vars] yamls/sensu-ansible/vars/Fedora.yml: https://dl.bintray.com/rabbitmq-erlang/rpm/erlang/{{ sens...  ← WINS

  sensu_rabbitmq_erlang_repo:
    → [role vars] yamls/sensu-ansible/vars/Debian.yml: deb https://packages.erlang-solutions.com/debian {{ ansib...  ← WINS
    → [role vars] yamls/sensu-ansible/vars/Ubuntu.yml: deb https://packages.erlang-solutions.com/ubuntu {{ ansib...  ← WINS

  sensu_rabbitmq_erlang_signing_key:
    → [role vars] yamls/sensu-ansible/vars/Amazon.yml: {{ sensu_rabbitmq_signing_key }}  ← WINS
    → [role vars] yamls/sensu-ansible/vars/CentOS.yml: {{ sensu_rabbitmq_signing_key }}  ← WINS
    → [role vars] yamls/sensu-ansible/vars/Debian.yml: https://packages.erlang-solutions.com/debian/erlang_solut...  ← WINS
    → [role vars] yamls/sensu-ansible/vars/Fedora.yml: {{ sensu_rabbitmq_signing_key }}  ← WINS
    → [role vars] yamls/sensu-ansible/vars/Ubuntu.yml: https://packages.erlang-solutions.com/debian/erlang_solut...  ← WINS

  sensu_rabbitmq_service_name:
      [role default] yamls/sensu-ansible/defaults/main.yml: rabbitmq-server
    → [role vars] yamls/sensu-ansible/vars/FreeBSD.yml: rabbitmq  ← WINS
    → [role vars] yamls/sensu-ansible/vars/OpenBSD.yml: rabbitmq  ← WINS
    → [role vars] yamls/sensu-ansible/vars/SmartOS.yml: rabbitmq  ← WINS

  sensu_redis_pkg_name:
      [role default] yamls/sensu-ansible/defaults/main.yml: redis
    → [role vars] yamls/sensu-ansible/vars/Debian.yml: redis-server  ← WINS
    → [role vars] yamls/sensu-ansible/vars/Ubuntu.yml: redis-server  ← WINS

  sensu_redis_service_name:
      [role default] yamls/sensu-ansible/defaults/main.yml: redis
    → [role vars] yamls/sensu-ansible/vars/Debian.yml: redis-server  ← WINS
    → [role vars] yamls/sensu-ansible/vars/Ubuntu.yml: redis-server  ← WINS

  sensu_yum_repo_url:
      [role default] yamls/sensu-ansible/defaults/main.yml: https://eol-repositories.sensuapp.org/yum/$releasever/$ba...
    → [role vars] yamls/sensu-ansible/vars/Amazon.yml: https://eol-repositories.sensuapp.org/yum/{{epel_version}...  ← WINS
    → [role vars] yamls/sensu-ansible/vars/Fedora.yml: https://eol-repositories.sensuapp.org/yum/7/$basearch/  ← WINS

  server_hostname:
    → [role vars] yamls/ansible-for-devops/https-nginx-proxy/provisioning/vars/main.yml: https-proxy.test  ← WINS
    → [role vars] yamls/ansible-for-devops/https-self-signed/provisioning/vars/main.yml: https.test  ← WINS

  service_name:
    → [play vars] yamls/kubespray/roles/container-engine/validate-container-engine/tasks/main.yml: containerd.service  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/validate-container-engine/tasks/main.yml: docker.service  ← WINS
    → [play vars] yamls/kubespray/roles/container-engine/validate-container-engine/tasks/main.yml: crio.service  ← WINS

  sources_dest:
      [role default] yamls/tools/docker-compose-minikube/minikube/defaults/main.yml: _sources
    → [host_vars] yamls/tools/docker-compose/ansible/host_vars/localhost.yml: ../_sources  ← WINS

  stdin:
    → [play vars] yamls/kubespray/roles/network_plugin/calico/tasks/peer_with_calico_rr.yml: {"apiVersion": "projectcalico.org/v3", "kind": "BGPPeer",...  ← WINS
    → [play vars] yamls/kubespray/roles/network_plugin/calico/tasks/peer_with_calico_rr.yml: {"apiVersion": "projectcalico.org/v3", "kind": "BGPPeer",...  ← WINS
    → [play vars] yamls/kubespray/roles/network_plugin/calico/tasks/peer_with_calico_rr.yml: {"apiVersion": "projectcalico.org/v3", "kind": "BGPPeer",...  ← WINS
    → [play vars] yamls/kubespray/roles/network_plugin/calico/tasks/peer_with_router.yml: {"apiVersion": "projectcalico.org/v3", "kind": "BGPPeer",...  ← WINS
    → [play vars] yamls/kubespray/roles/network_plugin/calico/tasks/peer_with_router.yml: {"apiVersion": "projectcalico.org/v3", "kind": "Node", "m...  ← WINS
    → [play vars] yamls/kubespray/roles/network_plugin/calico/tasks/peer_with_router.yml: {"apiVersion": "projectcalico.org/v3", "kind": "BGPPeer",...  ← WINS

  storage_classes:
    → [role default] yamls/kubespray/roles/kubernetes-apps/persistent_volumes/cinder-csi/defaults/main.yml: - name: cinder-csi
  is_default: false
  parameters:
    ...  ← WINS
    → [role default] yamls/kubespray/roles/kubernetes-apps/persistent_volumes/upcloud-csi/defaults/main.yml: - name: standard
  is_default: true
  expand_persistent_v...  ← WINS

  unsafe_show_logs:
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/download.yml: {{ lookup('env', 'CI_PROJECT_URL') == 'https://gitlab.com...
    → [group_vars] yamls/kubespray/inventory/sample/group_vars/all/all.yml: false  ← WINS

  youki_enabled:
      [role default] yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml: false
    → [play vars] yamls/kubespray/roles/container-engine/youki/molecule/default/converge.yml: true  ← WINS

⚠ SHADOWS (74 variables overridden by higher precedence):


⚠ UNDEFINED (872 variables referenced but never defined):
  {{ 0 }}
  {{ 10 }}
  {{ 110 }}
  {{ 143 }}
  {{ 2 }}
  {{ 20 }}
  {{ 30 }}
  {{ 5 }}
  {{ 59 }}
  {{ 60 }}
  {{ 636 }}
  {{ 65535 }}
  {{ 86400 }}
  {{ 993 }}
  {{ 995 }}
  {{ 9999999999999999999999999999999999999 }}
  {{ False }}
  {{ Initial_Root_Token }}
  {{ True }}
  {{ Unseal_Key_1 }}
  {{ Unseal_Key_2 }}
  {{ Unseal_Key_3 }}
  {{ __galaxy_client_build_version }}
  {{ __galaxy_client_build_version_result }}
  {{ __galaxy_current_commit_id }}
  {{ __galaxy_dir_perms }}
  {{ __galaxy_git_stat_result }}
  {{ __galaxy_git_update_result }}
  {{ __galaxy_major_version }}
  {{ __galaxy_node_version_file }}
  {{ __galaxy_passwd_result }}
  {{ __galaxy_privsep_user_group }}
  {{ __galaxy_themes_config_slurp }}
  {{ __galaxy_user_group }}
  {{ __molecule_dir_check }}
  {{ __molecule_git_check }}
  {{ _access_ips }}
  {{ _access_ipv4 }}
  {{ _access_ipv6 }}
  {{ _bgp_config }}
  {{ _bgp_config_cmd }}
  {{ _calico_pool }}
  {{ _calico_pool_cmd }}
  {{ _calico_pool_ipv6 }}
  {{ _calico_pool_ipv6_cmd }}
  {{ _editable_dependencies_links }}
  {{ _errors_from_first_try }}
  {{ _felix_cmd }}
  {{ _felix_config }}
  {{ _ips }}
  {{ _ipv4 }}
  {{ _ipv6 }}
  {{ _service_account_secret }}
  {{ _service_external_ips }}
  {{ _service_loadbalancer_ips }}
  {{ access_ip }}
  {{ access_ip6 }}
  {{ actual }}
  {{ additional_no_proxy }}
  {{ address }}
  {{ admin_input_plaintext_password }}
  {{ admin_kubeconfig }}
  {{ admin_password }}
  {{ admin_username }}
  {{ agents }}
  {{ alb_ingress_manifests }}
  {{ all_options }}
  {{ any_errors_fatal }}
  {{ apache__register_mods_available }}
  {{ apiserver_response }}
  {{ apiserver_sans }}
  {{ app_directory }}
  {{ app_environment }}
  {{ app_repository }}
  {{ app_user }}
  {{ app_version }}
  {{ application__deploy_state }}
  {{ application__elasticsearch__dependent_configuration }}
  {{ application__etc_aliases__dependent_recipients }}
  {{ application__kibana__dependent_configuration }}
  {{ application__nsswitch__dependent_services }}
  {{ application__postfix__dependent_maincf }}
  {{ application__postfix__dependent_mastercf }}
  {{ application__postfix__dependent_packages }}
  {{ application__rabbitmq_server__dependent_config }}
  {{ approval_node_name }}
  {{ argocd_admin_password }}
  {{ argocd_templates }}
  {{ authentication }}
  {{ aws_cred_name1 }}
  {{ aws_csi_manifests }}
  {{ aws_ebs_csi_plugin_digest_checksum }}
  {{ awx_license_type }}
  {{ awx_version }}
  {{ azure_csi_manifests }}
  {{ azure_resource_group }}
  {{ azure_route_table_name }}
  {{ azure_security_group_name }}
  {{ azure_storage_account_type }}
  {{ azure_subnet_admin_name }}
  {{ azure_subnet_masters_name }}
  {{ azure_subnet_minions_name }}
  {{ azure_virtual_network_name }}
  {{ azurerm_cred_name1 }}
  {{ base_dir }}
  {{ binary_item }}
  {{ bind__tmp_find_sig0_keys }}
  {{ bind__tmp_full_views }}
  {{ bind__tmp_keys }}
  {{ bind__tmp_sig0_fetch }}
  {{ bind__tmp_sig0_remove }}
  {{ bind__tmp_top_views }}
  {{ bind__tmp_top_zones }}
  {{ bind__views }}
  {{ body_info }}
  {{ brackets }}
  {{ bridge_if }}
  {{ btrfs__subvolumes_combined }}
  {{ build }}
  {{ bulk_inv_name }}
  {{ bulk_job_name }}
  {{ ca_cert_path }}
  {{ cache_image }}
  {{ calico }}
  {{ calico_apiserver_cabundle }}
  {{ calico_apiserver_digest_checksum }}
  {{ calico_apiserver_manifest }}
  {{ calico_cni_config_slurp }}
  {{ calico_cni_digest_checksum }}
  {{ calico_group_id }}
  {{ calico_ipv6 }}
  {{ calico_kube_manifests }}
  {{ calico_node_digest_checksum }}
  {{ calico_node_manifests }}
  {{ calico_node_typha_manifest }}
  {{ calico_policy_digest_checksum }}
  {{ calico_pool_cidr }}
  {{ calico_pool_cidr_ipv6 }}
  {{ calico_rr_id }}
  {{ calico_rr_node }}
  {{ calico_rr_node_patched }}
  {{ calico_typha_digest_checksum }}
  {{ calico_version_on_server }}
  {{ cert_manager_cainjector_digest_checksum }}
  {{ cert_manager_controller_digest_checksum }}
  {{ cert_manager_manifests }}
  {{ cert_manager_templates }}
  {{ cert_manager_webhook_digest_checksum }}
  {{ cfgdir }}
  {{ ci_inventory }}
  {{ cidrs }}
  {{ cilium_action }}
  {{ cilium_digest_checksum }}
  {{ cilium_hubble_certgen_digest_checksum }}
  {{ cilium_hubble_envoy_digest_checksum }}
  {{ cilium_hubble_event_buffer_capacity }}
  {{ cilium_hubble_relay_digest_checksum }}
  {{ cilium_hubble_ui_backend_digest_checksum }}
  {{ cilium_hubble_ui_digest_checksum }}
  {{ cilium_operator_digest_checksum }}
  {{ cinder_csi_manifests }}
  {{ cinder_csi_plugin_digest_checksum }}
  {{ client_id }}
  {{ client_secret }}
  {{ cluster }}
  {{ cluster_fips }}
  {{ cni_config }}
  {{ cni_config_slurp }}
  {{ command }}
  {{ conditional_dependencies }}
  {{ config_dir }}
  {{ connectivity_check }}
  {{ console__register_mount_points }}
  {{ console__register_nfs_mount_points }}
  {{ container_engine_accelerator_manifests }}
  {{ containerd_default_base_runtime_spec }}
  {{ context }}
  {{ controller_meta }}
  {{ coredns_digest_checksum }}
  {{ created_droplets }}
  {{ created_instances }}
  {{ created_org }}
  {{ cred }}
  {{ cred1 }}
  {{ cred1_result }}
  {{ cred2 }}
  {{ cred3 }}
  {{ cred_name }}
  {{ cred_name1 }}
  {{ cred_result }}
  {{ cred_type_name }}
  {{ cri_completion }}
  {{ crio_cgroup_driver_result }}
  {{ crio_download_base }}
  {{ crio_download_crio }}
  {{ crio_kubic_debian_repo_name }}
  {{ crio_latest }}
  {{ cryptsetup__register_ciphertext_blkid }}
  {{ cryptsetup__register_ciphertext_device }}
  {{ cryptsetup__register_cryptdisks_start }}
  {{ cryptsetup__register_keyfile_gen }}
  {{ cryptsetup__register_plaintext_device }}
  {{ cryptsetup__register_stat_remote_keyfile }}
  {{ cryptsetup__register_swap_fstab }}
  {{ csi_attacher_digest_checksum }}
  {{ csi_crd_manifests }}
  {{ csi_livenessprobe_digest_checksum }}
  {{ csi_node_driver_registrar_digest_checksum }}
  {{ csi_provisioner_digest_checksum }}
  {{ csi_resizer_digest_checksum }}
  {{ csi_snapshotter_digest_checksum }}
  {{ csr_json }}
  {{ ctr_oci_spec }}
  {{ current_db_version }}
  {{ current_user }}
  {{ custom_credential_via_token }}
  {{ custom_credential_via_userpass }}
  {{ custom_vault_cred_type }}
  {{ debconf__fact_reconfigure_packages }}
  {{ debian_repo }}
  {{ debops_6to4_iface }}
  {{ debops_6to4_ipv4_interface }}
  {{ debops__no_log }}
  {{ default_searchdomains }}
  {{ delegate_host_base_dir }}
  {{ delegate_host_to_write_cacert }}
  {{ delete_broken_kube_control_plane_nodes }}
  {{ delete_old_cerificates }}
  {{ demo_project_name }}
  {{ demo_project_name_2 }}
  {{ dhclientconffile }}
  {{ dhclienthookfile }}
  {{ dir }}
  {{ dist_upgrade_register_apt_sources }}
  {{ dns_attempts }}
  {{ dns_timeout }}
  {{ dnsautoscaler_digest_checksum }}
  {{ dnsmasq__env_tcpwrappers__dependent_allow }}
  {{ do }}
  {{ docker_cgroup_driver_result }}
  {{ docker_dns_servers }}
  {{ docker_packages_list }}
  {{ docker_password }}
  {{ docker_plugin }}
  {{ docker_repo_key_keyring }}
  {{ domain }}
  {{ dotfile }}
  {{ download_dir }}
  {{ drupal_core_path }}
  {{ drupal_core_version }}
  {{ drupal_site_name }}
  {{ ec2 }}
  {{ ec2_access_key }}
  {{ ec2_id }}
  {{ ec2_image }}
  {{ ec2_instance_count }}
  {{ ec2_instance_type }}
  {{ ec2_keypair }}
  {{ ec2_region }}
  {{ ec2_secret_key }}
  {{ ec2_security_group }}
  {{ ec2_tag_dbservers }}
  {{ ec2_tag_lbservers }}
  {{ ec2_tag_monitoring }}
  {{ ec2_tag_webservers }}
  {{ ee1 }}
  {{ ee_name }}
  {{ elasticsearch__register_builtin_password }}
  {{ elasticsearch__register_builtin_users }}
  {{ elasticsearch__secret__directories }}
  {{ element }}
  {{ email_not }}
  {{ enable_dual_stack_networks }}
  {{ end }}
  {{ end_point_options }}
  {{ endpoints }}
  {{ entry }}
  {{ etc_aliases__secret__directories }}
  {{ etc_services_dependency_list }}
  {{ etc_services_dependent_list }}
  {{ etc_services_group_list }}
  {{ etc_services_host_list }}
  {{ etc_services_list }}
  {{ etcd_backup_directory }}
  {{ etcd_client_cert_serial_result }}
  {{ etcd_cluster_is_healthy }}
  {{ etcd_current_version }}
  {{ etcd_endpoint_health }}
  {{ etcd_events_cluster_is_healthy }}
  {{ etcd_image_dict }}
  {{ etcd_master_certs }}
  {{ etcd_master_node_certs }}
  {{ etcd_metrics_port }}
  {{ etcd_node_certs }}
  {{ etcd_servers }}
  {{ etcd_snapshot }}
  {{ etckeeper__repository_group }}
  {{ etckeeper__repository_permissions }}
  {{ etherpad_database_collate }}
  {{ etherpad_database_ctype }}
  {{ etherpad_database_encoding }}
  {{ execution_node_count }}
  {{ existing_logging }}
  {{ ext }}
  {{ external_hcloud_manifests }}
  {{ external_huaweicloud_cacert }}
  {{ external_huaweicloud_manifests }}
  {{ external_openstack_lbaas_subnet_id }}
  {{ external_openstack_manifests }}
  {{ external_oracle_manifests }}
  {{ external_vsphere_configmap_manifest }}
  {{ external_vsphere_manifests }}
  {{ facter_fqdn }}
  {{ facter_operatingsystem }}
  {{ false }}
  {{ ferm__register_rules_removed }}
  {{ file_dir_line }}
  {{ file_path_cached }}
  {{ files_repo }}
  {{ firejail__register_profile_program_symlinks_find }}
  {{ firejail__register_profile_program_symlinks_stat }}
  {{ flannel_digest_checksum }}
  {{ flannel_init_digest_checksum }}
  {{ flannel_node_manifests }}
  {{ foo }}
  {{ fromJSON }}
  {{ galaxy_cache_dir }}
  {{ galaxy_changeset_id }}
  {{ galaxy_config_dir }}
  {{ galaxy_container_resolvers }}
  {{ galaxy_dependency_resolvers }}
  {{ galaxy_errordocs_dest }}
  {{ galaxy_errordocs_maint_file }}
  {{ galaxy_file_path }}
  {{ galaxy_git_repo }}
  {{ galaxy_job_metrics_plugins }}
  {{ galaxy_job_working_directory }}
  {{ galaxy_local_tools }}
  {{ galaxy_local_tools_dir }}
  {{ galaxy_mutable_config_dir }}
  {{ galaxy_mutable_data_dir }}
  {{ galaxy_node_version }}
  {{ galaxy_pip_version }}
  {{ galaxy_server_dir }}
  {{ galaxy_shed_tools_dir }}
  {{ galaxy_themes }}
  {{ galaxy_tool_data_path }}
  {{ galaxy_tool_dependency_dir }}
  {{ galaxy_venv_dir }}
  {{ galaxy_virtualenv_command }}
  {{ galaxy_virtualenv_python }}
  {{ gce_cred_name1 }}
  {{ gcp_pd_csi_manifests }}
  {{ gcp_pd_csi_sa_cred_file }}
  {{ get_archive }}
  {{ get_csr }}
  {{ getent_passwd }}
  {{ git_executable }}
  {{ git_item }}
  {{ git_result }}
  {{ github }}
  {{ github_token }}
  {{ github_webhook_credential_name }}
  {{ gitlab_runner__register_known_hosts }}
  {{ gitlab_runner__register_libvirt_source }}
  {{ gitlab_runner__register_ssh_key }}
  {{ gluster_brick_dir }}
  {{ gluster_brick_name }}
  {{ gluster_mount_dir }}
  {{ gpg_pubkey }}
  {{ group_name }}
  {{ group_name1 }}
  {{ group_name2 }}
  {{ group_name3 }}
  {{ grub__register_pw_hashes }}
  {{ grub__register_pw_plain }}
  {{ gvisor_manifests }}
  {{ gvisor_templates }}
  {{ haproxy_digest_checksum }}
  {{ hashicorp__register_unpack }}
  {{ helm_completion }}
  {{ homeassistant__register_systemd_unit_file }}
  {{ host }}
  {{ host1 }}
  {{ host_id_list }}
  {{ host_ip }}
  {{ host_name }}
  {{ host_name1 }}
  {{ host_name2 }}
  {{ host_name3 }}
  {{ host_name4 }}
  {{ hostname1 }}
  {{ hostname2 }}
  {{ hostname3 }}
  {{ hosts }}
  {{ hosts_created }}
  {{ http_proxy }}
  {{ httpd_port }}
  {{ https_port }}
  {{ https_proxy }}
  {{ hwraid_register_release }}
  {{ icinga__secret__directories }}
  {{ ifupdown__env_ferm__dependent_rules }}
  {{ ifupdown__env_kmod__dependent_load }}
  {{ ifupdown__env_sysctl__dependent_parameters }}
  {{ ifupdown__register_interfaces_created }}
  {{ ifupdown__register_interfaces_removed }}
  {{ ig1 }}
  {{ ig2 }}
  {{ image_filename }}
  {{ image_load_command }}
  {{ image_path_cached }}
  {{ image_path_final }}
  {{ image_reponame }}
  {{ image_save_command_on_localhost }}
  {{ included_tasks_file }}
  {{ ingress_alb_controller_digest_checksum }}
  {{ inputs }}
  {{ insights_cred_name1 }}
  {{ insights_cred_name2 }}
  {{ insights_url }}
  {{ inspec_download }}
  {{ instance }}
  {{ inv }}
  {{ inv1 }}
  {{ inv_name }}
  {{ inv_name1 }}
  {{ inv_name2 }}
  {{ inv_result }}
  {{ inv_source1 }}
  {{ inv_source2 }}
  {{ inv_source3 }}
  {{ inventory__environment }}
  {{ inventory__group_environment }}
  {{ inventory__host_environment }}
  {{ inventory_dir }}
  {{ inventory_hostname_short }}
  {{ inventory_id }}
  {{ inventory_name1 }}
  {{ inventory_node_labels }}
  {{ inventory_node_taints }}
  {{ inventory_result }}
  {{ ip }}
  {{ ip6 }}
  {{ ip_address }}
  {{ ipxe__register_debian_installer }}
  {{ irc_not }}
  {{ iscsi__register_targets }}
  {{ item_git }}
  {{ job }}
  {{ job_template }}
  {{ journald__register_fss }}
  {{ jquery_directory }}
  {{ jt }}
  {{ jt1 }}
  {{ jt1_name }}
  {{ jt1_result }}
  {{ jt2 }}
  {{ jt2_name }}
  {{ jt_name }}
  {{ jt_name1 }}
  {{ jt_name2 }}
  {{ jt_result }}
  {{ junk_var }}
  {{ k8s_certs_units }}
  {{ kata_containers_manifests }}
  {{ kata_containers_templates }}
  {{ key }}
  {{ kibana__secret__directories }}
  {{ kube_encrypt_token_extracted }}
  {{ kube_oidc_ca_cert }}
  {{ kube_oidc_ca_file }}
  {{ kube_ovn_digest_checksum }}
  {{ kube_ovn_node_manifests }}
  {{ kube_proxy_nodeport_addresses_cidr }}
  {{ kube_router_digest_checksum }}
  {{ kube_vip_digest_checksum }}
  {{ kubeadm_admin_kubeconfig }}
  {{ kubeadm_already_run }}
  {{ kubeadm_discovery_address }}
  {{ kubeadm_images_cooked }}
  {{ kubeadm_images_raw }}
  {{ kubeadm_token }}
  {{ kubeadm_upload_cert }}
  {{ kubeconfig_file_discovery }}
  {{ kubectl_alias }}
  {{ kubeletConfig_api_version }}
  {{ kubelet_cgroup_driver }}
  {{ kubelet_cgroup_driver_detected }}
  {{ l_additional_trust_bundle }}
  {{ l_cluster_version }}
  {{ l_kubernetes_server_version }}
  {{ l_mcd_image }}
  {{ l_release_image }}
  {{ l_worker_machine_config_name }}
  {{ lab1 }}
  {{ label1 }}
  {{ label2 }}
  {{ label_name }}
  {{ layer2_rendering }}
  {{ layer3_rendering }}
  {{ lb_pubip_cmd }}
  {{ ldap__fact_admin_bindpw }}
  {{ letsencrypt_email }}
  {{ light_info }}
  {{ line }}
  {{ listener_port }}
  {{ listener_protocol }}
  {{ loadbalancer_apiserver }}
  {{ local_as }}
  {{ local_path }}
  {{ local_path_provisioner_digest_checksum }}
  {{ local_path_provisioner_manifests }}
  {{ local_path_provisioner_templates }}
  {{ local_volume_provisioner_base_dir }}
  {{ local_volume_provisioner_digest_checksum }}
  {{ local_volume_provisioner_manifests }}
  {{ local_volume_provisioner_mount_dir }}
  {{ local_volume_provisioner_storage_class }}
  {{ local_volume_provisioner_templates }}
  {{ locations }}
  {{ logrotate__register_cron_diversion }}
  {{ lookup }}
  {{ machine__register_motd_scripts_removed }}
  {{ main_access_ip }}
  {{ main_ip }}
  {{ main_ips }}
  {{ main_user_name }}
  {{ mariadb__register_create_users }}
  {{ mariadb__register_database_status }}
  {{ master_debug_level }}
  {{ matrix }}
  {{ max_db_version }}
  {{ mcd_command }}
  {{ mcli__env_upstream_url_release }}
  {{ member_list }}
  {{ metallb_controller_digest_checksum }}
  {{ metallb_rendering }}
  {{ metallb_speaker_digest_checksum }}
  {{ metrics_server_digest_checksum }}
  {{ metrics_server_manifests }}
  {{ metrics_server_templates }}
  {{ minio__env_etc_services_dependent_list }}
  {{ minio__env_ferm_dependent_rules }}
  {{ minio__env_nginx_dependent_servers }}
  {{ minio__env_nginx_dependent_upstreams }}
  {{ minio__env_upstream_url_release }}
  {{ minio__register_instance_config }}
  {{ module }}
  {{ molecule_ephemeral_directory }}
  {{ molecule_scenario_directory }}
  {{ molecule_yml }}
  {{ mongo_admin_pass }}
  {{ mongoc_port }}
  {{ mongod_port }}
  {{ mongodb_datadir_prefix }}
  {{ mongos_port }}
  {{ mosquitto__register_version }}
  {{ mosquitto__register_websockets }}
  {{ mount__register_devices }}
  {{ mounted_dirs }}
  {{ multus_digest_checksum }}
  {{ my_etcd_node_certs }}
  {{ my_password2 }}
  {{ mysql_port }}
  {{ nerdctl_completion }}
  {{ net_cred_name1 }}
  {{ netcheck_agent_digest_checksum }}
  {{ netcheck_server_digest_checksum }}
  {{ new_logging }}
  {{ nfs__register_devices }}
  {{ nginx__register_check_mode }}
  {{ nginx_digest_checksum }}
  {{ nginx_port }}
  {{ nginx_register_default_server_saved }}
  {{ nginx_register_default_server_ssl_saved }}
  {{ nginx_register_nameservers }}
  {{ nginx_register_passenger_root }}
  {{ nginx_register_passenger_ruby }}
  {{ no_proxy }}
  {{ node }}
  {{ nodeToNodeMeshEnabled }}
  {{ node_debug_level }}
  {{ node_default_gateway_interface_cmd }}
  {{ node_feature_discovery_manifests }}
  {{ node_feature_discovery_templates }}
  {{ node_labels }}
  {{ node_pod_cidr_cmd }}
  {{ nodelocaldns_digest_checksum }}
  {{ not }}
  {{ ntp_config_file }}
  {{ ntp_service_name }}
  {{ oc_get }}
  {{ oc_get_additional_trust_bundle }}
  {{ oc_get_http_proxy }}
  {{ oc_get_https_proxy }}
  {{ oc_get_no_proxy }}
  {{ opendkim__secret__directories }}
  {{ openshift_kubeconfig_path }}
  {{ openshift_node_post_upgrade_hook }}
  {{ openshift_node_pre_cordon_hook }}
  {{ openshift_node_pre_uncordon_hook }}
  {{ openshift_node_pre_upgrade_hook }}
  {{ openstack_cred_name1 }}
  {{ openvpn_client_certificates }}
  {{ openvpn_client_keys }}
  {{ org2_name }}
  {{ org_name }}
  {{ org_name1 }}
  {{ org_name2 }}
  {{ os_release }}
  {{ ostree }}
  {{ owncloud__apps_item }}
  {{ owncloud__apps_setting_item }}
  {{ owncloud__files_scan_item }}
  {{ owncloud__occ_item }}
  {{ owncloud__occ_run }}
  {{ owncloud__occ_run_output }}
  {{ owncloud__theme_copy_files_combined }}
  {{ param1 }}
  {{ param2 }}
  {{ patch_kube_proxy_state }}
  {{ pd_not }}
  {{ peer }}
  {{ peers }}
  {{ person }}
  {{ person_plaintext_password }}
  {{ person_uid }}
  {{ pgbadger__register_ssh_keyscan }}
  {{ pgbadger__register_ssh_public_key }}
  {{ php__etc_base }}
  {{ php__logrotate_lib_base }}
  {{ php__version }}
  {{ phpmyadmin_pod }}
  {{ pip_extra_args }}
  {{ pkgs_lists }}
  {{ pki_env_secret_directories }}
  {{ pki_fact_lib_path }}
  {{ pki_fact_session_token }}
  {{ platforms }}
  {{ pod_infra_digest_checksum }}
  {{ podman_flags }}
  {{ podman_mounts }}
  {{ pools_rendering }}
  {{ post_upgrade_hooks }}
  {{ postconf__env_capabilities }}
  {{ postfix__secret__directories }}
  {{ postgresql_server__register_createcluster }}
  {{ postgresql_server__tpl_ports }}
  {{ postgresql_server__version }}
  {{ previous_archive }}
  {{ prod_level }}
  {{ proj }}
  {{ proj1 }}
  {{ proj2 }}
  {{ proj_name }}
  {{ proj_result }}
  {{ project_create_result }}
  {{ project_info }}
  {{ project_inv }}
  {{ project_inv_source }}
  {{ project_inv_source_result }}
  {{ project_name }}
  {{ project_name1 }}
  {{ project_name2 }}
  {{ project_name3 }}
  {{ project_path }}
  {{ projects_root }}
  {{ public_hosted_zone }}
  {{ pull_required }}
  {{ pvs }}
  {{ q }}
  {{ query }}
  {{ rabbitmq_server__secret__directories }}
  {{ radius_access_point_password }}
  {{ radius_access_point_subnet }}
  {{ radius_ca_file }}
  {{ radius_cert_file }}
  {{ radius_domain }}
  {{ radius_guest_vlan }}
  {{ radius_key_file }}
  {{ radius_local_vlan }}
  {{ radius_pki_realm }}
  {{ radius_test_user_identity }}
  {{ radius_test_user_password }}
  {{ rails_deploy_key_data }}
  {{ rails_deploy_mysql_user_password }}
  {{ rails_deploy_register_deploy_key }}
  {{ range }}
  {{ receptor_group }}
  {{ receptor_user }}
  {{ record }}
  {{ redis_sentinel__env_ports }}
  {{ redis_server__env_ports }}
  {{ redis_server__register_config_dynamic }}
  {{ redis_server__register_config_static }}
  {{ registries_conf }}
  {{ registry_digest_checksum }}
  {{ registry_host }}
  {{ registry_manifests }}
  {{ registry_templates }}
  {{ release_image_mcd }}
  {{ release_version }}
  {{ releases }}
  {{ rendered_worker }}
  {{ repo }}
  {{ repositories }}
  {{ repository }}
  {{ reprepro__env_nginx_servers }}
  {{ req_file }}
  {{ resolvconffile }}
  {{ result }}
  {{ results }}
  {{ reversed }}
  {{ rh_subscription_activation_key }}
  {{ rh_subscription_org_id }}
  {{ rh_subscription_password }}
  {{ rh_subscription_role }}
  {{ rh_subscription_sla }}
  {{ rh_subscription_usage }}
  {{ rh_subscription_username }}
  {{ rhv_cred_name1 }}
  {{ role_node_labels }}
  {{ role_node_taints }}
  {{ rolename }}
  {{ roundcube__fact_skin_elastic_css_files }}
  {{ rsnapshot__register_known_hosts }}
  {{ rsnapshot__register_ssh_keys }}
  {{ rspamd__dkim_local_keyfile }}
  {{ rspamd__found_snippets }}
  {{ run_pods_log }}
  {{ sat6_cred_name1 }}
  {{ sched1 }}
  {{ sched2 }}
  {{ scheduler_plugins_manifests }}
  {{ scm_accept_hostkey }}
  {{ scm_branch }}
  {{ scm_clean }}
  {{ scm_cred_name }}
  {{ scm_cred_name1 }}
  {{ scm_password }}
  {{ scm_refspec }}
  {{ scm_track_submodules }}
  {{ scm_url }}
  {{ scm_username }}
  {{ scm_version }}
  {{ secret_file_decoded }}
  {{ secret_file_encoded }}
  {{ secret_key }}
  {{ secrets }}
  {{ sensu_gem_repository }}
  {{ serial }}
  {{ server }}
  {{ service_status }}
  {{ slack_not }}
  {{ slice_inventory }}
  {{ slice_num }}
  {{ snapshot_controller_digest_checksum }}
  {{ snapshot_controller_manifests }}
  {{ snapshot_snapper__register_snapper_configs }}
  {{ snapshot_snapper__register_snapshot_directory }}
  {{ snapshot_snapper__templates_combined }}
  {{ snapshot_snapper__volume }}
  {{ snapshot_snapper__volumes_combined }}
  {{ snmpd_account_local_password }}
  {{ snmpd_account_local_username }}
  {{ snmpd_fact_account_admin_password }}
  {{ snmpd_fact_account_admin_username }}
  {{ snmpd_fact_account_agent_password }}
  {{ snmpd_fact_account_agent_username }}
  {{ solr_checksum }}
  {{ solr_dir }}
  {{ solr_version }}
  {{ some_var1 }}
  {{ sonobuoy_arch }}
  {{ sonobuoy_mode }}
  {{ sonobuoy_parallel }}
  {{ sonobuoy_path }}
  {{ sonobuoy_retrieve }}
  {{ sonobuoy_version }}
  {{ src_cred_name }}
  {{ src_cred_result }}
  {{ ssh_cred_name }}
  {{ ssh_cred_name1 }}
  {{ ssh_cred_name2 }}
  {{ ssh_cred_name3 }}
  {{ ssh_cred_name4 }}
  {{ ssh_key }}
  {{ ssh_key_data }}
  {{ sshd__env_register_host_public_keys }}
  {{ sshd__register_known_hosts }}
  {{ stack }}
  {{ steps }}
  {{ subdomain }}
  {{ suffix }}
  {{ svn_result }}
  {{ swapfile__register_allocation }}
  {{ swapfile__sysctl_file }}
  {{ sysctl_file_stat }}
  {{ sysfs__secret__directories }}
  {{ system_users__fact_self_comment }}
  {{ target_cred_name }}
  {{ target_cred_result }}
  {{ tarsnap_sha }}
  {{ team2_name }}
  {{ team_name }}
  {{ telegraf__register_existing_plugins_filenames }}
  {{ temp_dir }}
  {{ temp_token }}
  {{ tempdir }}
  {{ test_files }}
  {{ test_id }}
  {{ test_id1 }}
  {{ test_image_repo }}
  {{ test_image_tag }}
  {{ test_name }}
  {{ test_results }}
  {{ tinc__env_etc_services__dependent_list }}
  {{ tinc__env_ferm__dependent_rules }}
  {{ tinc__env_secret__directories }}
  {{ tor__base_packages }}
  {{ tower_cred_name1 }}
  {{ tower_user_name }}
  {{ true }}
  {{ twillo_not }}
  {{ ubuntu_repo }}
  {{ unattended_upgrades_file_stat }}
  {{ undef }}
  {{ upassword }}
  {{ upcloud_csi_manifests }}
  {{ url_item }}
  {{ user_can_become_root }}
  {{ username }}
  {{ username_info }}
  {{ usernames }}
  {{ users }}
  {{ val }}
  {{ var_lib_kubelet_files_dirs_w_attrs }}
  {{ vault_addr }}
  {{ vault_addr_from_container }}
  {{ vault_addr_from_host }}
  {{ vault_cred }}
  {{ vault_cred_name1 }}
  {{ vault_cred_name2 }}
  {{ vault_initialization }}
  {{ vault_userpass_cred }}
  {{ verbosity }}
  {{ version }}
  {{ vm_ip_list_cmd }}
  {{ vm_list_cmd }}
  {{ vmis }}
  {{ vmware_cred_name1 }}
  {{ vsphere_csi_manifests }}
  {{ vsphere_csi_secret_manifest }}
  {{ wait_results }}
  {{ webapp_version }}
  {{ webhook_not }}
  {{ webhook_notification }}
  {{ webhook_wfjt_name }}
  {{ wfjt_info }}
  {{ wfjt_name }}
  {{ wfjt_name1 }}
  {{ wfjt_name2 }}
  {{ wildcard_zone }}
  {{ workflow }}
  {{ workflow_job }}
  {{ wp_db_name }}
  {{ wp_db_password }}
  {{ wp_db_user }}
  {{ wp_sha256sum }}
  {{ wp_version }}
  {{ yum_repo }}

⚠ UNUSED (4677 variables defined but never referenced in {{ }}):
  __bash_path  (yamls/sensu-ansible/defaults/main.yml)
  __galaxy_cache_dir  (yamls/ansible-galaxy/vars/layout-custom.yml)
  __galaxy_config_dir  (yamls/ansible-galaxy/vars/layout-legacy-improved.yml)
  __galaxy_default_become_users  (yamls/ansible-galaxy/defaults/main.yml)
  __galaxy_default_nonroot_become_users  (yamls/ansible-galaxy/defaults/main.yml)
  __galaxy_file_path  (yamls/ansible-galaxy/vars/layout-custom.yml)
  __galaxy_gravity_pm  (yamls/ansible-galaxy/defaults/main.yml)
  __galaxy_job_working_directory  (yamls/ansible-galaxy/vars/layout-custom.yml)
  __galaxy_local_tools_dir  (yamls/ansible-galaxy/vars/layout-custom.yml)
  __galaxy_mutable_config_dir  (yamls/ansible-galaxy/vars/layout-custom.yml)
  __galaxy_mutable_data_dir  (yamls/ansible-galaxy/vars/layout-legacy-improved.yml)
  __galaxy_node_version_max  (yamls/ansible-galaxy/defaults/main.yml)
  __galaxy_privsep_user  (yamls/ansible-galaxy/defaults/main.yml)
  __galaxy_server_dir  (yamls/ansible-galaxy/vars/layout-opt.yml)
  __galaxy_shed_tools_dir  (yamls/ansible-galaxy/vars/layout-custom.yml)
  __galaxy_systemd_memory_limit_merged  (yamls/ansible-galaxy/defaults/main.yml)
  __galaxy_tool_data_path  (yamls/ansible-galaxy/vars/layout-custom.yml)
  __galaxy_tool_dependency_dir  (yamls/ansible-galaxy/vars/layout-custom.yml)
  __galaxy_venv_dir  (yamls/ansible-galaxy/vars/layout-legacy-improved.yml)
  __galaxy_version  (yamls/ansible-galaxy/molecule/default/converge.yml)
  _groups  (yamls/kubespray/tests/cloud_playbooks/roles/packet-ci/tasks/main.yml)
  _nameserverentries  (yamls/kubespray/roles/kubernetes/preinstall/vars/main.yml)
  _values  (yamls/kubespray/scripts/assert-sorted-checksums.yml)
  a_list  (yamls/ansible-examples/language_features/upgraded_vars.yml)
  additional_galaxy_env  (yamls/awx/playbooks/project_update.yml)
  adduser  (yamls/kubespray/roles/adduser/defaults/main.yml)
  agents_check_result  (yamls/kubespray/tests/testcases/040_check-network-adv.yml)
  alb_ingress_aws_debug  (yamls/kubespray/roles/kubernetes-apps/ingress_controller/alb_ingress_controller/defaults/main.yml)
  alb_ingress_aws_region  (yamls/kubespray/roles/kubernetes-apps/ingress_controller/alb_ingress_controller/defaults/main.yml)
  aliases  (yamls/awx_collection/tools/vars/aliases.yml)
  allow_ungraceful_removal  (yamls/kubespray/roles/remove_node/pre_remove/defaults/main.yml)
  allow_unsupported_distribution_setup  (yamls/kubespray/inventory/sample/group_vars/all/all.yml)
  alpha  (yamls/ansible-examples/language_features/vars/external_vars.yml)
  ansible__base_packages  (yamls/debops/ansible/roles/ansible/defaults/main.yml)
  ansible__deploy_type  (yamls/debops/ansible/roles/ansible/defaults/main.yml)
  ansible__packages  (yamls/debops/ansible/roles/ansible/defaults/main.yml)
  ansible_become  (yamls/openshift-ansible/inventory/dynamic/aws/group_vars/all/00_defaults.yml)
  ansible_install_method  (yamls/ansible-for-devops/jenkins/provision.yml)
  ansible_ssh_common_args  (yamls/kubespray/roles/kubespray_defaults/defaults/main/main.yml)
  ansible_ssh_pipelining  (yamls/kubespray/extra_playbooks/upgrade-only-k8s.yml)
  ansible_ssh_port  (yamls/ansible-examples/windows/wamp_haproxy/rolling_update.yml)
  ansible_ssh_retries  (yamls/kubespray/roles/etcd/tasks/gen_nodes_certs_script.yml)
  apache__access_log_format  (yamls/debops/ansible/roles/apache/defaults/main.yml)
  apache__base_packages  (yamls/debops/ansible/roles/apache/defaults/main.yml)
  apache__combined_directory_match  (yamls/debops/ansible/roles/apache/defaults/main.yml)
  apache__combined_vhosts  (yamls/debops/ansible/roles/apache/defaults/main.yml)
  apache__config_min_version  (yamls/debops/ansible/roles/apache/defaults/main.yml)
  apache__config_use_if_version  (yamls/debops/ansible/roles/apache/defaults/main.yml)
  apache__dependent_packages  (yamls/debops/ansible/roles/apache/defaults/main.yml)
  apache__dependent_vhosts  (yamls/debops/ansible/roles/apache/defaults/main.yml)
  ... and 4627 more

═══════════════════════════════════════════════════════════
  SUMMARY
═══════════════════════════════════════════════════════════
  Total variables defined:  8355
  Referenced in {{ }}:       4599
  Collisions:               126
  Shadows:                  74
  Unused:                   4677 (55%)
  Undefined references:     872
═══════════════════════════════════════════════════════════
