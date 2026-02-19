(playbook "kubespray/roles/container-engine/cri-o/vars/v1.29.yml"
  (crio_conmon (jinja "{{ bin_dir }}") "/crio-conmon")
  (crio_runtime_bin_dir (jinja "{{ bin_dir }}"))
  (crio_bin_files (list
      "crio-conmon"
      "crio-conmonrs"
      "crio-crun"
      "crio-runc"
      "crio"
      "pinns"))
  (crio_status_command "crio status"))
