(playbook "kubespray/roles/container-engine/cri-o/vars/v1.31.yml"
  (crio_conmon (jinja "{{ crio_libexec_dir }}") "/conmon")
  (crio_runtime_bin_dir (jinja "{{ crio_libexec_dir }}"))
  (crio_bin_files (list
      "crio"
      "pinns"))
  (crio_libexec_files (list
      "conmon"
      "conmonrs"
      "crun"
      "runc"))
  (crio_status_command "crio status"))
