(playbook "debops/ansible/roles/gunicorn/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Configure Green Unicorn on older OS releases"
      (ansible.builtin.include_tasks "older_releases.yml")
      (when "ansible_distribution_release in [ 'trusty', 'xenial' ]"))
    (task "Configure Green Unicorn on newer OS releases"
      (ansible.builtin.include_tasks "newer_releases.yml")
      (when "ansible_distribution_release not in [ 'trusty', 'xenial' ]"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save gunicorn local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/gunicorn.fact.j2")
        (dest "/etc/ansible/facts.d/gunicorn.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
