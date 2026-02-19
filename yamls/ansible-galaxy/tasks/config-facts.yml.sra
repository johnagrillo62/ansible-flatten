(playbook "ansible-galaxy/tasks/config-facts.yml"
  (tasks
    (task "Build static_dir_by_host dict"
      (set_fact 
        (_galaxy_static_dir_by_host_dict (jinja "{{
  _galaxy_static_dir_by_host_dict | default({}) |
  combine({
    (subdomain.name ~ '.' ~ galaxy_themes_instance_domain): (galaxy_themes_static_path ~ '/static-' ~ subdomain.name ~ '/')
  })
}}")))
      (loop (jinja "{{ galaxy_themes_subdomains }}"))
      (loop_control 
        (loop_var "subdomain"))
      (when "galaxy_manage_subdomain_static"))
    (task "Add base domain to static_dir_by_host dict"
      (set_fact 
        (_galaxy_static_dir_by_host_dict (jinja "{{
  _galaxy_static_dir_by_host_dict | default({}) |
  combine({galaxy_themes_instance_domain: (galaxy_static_dir ~ '/')})
}}")))
      (when "galaxy_manage_subdomain_static"))
    (task "Build static_images_dir_by_host dict"
      (set_fact 
        (_galaxy_static_images_dir_by_host_dict (jinja "{{
  _galaxy_static_images_dir_by_host_dict | default({}) |
  combine({
    (subdomain.name ~ '.' ~ galaxy_themes_instance_domain): (galaxy_themes_static_path ~ '/static-' ~ subdomain.name ~ '/images')
  })
}}")))
      (loop (jinja "{{ galaxy_themes_subdomains }}"))
      (loop_control 
        (loop_var "subdomain"))
      (when "galaxy_manage_subdomain_static"))
    (task "Add base domain to static_images_dir_by_host dict"
      (set_fact 
        (_galaxy_static_images_dir_by_host_dict (jinja "{{
  _galaxy_static_images_dir_by_host_dict | default({}) |
  combine({galaxy_themes_instance_domain: (galaxy_static_dir ~ '/images')})
}}")))
      (when "galaxy_manage_subdomain_static"))
    (task "Build static_welcome_html_by_host dict"
      (set_fact 
        (_galaxy_static_welcome_html_by_host_dict (jinja "{{
  _galaxy_static_welcome_html_by_host_dict | default({}) |
  combine({
    (subdomain.name ~ '.' ~ galaxy_themes_instance_domain): (galaxy_themes_static_path ~ '/static-' ~ subdomain.name ~ '/welcome.html')
  })
}}")))
      (loop (jinja "{{ galaxy_themes_subdomains }}"))
      (loop_control 
        (loop_var "subdomain"))
      (when "galaxy_manage_subdomain_static"))
    (task "Add base domain to static_welcome_html_by_host dict"
      (set_fact 
        (_galaxy_static_welcome_html_by_host_dict (jinja "{{
  _galaxy_static_welcome_html_by_host_dict | default({}) |
  combine({galaxy_themes_instance_domain: (galaxy_static_dir ~ '/welcome.html')})
}}")))
      (when "galaxy_manage_subdomain_static"))
    (task "Build static_scripts_dir_by_host dict"
      (set_fact 
        (_galaxy_static_scripts_dir_by_host_dict (jinja "{{
  _galaxy_static_scripts_dir_by_host_dict | default({}) |
  combine({
    (subdomain.name ~ '.' ~ galaxy_themes_instance_domain): (galaxy_themes_static_path ~ '/static-' ~ subdomain.name ~ '/scripts')
  })
}}")))
      (loop (jinja "{{ galaxy_themes_subdomains }}"))
      (loop_control 
        (loop_var "subdomain"))
      (when "galaxy_manage_subdomain_static"))
    (task "Add base domain to static_scripts_dir_by_host dict"
      (set_fact 
        (_galaxy_static_scripts_dir_by_host_dict (jinja "{{
  _galaxy_static_scripts_dir_by_host_dict | default({}) |
  combine({galaxy_themes_instance_domain: (galaxy_static_dir ~ '/scripts')})
}}")))
      (when "galaxy_manage_subdomain_static"))
    (task "Build static_favicon_dir_by_host dict"
      (set_fact 
        (_galaxy_static_favicon_dir_by_host_dict (jinja "{{
  _galaxy_static_favicon_dir_by_host_dict | default({}) |
  combine({
    (subdomain.name ~ '.' ~ galaxy_themes_instance_domain): (galaxy_themes_static_path ~ '/static-' ~ subdomain.name)
  })
}}")))
      (loop (jinja "{{ galaxy_themes_subdomains }}"))
      (loop_control 
        (loop_var "subdomain"))
      (when "galaxy_manage_subdomain_static"))
    (task "Add base domain to static_favicon_dir_by_host dict"
      (set_fact 
        (_galaxy_static_favicon_dir_by_host_dict (jinja "{{
  _galaxy_static_favicon_dir_by_host_dict | default({}) |
  combine({galaxy_themes_instance_domain: galaxy_static_dir})
}}")))
      (when "galaxy_manage_subdomain_static"))
    (task "Build static_robots_txt_by_host dict"
      (set_fact 
        (_galaxy_static_robots_txt_by_host_dict (jinja "{{
  _galaxy_static_robots_txt_by_host_dict | default({}) |
  combine({
    (subdomain.name ~ '.' ~ galaxy_themes_instance_domain): (galaxy_themes_static_path ~ '/static-' ~ subdomain.name)
  })
}}")))
      (loop (jinja "{{ galaxy_themes_subdomains }}"))
      (loop_control 
        (loop_var "subdomain"))
      (when "galaxy_manage_subdomain_static"))
    (task "Add base domain to static_robots_txt_by_host dict"
      (set_fact 
        (_galaxy_static_robots_txt_by_host_dict (jinja "{{
  _galaxy_static_robots_txt_by_host_dict | default({}) |
  combine({galaxy_themes_instance_domain: galaxy_static_dir})
}}")))
      (when "galaxy_manage_subdomain_static"))
    (task "Build themes_config_file_by_host dict for subdomains"
      (set_fact 
        (_galaxy_themes_config_file_by_host_dict (jinja "{{
  _galaxy_themes_config_file_by_host_dict | default({}) |
  combine({
    (subdomain.name ~ '.' ~ galaxy_themes_instance_domain): ('themes_conf-' ~ subdomain.name ~ '.yml')
  })
}}")))
      (loop (jinja "{{ galaxy_themes_subdomains }}"))
      (loop_control 
        (loop_var "subdomain"))
      (when (list
          "galaxy_manage_themes"
          "galaxy_themes_subdomains | length > 0"
          "subdomain.theme is defined")))
    (task "Add base domain to themes_config_file_by_host dict"
      (set_fact 
        (_galaxy_themes_config_file_by_host_dict (jinja "{{
  _galaxy_themes_config_file_by_host_dict | default({}) |
  combine({galaxy_themes_instance_domain: (galaxy_config.galaxy.themes_config_file | default((galaxy_config_dir, 'themes_conf.yml') | path_join))})
}}")))
      (when (list
          "galaxy_manage_themes"
          "galaxy_themes_subdomains | length > 0")))
    (task "Build brand_by_host dict"
      (set_fact 
        (_galaxy_brand_by_host_dict (jinja "{{
  _galaxy_brand_by_host_dict | default({}) |
  combine({
    (subdomain.name ~ '.' ~ galaxy_themes_instance_domain): (subdomain.name[0]|upper ~ subdomain.name[1:])
  })
}}")))
      (loop (jinja "{{ galaxy_themes_subdomains }}"))
      (loop_control 
        (loop_var "subdomain"))
      (when "galaxy_auto_brand"))
    (task "Add base domain to brand_by_host dict"
      (set_fact 
        (_galaxy_brand_by_host_dict (jinja "{{
  _galaxy_brand_by_host_dict | default({}) |
  combine({galaxy_themes_instance_domain: galaxy_themes_instance_domain})
}}")))
      (when "galaxy_auto_brand"))
    (task "Override galaxy_app_config_default with proper dict values"
      (set_fact 
        (galaxy_app_config_default (jinja "{{
  galaxy_app_config_default |
  combine({
    'static_dir_by_host': _galaxy_static_dir_by_host_dict | default({}),
    'static_images_dir_by_host': _galaxy_static_images_dir_by_host_dict | default({}),
    'static_welcome_html_by_host': _galaxy_static_welcome_html_by_host_dict | default({}),
    'static_scripts_dir_by_host': _galaxy_static_scripts_dir_by_host_dict | default({}),
    'static_favicon_dir_by_host': _galaxy_static_favicon_dir_by_host_dict | default({}),
    'static_robots_txt_by_host': _galaxy_static_robots_txt_by_host_dict | default({}),
    'themes_config_file_by_host': _galaxy_themes_config_file_by_host_dict | default({}),
    'brand_by_host': _galaxy_brand_by_host_dict | default({})
  })
}}"))))))
