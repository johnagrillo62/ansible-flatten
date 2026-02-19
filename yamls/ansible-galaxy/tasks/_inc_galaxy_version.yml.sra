(playbook "ansible-galaxy/tasks/_inc_galaxy_version.yml"
  (tasks
    (task "Collect Galaxy version file"
      (slurp 
        (src (jinja "{{ galaxy_server_dir }}") "/lib/galaxy/version.py"))
      (register "__galaxy_version_file"))
    (task "Determine Galaxy version"
      (set_fact 
        (__galaxy_major_version (jinja "{{
    (__galaxy_version_file['content'] | b64decode).splitlines()
        | select('match', 'VERSION_MAJOR\\s*=.*') | first
        | regex_replace('^[^\\d]+([.\\d]+).*', '\\1')
}}"))))))
