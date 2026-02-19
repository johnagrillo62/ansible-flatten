(playbook "debops/ansible/roles/neurodebian/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Configure NeuroDebian APT repository"
      (ansible.builtin.template 
        (src "etc/apt/sources.list.d/neurodebian.sources.list.j2")
        (dest "/etc/apt/sources.list.d/neurodebian.sources.list")
        (mode "0644"))
      (register "neurodebian__register_apt_repository")
      (when "(neurodebian__deploy_state == \"present\" and neurodebian__upstream | bool)"))
    (task "Ensure the NeuroDebian APT repository is disabled"
      (ansible.builtin.file 
        (path "/etc/apt/sources.list.d/neurodebian.sources.list")
        (state "absent"))
      (register "neurodebian__register_apt_repository_absent")
      (when "(neurodebian__deploy_state == \"absent\" and neurodebian__upstream | bool)"))
    (task "Configure NeuroDebian support in debconf"
      (ansible.builtin.debconf 
        (name "neurodebian")
        (question "neurodebian/enable")
        (vtype "boolean")
        (value (jinja "{{ \"true\" if (neurodebian__deploy_state == \"present\") else \"false\" }}")))
      (when "not neurodebian__upstream | bool"))
    (task "Install packages required for NeuroDebian support"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", neurodebian__support_packages) }}"))
        (state "present"))
      (register "neurodebian__register_support_packages")
      (until "neurodebian__register_support_packages is succeeded")
      (when "(neurodebian__deploy_state == \"present\" and not neurodebian__upstream | bool)"))
    (task "Update APT repository cache"
      (ansible.builtin.apt 
        (update_cache "True"))
      (register "neurodebian__register_apt_update")
      (until "neurodebian__register_apt_update is succeeded")
      (when "neurodebian__register_apt_repository is changed or neurodebian__register_apt_repository_absent is changed or neurodebian__register_support_packages is changed"))
    (task "Ensure specified packages are in their desired state"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (neurodebian__packages
                              + neurodebian__group_packages
                              + neurodebian__host_packages
                              + neurodebian__dependent_packages)) }}"))
        (state (jinja "{{ \"present\" if (neurodebian__deploy_state == \"present\") else \"absent\" }}")))
      (register "neurodebian__register_packages")
      (until "neurodebian__register_packages is succeeded")
      (tags (list
          "role::neurodebian:package")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save NeuroDebian local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/neurodebian.fact.j2")
        (dest "/etc/ansible/facts.d/neurodebian.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
