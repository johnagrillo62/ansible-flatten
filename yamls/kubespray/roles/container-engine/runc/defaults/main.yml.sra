(playbook "kubespray/roles/container-engine/runc/defaults/main.yml"
  (runc_bin_dir (jinja "{{ bin_dir }}"))
  (runc_package_name "runc"))
