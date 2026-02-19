(playbook "debops/ansible/roles/resources/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Pre hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"resources/pre_main.yml\") }}")))
    (task "Manage git repositories"
      (ansible.builtin.git 
        (repo (jinja "{{ item.repo | d(item.url | d(item.src)) }}"))
        (dest (jinja "{{ item.dest | d(item.name | d(item.path)) }}"))
        (accept_hostkey (jinja "{{ item.accept_hostkey | d(omit) }}"))
        (bare (jinja "{{ item.bare | d(omit) }}"))
        (clone (jinja "{{ item.clone | d(omit) }}"))
        (depth (jinja "{{ item.depth | d(omit) }}"))
        (executable (jinja "{{ item.executable | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (key_file (jinja "{{ item.key_file | d(omit) }}"))
        (recursive (jinja "{{ item.recursive | d(omit) }}"))
        (reference (jinja "{{ item.reference | d(omit) }}"))
        (refspec (jinja "{{ item.refspec | d(omit) }}"))
        (remote (jinja "{{ item.remote | d(omit) }}"))
        (ssh_opts (jinja "{{ item.ssh_opts | d(omit) }}"))
        (track_submodules (jinja "{{ item.track_submodules | d(omit) }}"))
        (umask (jinja "{{ item.umask | d(omit) }}"))
        (update (jinja "{{ item[\"_update\"] | d(omit) }}"))
        (verify_commit (jinja "{{ item.verify_commit | d(omit) }}"))
        (version (jinja "{{ item.version | d(omit) }}")))
      (become "True")
      (become_user (jinja "{{ item.owner | d(\"root\") }}"))
      (loop (jinja "{{ q(\"flattened\", resources__repositories
                           + resources__group_repositories
                           + resources__host_repositories) }}"))
      (when "(resources__enabled | bool and (item.repo | d() or item.url | d() or item.src | d()) and (item.dest | d() or item.name | d() or item.path | d()))")
      (tags (list
          "role::resources:repositories")))
    (task "Ensure that template directories exist"
      (ansible.builtin.file 
        (path "/" (jinja "{{ item.path }}"))
        (mode (jinja "{{ item.mode }}"))
        (state "directory"))
      (with_community.general.filetree (jinja "{{ (resources__host_templates
                                        + resources__group_templates
                                        + resources__templates) | flatten }}"))
      (when "item.state == 'directory'"))
    (task "Generate custom templates"
      (ansible.builtin.template 
        (src (jinja "{{ item.src }}"))
        (dest "/" (jinja "{{ item.path }}"))
        (mode (jinja "{{ item.mode }}")))
      (with_community.general.filetree (jinja "{{ (resources__host_templates
                                        + resources__group_templates
                                        + resources__templates) | flatten }}"))
      (when "item.state == 'file'"))
    (task "Recreate custom symlinks"
      (ansible.builtin.file 
        (src (jinja "{{ item.src }}"))
        (dest "/" (jinja "{{ item.path }}"))
        (mode (jinja "{{ item.mode }}"))
        (state "link")
        (force "True"))
      (with_community.general.filetree (jinja "{{ (resources__host_templates
                                        + resources__group_templates
                                        + resources__templates) | flatten }}"))
      (when "item.state == 'link'"))
    (task "Manage paths on remote hosts"
      (ansible.builtin.file 
        (path (jinja "{{ (item.path | d(item.dest | d(item.name))) | d(item) }}"))
        (state (jinja "{{ item.state | d(\"directory\") }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (selevel (jinja "{{ item.selevel | d(omit) }}"))
        (serole (jinja "{{ item.serole | d(omit) }}"))
        (setype (jinja "{{ item.setype | d(omit) }}"))
        (seuser (jinja "{{ item.seuser | d(omit) }}"))
        (follow (jinja "{{ item.follow | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (src (jinja "{{ item.src | d(omit) }}"))
        (recurse (jinja "{{ item.recurse | d(omit) }}"))
        (attributes (jinja "{{ item.attributes | d(omit) }}"))
        (access_time (jinja "{{ item.access_time | d(omit) }}"))
        (access_time_format (jinja "{{ item.access_time_format | d(resources__time_format) }}"))
        (modification_time (jinja "{{ item.modification_time | d(omit) }}"))
        (modification_time_format (jinja "{{ item.modification_time_format | d(resources__time_format) }}")))
      (loop (jinja "{{ q(\"flattened\", resources__paths
                           + resources__group_paths
                           + resources__host_paths) }}"))
      (when "(resources__enabled | bool and ((item.path | d() or item.dest | d() or item.name | d()) or item))")
      (tags (list
          "role::resources:paths")))
    (task "Ensure that parent directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ (item.dest | d(item.name | d(item.path))) | dirname }}"))
        (state "directory")
        (recurse (jinja "{{ item.parent_dirs_recurse | d(resources__parent_dirs_recurse) }}"))
        (owner (jinja "{{ item.parent_dirs_owner | d(resources__parent_dirs_owner) }}"))
        (group (jinja "{{ item.parent_dirs_group | d(resources__parent_dirs_group) }}"))
        (mode (jinja "{{ item.parent_dirs_mode | d(resources__parent_dirs_mode) }}")))
      (when "(resources__enabled | bool and (item.parent_dirs_create | d(resources__parent_dirs_create) | bool) and item.state | d(\"present\") != 'absent')")
      (loop (jinja "{{ q(\"flattened\", resources__urls
                           + resources__group_urls
                           + resources__host_urls
                           + resources__archives
                           + resources__group_archives
                           + resources__host_archives
                           + resources__files
                           + resources__group_files
                           + resources__host_files) }}"))
      (tags (list
          "role::resources:urls"
          "role::resources:archives"
          "role::resources:files")))
    (task "Download online resources to remote hosts"
      (ansible.builtin.get_url 
        (url (jinja "{{ item.url | d(item.src) }}"))
        (dest (jinja "{{ item.dest | d(item.name | d(item.path)) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (checksum (jinja "{{ item.checksum | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (force_basic_auth (jinja "{{ item.force_basic_auth | d(omit) }}"))
        (headers (jinja "{{ item.headers | d(omit) }}"))
        (sha256sum (jinja "{{ item.sha256sum | d(omit) }}"))
        (timeout (jinja "{{ item.timeout | d(omit) }}"))
        (url_password (jinja "{{ item.url_password | d(omit) }}"))
        (url_username (jinja "{{ item.url_username | d(omit) }}"))
        (use_proxy (jinja "{{ item.use_proxy | d(omit) }}"))
        (validate_certs (jinja "{{ item.validate_certs | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", resources__urls
                           + resources__group_urls
                           + resources__host_urls) }}"))
      (when "(resources__enabled | bool and (item.url | d() or item.src | d()) and (item.dest | d() or item.name | d() or item.path | d()))")
      (no_log (jinja "{{ debops__no_log | d(True if item.url_password | d() else omit) }}"))
      (tags (list
          "role::resources:urls")))
    (task "Unpack archives to remote hosts"
      (ansible.builtin.unarchive 
        (src (jinja "{{ item.src }}"))
        (dest (jinja "{{ item.dest | d(item.name | d(item.path)) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (selevel (jinja "{{ item.selevel | d(omit) }}"))
        (serole (jinja "{{ item.serole | d(omit) }}"))
        (setype (jinja "{{ item.setype | d(omit) }}"))
        (seuser (jinja "{{ item.seuser | d(omit) }}"))
        (creates (jinja "{{ item.creates | d(omit) }}"))
        (exclude (jinja "{{ item.exclude | d(omit) }}"))
        (keep_newer (jinja "{{ item.keep_newer | d(omit) }}"))
        (extra_opts (jinja "{{ item.extra_opts | d(omit) }}"))
        (attributes (jinja "{{ item.attributes | d(omit) }}"))
        (list_files (jinja "{{ item.list_files | d(omit) }}"))
        (remote_src (jinja "{{ item.remote_src | d(omit) }}"))
        (unsafe_writes (jinja "{{ item.unsafe_writes | d(omit) }}"))
        (validate_certs (jinja "{{ item.validate_certs | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", resources__archives
                           + resources__group_archives
                           + resources__host_archives) }}"))
      (when "(resources__enabled | bool and item.src | d() and (item.dest | d() or item.name | d() or item.path | d()))")
      (tags (list
          "role::resources:archives")))
    (task "Delete files on remote hosts"
      (ansible.builtin.file 
        (path (jinja "{{ item.dest | d(item.path | d(item.name)) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", resources__files
                           + resources__group_files
                           + resources__host_files) }}"))
      (when "(resources__enabled | bool and (item.dest | d() or item.path | d() or item.name | d()) and (item.state | d('present') == 'absent'))")
      (tags (list
          "role::resources:files")))
    (task "Copy files to remote hosts"
      (ansible.builtin.copy 
        (dest (jinja "{{ item.dest | d(item.path | d(item.name)) }}"))
        (src (jinja "{{ item.src | d(omit) }}"))
        (content (jinja "{{ item.content | d(omit) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (selevel (jinja "{{ item.selevel | d(omit) }}"))
        (serole (jinja "{{ item.serole | d(omit) }}"))
        (setype (jinja "{{ item.setype | d(omit) }}"))
        (seuser (jinja "{{ item.seuser | d(omit) }}"))
        (follow (jinja "{{ item.follow | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (backup (jinja "{{ item.backup | d(omit) }}"))
        (validate (jinja "{{ item.validate | d(omit) }}"))
        (remote_src (jinja "{{ item.remote_src | d(omit) }}"))
        (directory_mode (jinja "{{ item.directory_mode | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", resources__files
                           + resources__group_files
                           + resources__host_files) }}"))
      (when "(resources__enabled | bool and (item.src | d() or item.content is defined) and (item.dest | d() or item.path | d() or item.name | d()) and (item.state | d('present') != 'absent'))")
      (tags (list
          "role::resources:files")))
    (task "Manage virtual environments"
      (ansible.builtin.pip 
        (chdir (jinja "{{ item.chdir | d(omit) }}"))
        (editable (jinja "{{ item.editable | d(omit) }}"))
        (executable (jinja "{{ item.executable | d(omit) }}"))
        (extra_args (jinja "{{ item.extra_args | d(omit) }}"))
        (name (jinja "{{ item.name | d(omit) }}"))
        (requirements (jinja "{{ item.requirements | d(omit) }}"))
        (state (jinja "{{ item.state | d(omit) }}"))
        (umask (jinja "{{ item.umask | d(omit) }}"))
        (version (jinja "{{ item.version | d(omit) }}"))
        (virtualenv (jinja "{{ item.virtualenv | d(omit) }}"))
        (virtualenv_command (jinja "{{ item.virtualenv_command | d(omit) }}"))
        (virtualenv_python (jinja "{{ item.virtualenv_python | d(omit) }}"))
        (virtualenv_site_packages (jinja "{{ item.virtualenv_site_packages | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", resources__pip
                           + resources__group_pip
                           + resources__host_pip) }}"))
      (become "True")
      (become_user (jinja "{{ item.owner | d(\"root\") }}"))
      (when "(resources__enabled | bool and (item.name | d() or item.requirements is defined) and (item.state | d('present') != 'absent'))")
      (tags (list
          "role::resources:pip")))
    (task "Manage replacements inside files"
      (ansible.builtin.replace 
        (dest (jinja "{{ item.dest | d(item.name | d(item.path)) }}"))
        (after (jinja "{{ item.after | d(omit) }}"))
        (attributes (jinja "{{ item.attributes | d(item.attr | d(omit)) }}"))
        (backup (jinja "{{ item.backup | d(omit) }}"))
        (before (jinja "{{ item.before | d(omit) }}"))
        (encoding (jinja "{{ item.encoding | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (others (jinja "{{ item.others | d(omit) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (regexp (jinja "{{ item.regexp | d(omit) }}"))
        (replace (jinja "{{ item.replace | d(omit) }}"))
        (selevel (jinja "{{ item.selevel | d(omit) }}"))
        (serole (jinja "{{ item.serole | d(omit) }}"))
        (setype (jinja "{{ item.setype | d(omit) }}"))
        (seuser (jinja "{{ item.seuser | d(omit) }}"))
        (unsafe_writes (jinja "{{ item.unsafe_writes | d(omit) }}"))
        (validate (jinja "{{ item.validate | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", resources__replacements
                           + resources__group_replacements
                           + resources__host_replacements) }}"))
      (when "(resources__enabled | bool and item.regexp | d() and (item.dest | d() or item.path | d() or item.name | d()))")
      (tags (list
          "role::resources:lineinfile")))
    (task "Set ACLs on remote hosts"
      (ansible.posix.acl 
        (path (jinja "{{ item.1.path | d(item.0.name) | d(item.0.dest) | d(item.0.path) }}"))
        (default (jinja "{{ item.1.default | d(omit) }}"))
        (entity (jinja "{{ item.1.entity | d(omit) }}"))
        (entry (jinja "{{ item.1.entry | d(omit) }}"))
        (etype (jinja "{{ item.1.etype | d(omit) }}"))
        (permissions (jinja "{{ item.1.permissions | d(omit) }}"))
        (follow (jinja "{{ item.1.follow | d(omit) }}"))
        (recursive (jinja "{{ item.1.recursive | d(omit) }}"))
        (state (jinja "{{ item.1.state | d(\"present\") }}")))
      (loop (jinja "{{ (lookup(\"flattened\",
                    resources__paths
                    + resources__group_paths
                    + resources__host_paths
                    + resources__repositories
                    + resources__group_repositories
                    + resources__host_repositories
                    + resources__urls
                    + resources__group_urls
                    + resources__host_urls
                    + resources__archives
                    + resources__group_archives
                    + resources__host_archives
                    + resources__files
                    + resources__group_files
                    + resources__host_files,
                    wantlist=True))
             | selectattr(\"acl\", \"defined\") | list
             | subelements(\"acl\") }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.0.name | d(item.0.dest) | d(item.0.path)),
                \"acl\": item.1} }}")))
      (when "item.0.state | d('present') != 'absent'")
      (tags (list
          "role::resources:acl")))
    (task "Manage delayed paths on remote hosts"
      (ansible.builtin.file 
        (path (jinja "{{ (item.path | d(item.dest | d(item.name))) | d(item) }}"))
        (state (jinja "{{ item.state | d(\"directory\") }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (selevel (jinja "{{ item.selevel | d(omit) }}"))
        (serole (jinja "{{ item.serole | d(omit) }}"))
        (setype (jinja "{{ item.setype | d(omit) }}"))
        (seuser (jinja "{{ item.seuser | d(omit) }}"))
        (follow (jinja "{{ item.follow | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (src (jinja "{{ item.src | d(omit) }}"))
        (recurse (jinja "{{ item.recurse | d(omit) }}"))
        (attributes (jinja "{{ item.attributes | d(omit) }}"))
        (access_time (jinja "{{ item.access_time | d(omit) }}"))
        (access_time_format (jinja "{{ item.access_time_format | d(resources__time_format) }}"))
        (modification_time (jinja "{{ item.modification_time | d(omit) }}"))
        (modification_time_format (jinja "{{ item.modification_time_format | d(resources__time_format) }}")))
      (loop (jinja "{{ q(\"flattened\", resources__delayed_paths
                           + resources__group_delayed_paths
                           + resources__host_delayed_paths) }}"))
      (when "(resources__enabled | bool and ((item.path | d() or item.dest | d() or item.name | d()) or item))")
      (tags (list
          "role::resources:paths")))
    (task "Set custom file capabilities"
      (community.general.capabilities 
        (path (jinja "{{ item.path | d(item.name) }}"))
        (capability (jinja "{{ item.capability }}"))
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (loop (jinja "{{ q(\"flattened\", resources__combined_file_capabilities) }}"))
      (when "resources__enabled | bool")
      (tags (list
          "role::resources:capabilities")))
    (task "Execute shell commands"
      (ansible.builtin.include_tasks "shell_commands.yml")
      (loop (jinja "{{ q(\"flattened\", resources__combined_commands) | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name} }}")))
      (when "resources__enabled | bool and item.name | d() and item.state | d('present') not in [ 'absent', 'ignore' ]")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}"))
      (tags (list
          "role::resources:commands")))
    (task "Post hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"resources/post_main.yml\") }}")))))
