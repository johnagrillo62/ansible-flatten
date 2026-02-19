(playbook "debops/ansible/roles/reprepro/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install packages for Debian repository management"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (reprepro__base_packages + reprepro__packages)) }}"))
        (state "present"))
      (register "reprepro__register_packages")
      (until "reprepro__register_packages is succeeded"))
    (task "Create UNIX system group for reprepro"
      (ansible.builtin.group 
        (name (jinja "{{ reprepro__group }}"))
        (system "True")
        (state "present")))
    (task "Create UNIX system account for reprepro"
      (ansible.builtin.user 
        (name (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (groups (jinja "{{ reprepro__additional_groups }}"))
        (append "True")
        (system "True")
        (shell "/bin/bash")
        (home (jinja "{{ reprepro__home }}"))
        (comment (jinja "{{ reprepro__comment }}"))
        (state "present")))
    (task "Add admin SSH keys to reprepro UNIX account"
      (ansible.posix.authorized_key 
        (key (jinja "{{ (reprepro__admin_sshkeys
              if reprepro__admin_sshkeys is string
              else '\\n'.join(q('flattened', reprepro__admin_sshkeys))) | string }}"))
        (state "present")
        (user (jinja "{{ reprepro__user }}"))
        (exclusive "False"))
      (when "reprepro__admin_sshkeys | d()"))
    (task "Generate queue processing services"
      (ansible.builtin.template 
        (src (jinja "{{ \"etc/systemd/system/\" + item + \".j2\" }}"))
        (dest (jinja "{{ \"/etc/systemd/system/\" + item }}"))
        (mode "0644"))
      (loop (list
          "reprepro-incoming@.service"
          "reprepro-incoming@.path"))
      (notify (list
          "Reload systemd daemon"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Flush handlers when needed"
      (ansible.builtin.meta "flush_handlers"))
    (task "Manage the GnuPG environment for reprepro"
      (ansible.builtin.import_tasks "configure_gnupg.yml"))
    (task "Manage reprepro instances"
      (ansible.builtin.include_tasks "configure_reprepro.yml")
      (loop_control 
        (loop_var "repo")
        (label (jinja "{{ {\"name\": repo.name, \"state\": repo.state | d(\"present\"),
                \"outdir\": (repo.outdir | d(reprepro__public_root + \"/sites/\" + repo.name + \"/public\"))} }}")))
      (loop (jinja "{{ q(\"flattened\", reprepro__combined_instances)
            | debops.debops.parse_kv_items(merge_keys=[\"distributions\", \"incoming\", \"pulls\", \"updates\"]) }}")))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Generate reprepro Ansible local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/reprepro.fact.j2")
        (dest "/etc/ansible/facts.d/reprepro.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Refresh host facts when needed"
      (ansible.builtin.meta "flush_handlers"))))
