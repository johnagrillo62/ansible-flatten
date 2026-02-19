(playbook "kubespray/roles/container-engine/youki/defaults/main.yml"
  (youki_bin_dir (jinja "{{ bin_dir }}")))
