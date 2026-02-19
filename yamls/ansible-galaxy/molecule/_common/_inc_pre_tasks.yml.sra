(playbook "ansible-galaxy/molecule/_common/_inc_pre_tasks.yml"
  (tasks
    (task "Install dependencies (yum)"
      (yum 
        (name (list
            "sudo"
            "make"
            "bzip2")))
      (when "ansible_os_family == \"RedHat\" and ansible_distribution_major_version is version(\"8\", \"<\")"))
    (task "Install dependencies (dnf)"
      (dnf 
        (name (list
            "sudo"
            "git"
            "make"
            "bzip2")))
      (when "ansible_os_family == \"RedHat\" and ansible_distribution_major_version is version(\"8\", \">=\")"))
    (task "Install dependencies (apt)"
      (apt 
        (name (list
            "sudo"
            "git"
            "make"
            "python3-venv"
            "python3-setuptools"
            "python3-dev"
            "python3-psycopg2"
            "gcc"
            "acl"
            "gnutls-bin"
            "libmagic-dev")))
      (when "ansible_os_family == \"Debian\""))
    (task "Check whether server dir exists"
      (stat 
        (path (jinja "{{ galaxy_root }}") "/server"))
      (register "__molecule_dir_check"))
    (task "Collect current commit id"
      (git 
        (clone "false")
        (depth (jinja "{{ galaxy_clone_depth }}"))
        (dest (jinja "{{ galaxy_root }}") "/server")
        (repo "https://github.com/galaxyproject/galaxy.git"))
      (changed_when "false")
      (become (jinja "{{ __molecule_dir_check.stat.exists }}"))
      (become_user (jinja "{{ galaxy_privsep_user }}"))
      (register "__molecule_git_check"))
    (task "Set galaxy_commit_id"
      (set_fact 
        (galaxy_commit_id (jinja "{{ __molecule_git_check.before or ((__galaxy_version == 'dev') | ternary('dev', 'release_' ~ __galaxy_version)) }}"))))))
