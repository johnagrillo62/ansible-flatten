(playbook "kubespray/roles/system_packages/defaults/main.yml"
  (pkg_install_retries "4")
  (pkg_install_timeout (jinja "{{ 5 * 60 }}"))
  (yum_repo_dir "/etc/yum.repos.d"))
