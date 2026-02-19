(playbook "debops/ansible/roles/ruby/tasks/main.yml"
  (tasks
    (task "Install Ruby packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (ruby__base_packages
                              + ruby__dev_packages
                              + ruby__packages
                              + ruby__group_packages
                              + ruby__host_packages
                              + ruby__dependent_packages)) }}"))
        (state "present"))
      (register "ruby__register_packages")
      (until "ruby__register_packages is succeeded"))
    (task "Install Ruby gems"
      (community.general.gem 
        (name (jinja "{{ item.name if item.name | d() else item }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (user_install (jinja "{{ item.user_install | d(False) }}"))
        (version (jinja "{{ item.version | d(omit) }}"))
        (repository (jinja "{{ item.repository | d(omit) }}"))
        (include_doc (jinja "{{ item.include_doc | d(omit) }}"))
        (build_flags (jinja "{{ item.build_flags | d(omit) }}"))
        (executable (jinja "{{ item.executable | d(omit) }}"))
        (include_dependencies (jinja "{{ item.include_dependencies | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", ruby__gems
                           + ruby__group_gems
                           + ruby__host_gems
                           + ruby__dependent_gems) }}")))
    (task "Make sure that required groups exist"
      (ansible.builtin.group 
        (name (jinja "{{ item.group | d(item.owner) }}"))
        (system (jinja "{{ (item.system | d(True)) | bool }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", ruby__user_gems
                           + ruby__group_user_gems
                           + ruby__host_user_gems
                           + ruby__dependent_user_gems) }}"))
      (when "(item.group | d() or item.owner | d())"))
    (task "Make sure that required users exist"
      (ansible.builtin.user 
        (name (jinja "{{ item.owner }}"))
        (group (jinja "{{ item.group | d(item.owner) }}"))
        (home (jinja "{{ item.home | d((ansible_local.fhs.home | d(\"/var/local\"))
                            + \"/\" + item.owner) }}"))
        (system (jinja "{{ (item.system | d(True)) | bool }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", ruby__user_gems
                           + ruby__group_user_gems
                           + ruby__host_user_gems
                           + ruby__dependent_user_gems) }}"))
      (when "item.owner | d()"))
    (task "Install Ruby user gems"
      (community.general.gem 
        (name (jinja "{{ item.name }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (user_install (jinja "{{ item.user_install | d(True) }}"))
        (version (jinja "{{ item.version | d(omit) }}"))
        (repository (jinja "{{ item.repository | d(omit) }}"))
        (include_doc (jinja "{{ item.include_doc | d(omit) }}"))
        (build_flags (jinja "{{ item.build_flags | d(omit) }}"))
        (executable (jinja "{{ item.executable | d(omit) }}"))
        (include_dependencies (jinja "{{ item.include_dependencies | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", ruby__user_gems
                           + ruby__group_user_gems
                           + ruby__host_user_gems
                           + ruby__dependent_user_gems) }}"))
      (become "True")
      (become_user (jinja "{{ item.user | d(item.owner) }}"))
      (when "(item.user | d() or item.owner | d())"))))
