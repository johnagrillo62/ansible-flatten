(playbook "debops/ansible/roles/reprepro/tasks/configure_reprepro.yml"
  (tasks
    (task "Create reprepro spool directory"
      (ansible.builtin.file 
        (path (jinja "{{ reprepro__spool_root + \"/\" + repo.name }}"))
        (state "directory")
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0755"))
      (when "repo.state | d('present') not in ['absent', 'ignore']"))
    (task "Create directory for reprepro uploads"
      (ansible.builtin.file 
        (path (jinja "{{ reprepro__spool_root + \"/\" + repo.name + \"/incoming\" }}"))
        (state "directory")
        (owner (jinja "{{ reprepro__user }}"))
        (group "www-data")
        (mode "0730"))
      (when "repo.state | d('present') not in ['absent', 'ignore']"))
    (task "Create reprepro internal directories"
      (ansible.builtin.file 
        (path (jinja "{{ reprepro__data_root + \"/\" + repo.name + \"/\" + item }}"))
        (state "directory")
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0755"))
      (loop (list
          "conf/uploaders"
          "tmp"))
      (when "repo.state | d('present') not in ['absent', 'ignore']"))
    (task "Create public reprepro repository"
      (ansible.builtin.file 
        (path (jinja "{{ reprepro__public_root + \"/sites/\" + repo.name + \"/public\" }}"))
        (state "directory")
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0755"))
      (when "repo.state | d('present') not in ['absent', 'ignore'] and not repo.outdir | d()"))
    (task "Copy GPG public key to public space"
      (ansible.builtin.copy 
        (src (jinja "{{ reprepro__home + \"/\" + reprepro__gpg_public_filename }}"))
        (dest (jinja "{{ reprepro__public_root + \"/sites/\" + repo.name + \"/public/\" + reprepro__gpg_public_filename }}"))
        (remote_src "True")
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0644"))
      (when "repo.state | d('present') not in ['absent', 'ignore'] and not repo.outdir | d()"))
    (task "Manage reprepro configuration files"
      (ansible.builtin.template 
        (src "home/reprepro/repositories/instance/conf/" (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ reprepro__data_root + \"/\" + repo.name + \"/conf/\" + item }}"))
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0644"))
      (loop (list
          "distributions"
          "incoming"
          "options"
          "pulls"
          "updates"))
      (register "reprepro__register_config")
      (when "(repo.state | d('present') not in ['absent', 'ignore'] and (item in repo.keys() or item in ['options']))"))
    (task "Configure uploaders configuration files"
      (ansible.builtin.template 
        (src "home/reprepro/repositories/instance/conf/uploaders/template.j2")
        (dest (jinja "{{ reprepro__data_root + \"/\" + repo.name + \"/conf/uploaders/\" + item.name }}"))
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0644"))
      (loop (jinja "{{ repo.uploaders }}"))
      (register "reprepro__register_uploaders")
      (when "repo.state | d('present') not in ['absent', 'ignore'] and 'uploaders' in repo.keys()"))
    (task "Initialize reprepro repositories"
      (ansible.builtin.command "reprepro export")
      (args 
        (chdir (jinja "{{ reprepro__data_root + \"/\" + repo.name }}")))
      (become "True")
      (become_user (jinja "{{ reprepro__user }}"))
      (register "reprepro__register_export")
      (changed_when "reprepro__register_export.changed | bool")
      (when "(repo.state | d('present') not in ['absent', 'ignore'] and repo.distributions | d() and (reprepro__register_config is changed or reprepro__register_uploaders is changed))"))
    (task "Generate symlinks"
      (ansible.builtin.command "reprepro --delete createsymlinks")
      (args 
        (chdir (jinja "{{ reprepro__data_root + \"/\" + repo.name }}")))
      (become "True")
      (become_user (jinja "{{ reprepro__user }}"))
      (changed_when "False")
      (when "(repo.state | d('present') not in ['absent', 'ignore'] and repo.distributions | d())"))
    (task "Enable incoming queue monitoring"
      (ansible.builtin.systemd 
        (name (jinja "{{ \"reprepro-incoming@\" + repo.name + \".path\" }}"))
        (state (jinja "{{ \"started\"
               if (repo.state | d(\"present\") not in [\"absent\", \"ignore\"])
               else \"stopped\" }}"))
        (enabled (jinja "{{ True
               if (repo.state | d(\"present\") not in [\"absent\", \"ignore\"])
               else False }}")))
      (when "repo.incoming | d()"))
    (task "Manage reprepro scripts"
      (ansible.builtin.template 
        (src "home/reprepro/repositories/instance/conf/" (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ reprepro__data_root + \"/\" + repo.name + \"/conf/\" + item }}"))
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0755"))
      (with_items (list
          "email-changes.sh"))
      (when "repo.state | d('present') not in ['absent', 'ignore']"))))
