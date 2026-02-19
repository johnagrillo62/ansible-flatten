(playbook "debops/ansible/roles/apt_install/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Pre hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"apt_install/pre_main.yml\") }}")))
    (task "Make sure that Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "apt_install__enabled | bool"))
    (task "Save local Ansible facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/apt_install.fact.j2")
        (dest "/etc/ansible/facts.d/apt_install.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "apt_install__enabled | bool")
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Debconf module dependencies"
      (ansible.builtin.apt 
        (name (list
            "debconf"
            "debconf-utils"))
        (state "present")
        (install_recommends (jinja "{{ apt_install__recommends | bool }}")))
      (register "apt_install__register_debconf_packages")
      (until "apt_install__register_debconf_packages is succeeded"))
    (task "Apply requested packages configuration"
      (ansible.builtin.debconf 
        (name (jinja "{{ item.name }}"))
        (question (jinja "{{ item.question | d(omit) }}"))
        (selection (jinja "{{ item.selection | d(omit) }}"))
        (setting (jinja "{{ item.setting | d(omit) }}"))
        (unseen (jinja "{{ item.unseen | d(omit) }}"))
        (value (jinja "{{ item.value | d(omit) }}"))
        (answer (jinja "{{ item.answer | d(omit) }}"))
        (vtype (jinja "{{ item.vtype | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", apt_install__debconf
                           + apt_install__group_debconf
                           + apt_install__host_debconf) }}"))
      (when "item.name | d()"))
    (task "Install requested APT packages"
      (ansible.builtin.apt 
        (name (jinja "{{ q(\"flattened\", lookup(\"template\",
                             \"lookup/apt_install__all_packages.j2\",
                             convert_data=False) | from_yaml) }}"))
        (state (jinja "{{ apt_install__state }}"))
        (install_recommends (jinja "{{ apt_install__recommends | bool }}"))
        (update_cache (jinja "{{ apt_install__update_cache | bool }}"))
        (cache_valid_time (jinja "{{ apt_install__cache_valid_time }}")))
      (register "apt_install__register_packages")
      (until "apt_install__register_packages is succeeded")
      (when "apt_install__enabled | bool"))
    (task "Configure alternative symlinks"
      (community.general.alternatives 
        (name (jinja "{{ item.name }}"))
        (path (jinja "{{ item.path }}"))
        (link (jinja "{{ item.link | d(omit) }}"))
        (priority (jinja "{{ item.priority | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", apt_install__default_alternatives
                           + apt_install__alternatives
                           + apt_install__group_alternatives
                           + apt_install__host_alternatives) }}"))
      (when "item.name | d() and item.path | d()"))
    (task "Configure automatic alternatives"
      (ansible.builtin.command "update-alternatives --auto " (jinja "{{ item.name }}"))
      (register "apt_install__register_alternatives")
      (loop (jinja "{{ q(\"flattened\", apt_install__alternatives
                           + apt_install__group_alternatives
                           + apt_install__host_alternatives) }}"))
      (when "item.name | d() and not item.path | d()")
      (changed_when "apt_install__register_alternatives.stdout | d()"))
    (task "Disable kernel hints about pending upgrades"
      (ansible.builtin.template 
        (src "etc/needrestart/conf.d/no-kernel-hints.conf.j2")
        (dest "/etc/needrestart/conf.d/no-kernel-hints.conf")
        (mode "0644"))
      (when "apt_install__enabled | bool and apt_install__no_kernel_hints | bool"))
    (task "Post hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"apt_install/post_main.yml\") }}")))))
