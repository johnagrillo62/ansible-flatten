(playbook "ansible-galaxy/molecule/prebuilt_client/converge.yml"
    (play
    (name "Converge")
    (hosts "all")
    (vars
      (galaxy_client_use_prebuilt "true")
      (__galaxy_version (jinja "{{ lookup('env', 'GALAXY_VERSION') }}"))
      (galaxy_create_user "yes")
      (galaxy_manage_paths "yes")
      (galaxy_manage_clone "yes")
      (galaxy_manage_download "no")
      (galaxy_manage_existing "no")
      (galaxy_manage_systemd "yes")
      (galaxy_manage_gravity (jinja "{{ false if __galaxy_major_version is version('22.01', '<') else true }}"))
      (galaxy_systemd_mode (jinja "{{ 'mule' if __galaxy_major_version is version('22.01', '<') else 'gravity' }}"))
      (galaxy_config_style "yaml")
      (galaxy_layout "root-dir")
      (galaxy_root "/srv/galaxy")
      (galaxy_separate_privileges "yes")
      (galaxy_user "galaxy")
      (galaxy_group "galaxy")
      (galaxy_privsep_user "gxpriv")
      (galaxy_clone_depth "1")
      (galaxy_config 
        (galaxy 
          (database_connection "sqlite:///" (jinja "{{ galaxy_mutable_data_dir }}") "/universe.sqlite")
          (conda_auto_init "false")))
      (pip_virtualenv_command "/usr/bin/python3 -m venv"))
    (pre_tasks
      (task
        (include_tasks "../_common/_inc_pre_tasks.yml")))
    (roles
      
        (role "galaxyproject.galaxy"))))
