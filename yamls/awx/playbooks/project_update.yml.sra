(playbook "awx/playbooks/project_update.yml"
    (play
    (hosts "localhost")
    (gather_facts "false")
    (connection "local")
    (name "Update source tree if necessary")
    (tasks
      (task "Delete project directory before update"
        (ansible.builtin.shell "set -o pipefail && find . -delete -print | tail -2")
        (register "reg")
        (changed_when "reg.stdout_lines | length > 1")
        (args 
          (chdir (jinja "{{ project_path }}")))
        (tags (list
            "delete")))
      (task "Update project using git"
        (block (list
            
            (name "Update project using git")
            (ansible.builtin.git 
              (dest (jinja "{{ project_path | quote }}"))
              (repo (jinja "{{ scm_url }}"))
              (version (jinja "{{ scm_branch | quote }}"))
              (refspec (jinja "{{ scm_refspec | default(omit) }}"))
              (force (jinja "{{ scm_clean }}"))
              (track_submodules (jinja "{{ scm_track_submodules | default(omit) }}"))
              (accept_hostkey (jinja "{{ scm_accept_hostkey | default(omit) }}")))
            (register "git_result")
            
            (name "Set the git repository version")
            (ansible.builtin.set_fact 
              (scm_version (jinja "{{ git_result['after'] }}")))
            (when "'after' in git_result")))
        (tags (list
            "update_git")))
      (task "Update project using svn"
        (block (list
            
            (name "Update project using svn")
            (ansible.builtin.subversion 
              (dest (jinja "{{ project_path | quote }}"))
              (repo (jinja "{{ scm_url | quote }}"))
              (revision (jinja "{{ scm_branch | quote }}"))
              (force (jinja "{{ scm_clean }}"))
              (username (jinja "{{ scm_username | default(omit) }}"))
              (password (jinja "{{ scm_password | default(omit) }}"))
              (in_place "true"))
            (environment 
              (LC_ALL "en_US.UTF-8"))
            (register "svn_result")
            
            (name "Set the svn repository version")
            (ansible.builtin.set_fact 
              (scm_version (jinja "{{ svn_result['after'] }}")))
            (when "'after' in svn_result")
            
            (name "Parse subversion version string properly")
            (ansible.builtin.set_fact 
              (scm_version (jinja "{{ scm_version | regex_replace('^.*Revision: ([0-9]+).*$', '\\\\1') }}")))))
        (tags (list
            "update_svn")))
      (task "Project update for Insights"
        (block (list
            
            (name "Ensure the project directory is present")
            (ansible.builtin.file 
              (dest (jinja "{{ project_path | quote }}"))
              (state "directory")
              (mode "0755"))
            
            (name "Fetch Insights Playbook(s)")
            (insights 
              (insights_url (jinja "{{ insights_url }}"))
              (username (jinja "{{ scm_username | default(omit) }}"))
              (password (jinja "{{ scm_password | default(omit) }}"))
              (project_path (jinja "{{ project_path }}"))
              (awx_license_type (jinja "{{ awx_license_type }}"))
              (awx_version (jinja "{{ awx_version }}"))
              (client_id (jinja "{{ client_id | default(omit) }}"))
              (client_secret (jinja "{{ client_secret | default(omit) }}"))
              (authentication (jinja "{{ authentication | default(omit) }}")))
            (register "results")
            
            (name "Save Insights Version")
            (ansible.builtin.set_fact 
              (scm_version (jinja "{{ results.version }}")))
            (when "results is defined")))
        (tags (list
            "update_insights")))
      (task "Update project using archive"
        (block (list
            
            (name "Ensure the project archive directory is present")
            (ansible.builtin.file 
              (dest (jinja "{{ project_path | quote }}") "/.archive")
              (state "directory")
              (mode "0755"))
            
            (name "Get archive from url")
            (ansible.builtin.get_url 
              (url (jinja "{{ scm_url | quote }}"))
              (dest (jinja "{{ project_path | quote }}") "/.archive/")
              (url_username (jinja "{{ scm_username | default(omit) }}"))
              (url_password (jinja "{{ scm_password | default(omit) }}"))
              (force_basic_auth "true")
              (mode "0755"))
            (register "get_archive")
            
            (name "Unpack archive")
            (project_archive 
              (src (jinja "{{ get_archive.dest }}"))
              (project_path (jinja "{{ project_path | quote }}"))
              (force (jinja "{{ scm_clean }}")))
            (when "get_archive.changed or scm_clean")
            (register "unarchived")
            
            (name "Find previous archives")
            (ansible.builtin.find 
              (paths (jinja "{{ project_path | quote }}") "/.archive/")
              (excludes (list
                  (jinja "{{ get_archive.dest | basename }}"))))
            (when "unarchived.changed")
            (register "previous_archive")
            
            (name "Remove previous archives")
            (ansible.builtin.file 
              (path (jinja "{{ item.path }}"))
              (state "absent"))
            (loop (jinja "{{ previous_archive.files }}"))
            (when "previous_archive.files | default([])")
            
            (name "Set scm_version to archive sha1 checksum")
            (ansible.builtin.set_fact 
              (scm_version (jinja "{{ get_archive.checksum_src }}")))))
        (tags (list
            "update_archive")))
      (task "Repository Version"
        (ansible.builtin.debug 
          (msg "Repository Version " (jinja "{{ scm_version }}")))
        (tags (list
            "update_git"
            "update_svn"
            "update_insights"
            "update_archive")))))
    (play
    (hosts "localhost")
    (gather_facts "false")
    (connection "local")
    (name "Perform project signature/checksum verification")
    (tasks
      (task "Verify project content using GPG signature"
        (verify_project 
          (project_path (jinja "{{ project_path | quote }}"))
          (validation_type "gpg")
          (gpg_pubkey (jinja "{{ gpg_pubkey }}")))
        (tags (list
            "validation_gpg_public_key")))
      (task "Verify project content against checksum manifest"
        (verify_project 
          (project_path (jinja "{{ project_path | quote }}"))
          (validation_type "checksum_manifest"))
        (tags (list
            "validation_checksum_manifest")))))
    (play
    (hosts "localhost")
    (gather_facts "false")
    (connection "local")
    (name "Install content with ansible-galaxy command if necessary")
    (vars
      (galaxy_task_env null)
      (additional_galaxy_env 
        (ANSIBLE_COLLECTIONS_PATH (jinja "{{ projects_root }}") "/.__awx_cache/" (jinja "{{ local_path }}") "/stage/requirements_collections")
        (ANSIBLE_ROLES_PATH (jinja "{{ projects_root }}") "/.__awx_cache/" (jinja "{{ local_path }}") "/stage/requirements_roles")
        (ANSIBLE_LOCAL_TEMP (jinja "{{ projects_root }}") "/.__awx_cache/" (jinja "{{ local_path }}") "/stage/tmp")))
    (tasks
      (task "Check content sync settings"
        (block (list
            
            (name "Warn about disabled content sync")
            (ansible.builtin.debug 
              (msg "Collection and role syncing disabled. Check the AWX_ROLES_ENABLED and AWX_COLLECTIONS_ENABLED settings and Galaxy credentials on the project's organization.
"))
            
            (name "End play due to disabled content sync")
            (ansible.builtin.meta "end_play")))
        (when "not roles_enabled | bool and not collections_enabled | bool")
        (tags (list
            "install_roles"
            "install_collections")))
      (task
        (block (list
            
            (name "Fetch galaxy roles from roles/requirements.(yml/yaml)")
            (ansible.builtin.command 
              (cmd "ansible-galaxy role install -r " (jinja "{{ req_file }}") " " (jinja "{{ verbosity }}")))
            (register "galaxy_result")
            (vars 
              (req_file (jinja "{{ lookup('ansible.builtin.first_found', req_candidates, skip=True) }}"))
              (req_candidates 
                (files (list
                    (jinja "{{ project_path | quote }}") "/roles/requirements.yml"
                    (jinja "{{ project_path | quote }}") "/roles/requirements.yaml"))
                (skip "True")))
            (changed_when "'was installed successfully' in galaxy_result.stdout")
            (when (list
                "roles_enabled | bool"
                "req_file"))
            (tags (list
                "install_roles"))
            
            (name "Fetch galaxy collections from collections/requirements.(yml/yaml)")
            (ansible.builtin.command 
              (cmd "ansible-galaxy collection install -r " (jinja "{{ req_file }}") " " (jinja "{{ verbosity }}")))
            (register "galaxy_collection_result")
            (vars 
              (req_file (jinja "{{ lookup('ansible.builtin.first_found', req_candidates, skip=True) }}"))
              (req_candidates 
                (files (list
                    (jinja "{{ project_path | quote }}") "/collections/requirements.yml"
                    (jinja "{{ project_path | quote }}") "/collections/requirements.yaml"))
                (skip "True")))
            (changed_when "'Nothing to do.' not in galaxy_collection_result.stdout")
            (when (list
                "ansible_version.full is version_compare('2.9', '>=')"
                "collections_enabled | bool"
                "req_file"))
            (tags (list
                "install_collections"))
            
            (name "Fetch galaxy roles and collections from requirements.(yml/yaml)")
            (ansible.builtin.command 
              (cmd "ansible-galaxy install -r " (jinja "{{ req_file }}") " " (jinja "{{ verbosity }}")))
            (register "galaxy_combined_result")
            (vars 
              (req_file (jinja "{{ lookup('ansible.builtin.first_found', req_candidates, skip=True) }}"))
              (req_candidates 
                (files (list
                    (jinja "{{ project_path | quote }}") "/requirements.yaml"
                    (jinja "{{ project_path | quote }}") "/requirements.yml"))
                (skip "True")))
            (changed_when "'Nothing to do.' not in galaxy_combined_result.stdout")
            (when (list
                "ansible_version.full is version_compare('2.10', '>=')"
                "collections_enabled | bool"
                "roles_enabled | bool"
                "req_file"))
            (tags (list
                "install_collections"
                "install_roles"))))
        (module_defaults 
          (ansible.builtin.command 
            (chdir (jinja "{{ project_path | quote }}"))))
        (environment (jinja "{{ galaxy_task_env | combine(additional_galaxy_env) }}"))
        (vars 
          (verbosity (jinja "{{ (ansible_verbosity) | ternary('-'+'v'*ansible_verbosity, '') }}")))))))
