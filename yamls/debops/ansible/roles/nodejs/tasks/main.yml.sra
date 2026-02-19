(playbook "debops/ansible/roles/nodejs/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Remove conflicting APT packages"
      (ansible.builtin.apt 
        (name (jinja "{{ q(\"flattened\", nodejs__remove_packages) }}"))
        (state "absent")
        (purge "True"))
      (when "ansible_pkg_mgr == 'apt'"))
    (task "Install APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (nodejs__base_packages
                              + nodejs__packages
                              + nodejs__group_packages
                              + nodejs__host_packages
                              + nodejs__dependent_packages)) }}"))
        (state (jinja "{{ \"latest\"
               if (nodejs__node_upstream | bool and
                   (ansible_local | d() and ansible_local.nodejs | d() and
                    ansible_local.nodejs.node_upstream is defined and
                    not ansible_local.nodejs.node_upstream | bool))
               else \"present\" }}"))
        (autoremove (jinja "{{ True
                    if (nodejs__node_upstream | bool and
                        (ansible_local | d() and ansible_local.nodejs | d() and
                         ansible_local.nodejs.node_upstream is defined and
                         not ansible_local.nodejs.node_upstream | bool))
                    else omit }}")))
      (notify (list
          "Refresh host facts"))
      (register "nodejs__register_packages")
      (until "nodejs__register_packages is succeeded"))
    (task "Maintain 'yarn' symlink for the 'yarnpkg' package"
      (ansible.builtin.file 
        (path "/usr/local/bin/yarn")
        (src (jinja "{{ omit if nodejs__yarn_upstream | bool else \"/usr/bin/yarnpkg\" }}"))
        (state (jinja "{{ \"absent\" if nodejs__yarn_upstream | bool else \"link\" }}"))
        (mode "0755")))
    (task "Install NPM packages"
      (community.general.npm 
        (name (jinja "{{ item.name | d(item) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (global (jinja "{{ (item.global | d(True)) | bool }}"))
        (production (jinja "{{ (item.production | d(nodejs__npm_production_mode)) | bool }}"))
        (version (jinja "{{ item.version | d(omit) }}"))
        (registry (jinja "{{ item.registry | d(omit) }}"))
        (executable (jinja "{{ item.executable | d(omit) }}"))
        (ignore_scripts (jinja "{{ item.ignore_scripts | d(omit) }}"))
        (path (jinja "{{ item.path | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", nodejs__npm_packages
                           + nodejs__npm_group_packages
                           + nodejs__npm_host_packages
                           + nodejs__npm_dependent_packages) }}")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Node.js local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/nodejs.fact.j2")
        (dest "/etc/ansible/facts.d/nodejs.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
