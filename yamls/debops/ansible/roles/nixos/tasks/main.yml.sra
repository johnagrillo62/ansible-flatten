(playbook "debops/ansible/roles/nixos/tasks/main.yml"
  (tasks
    (task "Assert role configuration"
      (ansible.builtin.assert 
        (that (list
            "ansible_distribution == nixos__distribution_string"
            "nixos__config_dir != \"\""
            "nixos__config_dir.startswith(\"/\")"))
        (quiet "True")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "debops.debops.secret")))
    (task "Pre hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"nixos/pre_main.yml\") }}")))
    (task "Convert NixOS directory to a git repository"
      (block (list
          
          (name "Check if NixOS configuration directory is a git repository")
          (ansible.builtin.stat 
            (path (jinja "{{ nixos__config_dir + \"/.git\" }}")))
          (register "nixos__register_nixos_git")
          
          (name "Move NixOS configuration to a backup directory")
          (ansible.posix.synchronize 
            (src (jinja "{{ nixos__config_dir + \"/\" }}"))
            (dest (jinja "{{ nixos__git_backup_dir + \"/\" }}"))
            (rsync_opts (jinja "{{ nixos__git_resync_options }}")))
          (delegate_to (jinja "{{ inventory_hostname }}"))
          (when "not nixos__register_nixos_git.stat.exists | bool and nixos__git_resync | bool")
          
          (name "Clear out NixOS configuration before git clone")
          (ansible.builtin.file 
            (path (jinja "{{ nixos__config_dir }}"))
            (state "absent"))
          (when "not nixos__register_nixos_git.stat.exists | bool and nixos__git_resync | bool")
          
          (name "Manage NixOS configuration using git repositories")
          (ansible.builtin.git 
            (repo (jinja "{{ item.repo }}"))
            (dest (jinja "{{ item.dest | d(nixos__config_dir) }}"))
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
          (loop (jinja "{{ q(\"flattened\", nixos__repositories
                               + nixos__group_repositories
                               + nixos__host_repositories) }}"))
          (notify (list
              "Rebuild NixOS system"))
          (when "item.repo | d() and item.version | d()")
          
          (name "Move old NixOS configuration back to main directory")
          (ansible.posix.synchronize 
            (src (jinja "{{ nixos__git_backup_dir + \"/\" }}"))
            (dest (jinja "{{ nixos__config_dir + \"/\" }}"))
            (delete "False")
            (rsync_opts (jinja "{{ nixos__git_resync_options }}")))
          (delegate_to (jinja "{{ inventory_hostname }}"))
          (when "not nixos__register_nixos_git.stat.exists | bool and nixos__git_resync | bool")
          
          (name "Remove old backup directory")
          (ansible.builtin.file 
            (path (jinja "{{ nixos__git_backup_dir }}"))
            (state "absent"))
          (when "not nixos__register_nixos_git.stat.exists | bool and nixos__git_resync | bool")))
      (when "nixos__repositories | d() or nixos__group_repositories | d() or nixos__host_repositories | d()"))
    (task "Remove NixOS configuration if requested"
      (ansible.builtin.file 
        (path (jinja "{{ nixos__config_dir + \"/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ nixos__combined_configuration | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Rebuild NixOS system"))
      (when "item.state | d(\"present\") == 'absent'"))
    (task "Create directories for NixOS configuration files"
      (ansible.builtin.file 
        (path (jinja "{{ nixos__config_dir + \"/\" + (item.name | dirname) }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ nixos__combined_configuration | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name | dirname, \"state\": item.state | d(\"present\")} }}")))
      (when "item.raw | d() and item.state | d(\"present\") not in ['absent', 'ignore', 'init'] and item.name is search('/')"))
    (task "Generate NixOS configuration files"
      (ansible.builtin.template 
        (src "etc/nixos/template.nix.j2")
        (dest (jinja "{{ nixos__config_dir + \"/\" + item.name }}"))
        (mode (jinja "{{ item.mode | d(\"0644\") }}")))
      (loop (jinja "{{ nixos__combined_configuration | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Rebuild NixOS system"))
      (when "item.raw | d() and item.state | d(\"present\") not in ['absent', 'ignore', 'init']"))
    (task "Ensure that template directories exist"
      (ansible.builtin.file 
        (path "/" (jinja "{{ item.path }}"))
        (mode (jinja "{{ item.mode }}"))
        (state "directory"))
      (with_community.general.filetree (jinja "{{ (nixos__host_templates
                                        + nixos__group_templates
                                        + nixos__templates) | flatten }}"))
      (loop_control 
        (label (jinja "{{ {\"path\": item.path, \"state\": item.state, \"mode\": item.mode} }}")))
      (notify (list
          "Rebuild NixOS system"))
      (when "item.state == 'directory'"))
    (task "Generate custom templates"
      (ansible.builtin.template 
        (src (jinja "{{ item.src }}"))
        (dest "/" (jinja "{{ item.path }}"))
        (mode (jinja "{{ item.mode }}")))
      (with_community.general.filetree (jinja "{{ (nixos__host_templates
                                        + nixos__group_templates
                                        + nixos__templates) | flatten }}"))
      (loop_control 
        (label (jinja "{{ {\"path\": item.path, \"state\": item.state, \"mode\": item.mode} }}")))
      (notify (list
          "Rebuild NixOS system"))
      (when "item.state == 'file'"))
    (task "Recreate custom symlinks"
      (ansible.builtin.file 
        (src (jinja "{{ item.src }}"))
        (dest "/" (jinja "{{ item.path }}"))
        (mode (jinja "{{ item.mode }}"))
        (state "link")
        (force "True"))
      (with_community.general.filetree (jinja "{{ (nixos__host_templates
                                        + nixos__group_templates
                                        + nixos__templates) | flatten }}"))
      (loop_control 
        (label (jinja "{{ {\"path\": item.path, \"state\": item.state, \"mode\": item.mode} }}")))
      (notify (list
          "Rebuild NixOS system"))
      (when "item.state == 'link'"))
    (task "Flush handlers when needed"
      (ansible.builtin.meta "flush_handlers"))
    (task "Post hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"nixos/post_main.yml\") }}")))))
