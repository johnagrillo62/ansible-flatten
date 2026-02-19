(playbook "ansible-galaxy/defaults/main.yml"
  (galaxy_create_user "no")
  (galaxy_manage_paths "no")
  (galaxy_manage_clone "yes")
  (galaxy_manage_download "no")
  (galaxy_manage_existing "no")
  (galaxy_manage_static_setup "yes")
  (galaxy_manage_mutable_setup "yes")
  (galaxy_manage_database "yes")
  (galaxy_fetch_dependencies "yes")
  (galaxy_build_client "yes")
  (galaxy_manage_errordocs "no")
  (galaxy_backup_configfiles "yes")
  (galaxy_manage_gravity (jinja "{{ false if __galaxy_major_version is version('22.05', '<') else true }}"))
  (galaxy_manage_systemd "no")
  (galaxy_manage_systemd_reports "no")
  (galaxy_manage_cleanup "no")
  (galaxy_manage_themes (jinja "{{ galaxy_manage_static_setup and (galaxy_themes is defined or galaxy_themes_subdomains | length > 0) }}"))
  (galaxy_manage_subdomain_static "no")
  (galaxy_manage_host_filters "no")
  (galaxy_auto_brand "no")
  (galaxy_diff_mode_verbose (jinja "{{ ansible_diff_mode }}"))
  (__galaxy_privsep_user (jinja "{{ galaxy_privsep_user if galaxy_separate_privileges else galaxy_user }}"))
  (__galaxy_default_root_become_users 
    (galaxy (jinja "{{ __galaxy_user_name }}"))
    (privsep (jinja "{{ __galaxy_privsep_user_name }}")))
  (__galaxy_default_nonroot_become_users 
    (root "root")
    (galaxy (jinja "{{ __galaxy_user_name }}"))
    (privsep (jinja "{{ __galaxy_privsep_user_name }}")))
  (__galaxy_default_become_users (jinja "{{ __galaxy_default_root_become_users if ansible_user_uid == 0 else __galaxy_default_nonroot_become_users }}"))
  (galaxy_become_users (jinja "{{ {} if ansible_user_id == __galaxy_user_name and not galaxy_separate_privileges else __galaxy_default_become_users }}"))
  (galaxy_remote_users )
  (galaxy_separate_privileges "no")
  (galaxy_user (jinja "{{ ansible_user_id }}"))
  (galaxy_privsep_user "root")
  (__galaxy_user_name (jinja "{{ galaxy_user.name | default(galaxy_user) }}"))
  (__galaxy_privsep_user_name (jinja "{{ galaxy_privsep_user.name | default(galaxy_privsep_user) }}"))
  (galaxy_create_privsep_user (jinja "{{ galaxy_create_user if __galaxy_privsep_user_name != 'root' else false }}"))
  (galaxy_log_dir (jinja "{{ galaxy_mutable_data_dir }}") "/log")
  (galaxy_dirs (list
      (jinja "{{ galaxy_mutable_data_dir }}")
      (jinja "{{ galaxy_mutable_config_dir }}")
      (jinja "{{ galaxy_cache_dir }}")
      (jinja "{{ galaxy_shed_tools_dir }}")
      (jinja "{{ galaxy_tool_dependency_dir }}")
      (jinja "{{ galaxy_file_path }}")
      (jinja "{{ galaxy_job_working_directory }}")
      (jinja "{{ galaxy_tool_data_path }}")
      (jinja "{{ galaxy_log_dir }}")))
  (galaxy_extra_dirs (list))
  (galaxy_privsep_dirs (list
      (jinja "{{ galaxy_venv_dir }}")
      (jinja "{{ galaxy_server_dir }}")
      (jinja "{{ galaxy_config_dir }}")
      (jinja "{{ galaxy_local_tools_dir }}")))
  (galaxy_extra_privsep_dirs (list))
  (galaxy_local_tools_src_dir "files/galaxy/tools")
  (galaxy_dynamic_job_rules_src_dir "files/galaxy/dynamic_job_rules")
  (galaxy_dynamic_job_rules_dir (jinja "{{ galaxy_server_dir }}") "/lib/galaxy/jobs/rules")
  (galaxy_dynamic_job_rules (list))
  (galaxy_tmpclean_dirs (list
      (jinja "{{ galaxy_job_working_directory }}")
      (jinja "{{ galaxy_config.galaxy.new_file_path | default((galaxy_mutable_data_dir, 'tmp') | path_join) }}")))
  (galaxy_tmpclean_age "30d")
  (galaxy_tmpclean_log "true")
  (galaxy_tmpclean_cron_file "ansible_galaxy_tmpclean")
  (galaxy_tmpclean_verbose "false")
  (galaxy_tmpclean_time 
    (special_time "daily"))
  (galaxy_tmpclean_tmpreaper_runtime (jinja "{{ 20 * 60 * 60 }}"))
  (_galaxy_tmpclean_command 
    (redhat "/usr/bin/tmpwatch -all --mtime --dirmtime")
    (debian "/usr/sbin/tmpreaper --all --mtime --mtime-dir --runtime=" (jinja "{{ galaxy_tmpclean_tmpreaper_runtime }}")))
  (galaxy_tmpclean_verbose_statement (jinja "{{ galaxy_tmpclean_verbose | ternary(' -v', '') }}"))
  (galaxy_tmpclean_log_statement (jinja "{{ (galaxy_tmpclean_log != true) | ternary(
    ((galaxy_tmpclean_log is none) | ternary(
        '>/dev/null',
        '>>' ~ galaxy_tmpclean_log
    )),
    ''
) }}"))
  (galaxy_tmpclean_command (jinja "{{ _galaxy_tmpclean_command[(ansible_os_family | lower)] }}") (jinja "{{ galaxy_tmpclean_verbose_statement }}"))
  (galaxy_repo (jinja "{{ galaxy_git_repo | default('https://github.com/galaxyproject/galaxy.git') }}"))
  (galaxy_force_checkout "no")
  (galaxy_commit_id (jinja "{{ galaxy_changeset_id | default('master') }}"))
  (galaxy_download_url (jinja "{{ galaxy_repo | replace('.git', '') }}") "/archive/" (jinja "{{ galaxy_commit_id }}") ".tar.gz")
  (galaxy_tool_config_files (list
      (jinja "{{ galaxy_server_dir }}") "/config/tool_conf.xml.sample"))
  (galaxy_shed_tool_conf_file (jinja "{{ galaxy_mutable_config_dir }}") "/shed_tool_conf.xml")
  (galaxy_shed_tool_config_file (jinja "{{ galaxy_shed_tool_conf_file }}"))
  (galaxy_requirements_file (jinja "{{ galaxy_server_dir }}") "/lib/galaxy/dependencies/pinned-requirements.txt")
  (galaxy_static_dir (jinja "{{ galaxy_server_dir }}") "/static")
  (galaxy_config_style "yaml")
  (galaxy_config_file_basename "galaxy." (jinja "{{ 'yml' if galaxy_config_style in ('yaml', 'yml') else 'ini' }}"))
  (galaxy_config_file_template (jinja "{{ galaxy_config_file_basename }}") ".j2")
  (galaxy_config_file (jinja "{{ galaxy_config_dir }}") "/" (jinja "{{ galaxy_config_file_basename }}"))
  (galaxy_app_config_section (jinja "{{ 'galaxy' if galaxy_config_style in ('yaml', 'yml') else 'app:main' }}"))
  (galaxy_config_perms "0640")
  (galaxy_config_perms_public "0644")
  (galaxy_paste_app_factory "galaxy.web.buildapp:app_factory")
  (galaxy_app_config_default 
    (builds_file_path (jinja "{{ galaxy_server_dir }}") "/tool-data/shared/ucsc/builds.txt.sample")
    (data_manager_config_file (jinja "{{ galaxy_server_dir }}") "/config/data_manager_conf.xml.sample")
    (datatypes_config_file (jinja "{{ galaxy_server_dir }}") "/config/datatypes_conf.xml.sample")
    (external_service_type_config_file (jinja "{{ galaxy_server_dir }}") "/config/external_service_types_conf.xml.sample")
    (openid_config_file (jinja "{{ galaxy_server_dir }}") "/config/openid_conf.xml.sample")
    (ucsc_build_sites (jinja "{{ galaxy_server_dir }}") "/tool-data/shared/ucsc/ucsc_build_sites.txt.sample")
    (tool_data_table_config_path (jinja "{{ galaxy_server_dir }}") "/config/tool_data_table_conf.xml.sample")
    (tool_sheds_config_file (jinja "{{ galaxy_server_dir }}") "/config/tool_sheds_conf.xml.sample")
    (themes_config_file (jinja "{{ galaxy_config_dir }}") "/themes_conf.yml")
    (data_dir (jinja "{{ galaxy_mutable_data_dir }}"))
    (integrated_tool_panel_config (jinja "{{ galaxy_mutable_config_dir }}") "/integrated_tool_panel.xml")
    (migrated_tools_config (jinja "{{ galaxy_mutable_config_dir }}") "/migrated_tools_conf.xml")
    (shed_data_manager_config_file (jinja "{{ galaxy_mutable_config_dir }}") "/shed_data_manager_conf.xml")
    (shed_tool_data_table_config (jinja "{{ galaxy_mutable_config_dir }}") "/shed_tool_data_table_conf.xml")
    (file_path (jinja "{{ galaxy_file_path }}"))
    (job_working_directory (jinja "{{ galaxy_job_working_directory }}"))
    (tool_dependency_dir (jinja "{{ galaxy_tool_dependency_dir }}"))
    (tool_data_path (jinja "{{ galaxy_tool_data_path }}"))
    (tool_config_file (jinja "{{ galaxy_tool_config_files | join(',') }}"))
    (shed_tool_config_file (jinja "{{ galaxy_shed_tool_config_file }}"))
    (job_metrics_config_file (jinja "{{ galaxy_config_dir }}") "/job_metrics_conf." (jinja "{{ (galaxy_job_metrics_plugins is defined) | ternary('yml', 'xml') }}"))
    (dependency_resolvers_config_file (jinja "{{ galaxy_config_dir }}") "/dependency_resolvers_conf." (jinja "{{ (galaxy_dependency_resolvers is defined) | ternary('yml', 'xml') }}"))
    (container_resolvers_config_file (jinja "{{ (galaxy_container_resolvers is defined) | ternary(galaxy_config_dir ~ '/container_resolvers_conf.yml', none) }}"))
    (visualization_plugins_directory "config/plugins/visualizations")
    (static_enabled (jinja "{{ galaxy_manage_subdomain_static }}"))
    (static_dir_by_host )
    (static_images_dir_by_host )
    (static_welcome_html_by_host )
    (static_scripts_dir_by_host )
    (static_favicon_dir_by_host )
    (static_robots_txt_by_host )
    (themes_config_file_by_host )
    (brand_by_host ))
  (galaxy_config_default (jinja "{{ {} | combine({galaxy_app_config_section: galaxy_app_config_default}) }}"))
  (galaxy_config_merged (jinja "{{ galaxy_config_default | combine(galaxy_config | default({}), recursive=True) }}"))
  (galaxy_mutable_config_files (list
      
      (src "shed_data_manager_conf.xml")
      (dest (jinja "{{ galaxy_config_merged[galaxy_app_config_section].shed_data_manager_config_file }}"))
      
      (src "shed_tool_data_table_conf.xml")
      (dest (jinja "{{ galaxy_config_merged[galaxy_app_config_section].shed_tool_data_table_config }}"))))
  (galaxy_mutable_config_templates (list
      
      (src "shed_tool_conf.xml.j2")
      (dest (jinja "{{ galaxy_config_merged[galaxy_app_config_section].migrated_tools_config }}"))
      
      (src "shed_tool_conf.xml.j2")
      (dest (jinja "{{ galaxy_shed_tool_config_file }}"))))
  (galaxy_config_error_email_to (jinja "{{ galaxy_config_merged[galaxy_app_config_section].error_email_to | default('') }}"))
  (galaxy_config_instance_resource_url (jinja "{{ galaxy_config_merged[galaxy_app_config_section].instance_resource_url | default('') }}"))
  (galaxy_errordocs_server_name "Galaxy")
  (galaxy_errordocs_prefix "/error")
  (galaxy_config_files (list))
  (galaxy_config_templates (list))
  (galaxy_config_files_public (list))
  (galaxy_gravity_state_dir (jinja "{{ (galaxy_mutable_data_dir, 'gravity') | path_join }}"))
  (galaxy_gravity_config_default 
    (galaxy_root (jinja "{{ galaxy_server_dir }}"))
    (log_dir (jinja "{{ galaxy_log_dir }}"))
    (virtualenv (jinja "{{ galaxy_venv_dir }}"))
    (app_server "gunicorn")
    (gunicorn 
      (bind "localhost:8080")))
  (galaxy_uwsgi_yaml_parser "internal")
  (galaxy_uwsgi_config_default 
    (http "127.0.0.1:8080")
    (buffer-size "16384")
    (processes "1")
    (threads "4")
    (offload-threads "2")
    (static-map (list
        "/static/style=" (jinja "{{ galaxy_server_dir }}") "/static/style/blue"
        "/static=" (jinja "{{ galaxy_server_dir }}") "/static"))
    (master "true")
    (virtualenv (jinja "{{ galaxy_venv_dir }}"))
    (pythonpath (jinja "{{ galaxy_server_dir }}") "/lib")
    (module "galaxy.webapps.galaxy.buildapp:uwsgi_app()")
    (thunder-lock "true")
    (die-on-term "true")
    (hook-master-start (list
        "unix_signal:2 gracefully_kill_them_all"
        "unix_signal:15 gracefully_kill_them_all"))
    (py-call-osafterfork "true")
    (enable-threads "true"))
  (galaxy_client_use_prebuilt "false")
  (galaxy_client_make_target "client-production-maps")
  (galaxy_client_force_build "false")
  (galaxy_client_node_env "production")
  (galaxy_client_build_steps 
    (default (list
        "client"
        "plugins"))
    (19.09 (list
        "fonts"
        "stageLibs"
        "plugins")))
  (__galaxy_node_version_max 
    (redhat7 "16.19.1"))
  (galaxy_node_version_max (jinja "{{
  (__galaxy_node_version_max[(ansible_os_family | lower) ~ ansible_distribution_major_version]) | default(galaxy_node_version)
}}"))
  (__galaxy_gravity_pm (jinja "{{ (galaxy_config_merged.gravity | default({})).process_manager | default('supervisor') }}"))
  (__galaxy_gravity_instance_name (jinja "{{ (galaxy_config_merged.gravity | default({})).instance_name | default(none) }}"))
  (galaxy_gravity_wrapper_path "/usr/local/bin/galaxyctl" (jinja "{{ __galaxy_gravity_instance_name | ternary('-' ~ __galaxy_gravity_instance_name, '') }}"))
  (galaxy_gravity_command (jinja "{{ galaxy_venv_dir }}") "/bin/galaxyctl")
  (galaxy_systemd_mode (jinja "{{ 'mule' if __galaxy_major_version is version('22.05', '<') else 'gravity' }}"))
  (galaxy_systemd_root "true")
  (galaxy_systemd_command (jinja "{{ __galaxy_systemd_command[galaxy_systemd_mode] }}"))
  (__galaxy_systemd_command 
    (mule (jinja "{{ galaxy_venv_dir }}") "/bin/uwsgi " (jinja "{{ '--yaml' if galaxy_config_style in ('yaml', 'yml') else '--ini' }}") " " (jinja "{{ galaxy_config_file }}"))
    (gravity (jinja "{{ galaxy_venv_dir }}") "/bin/galaxyctl start --foreground --quiet"))
  (galaxy_systemd_timeout_start_sec (jinja "{{ (galaxy_systemd_mode == 'gravity') | ternary(60, 10) }}"))
  (__galaxy_systemd_memory_limit 
    (mule "16")
    (reports "5"))
  (__galaxy_systemd_memory_limit_merged (jinja "{{ __galaxy_systemd_memory_limit | combine(galaxy_systemd_memory_limit | default({})) }}"))
  (galaxy_systemd_env (list))
  (galaxy_additional_venv_packages (list))
  (galaxy_themes_subdomains (list))
  (galaxy_themes_static_path (jinja "{{ galaxy_root }}") "/server")
  (galaxy_themes_welcome_url_prefix "https://usegalaxy-eu.github.io/index-")
  (galaxy_themes_default_welcome "https://galaxyproject.org")
  (galaxy_themes_ansible_file_path "files/galaxy/static")
  (galaxy_themes_instance_domain "usegalaxy.eu")
  (galaxy_themes_global_host_filters_path (jinja "{{ galaxy_root }}") "/server/lib/galaxy/tool_util/toolbox/filters/global_host_filters.py")
  (galaxy_themes_tool_base_labels (list
      "file_and_meta_tools"
      "general_text_tools"
      "genomic_file_manipulation"
      "gff"
      "common_genomics"))
  (galaxy_themes_tool_ngs_labels (list
      "specific_genomics"
      "genomics_toolkits"))
  (galaxy_themes_tool_base_sections (list
      "getext"
      "send"
      "collection_operations"
      "textutil"
      "convert"
      "filter"
      "group"
      "expression_tools"))
  (galaxy_themes_tool_ngs_sections (list
      "deeptools"
      "bed"
      "sambam"
      "bxops"
      "fastafastq"
      "fastq_quality_control"
      "picard"
      "mapping"
      "sambam")))
