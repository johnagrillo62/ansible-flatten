(playbook "debops/ansible/roles/opensearch/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Create directories"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ opensearch__user }}"))
        (group (jinja "{{ opensearch__group }}"))
        (mode "0750"))
      (loop (list
          "/etc/opensearch"
          "/var/local/opensearch"
          "/var/log/opensearch")))
    (task "Install OpenSearch from upstream release"
      (block (list
          
          (name "Download release files")
          (ansible.builtin.get_url 
            (url "https://artifacts.opensearch.org/releases/bundle/opensearch/" (jinja "{{ opensearch__version + \"/\" + item }}"))
            (dest "/var/tmp/" (jinja "{{ item }}"))
            (mode "0644"))
          (loop (list
              (jinja "{{ opensearch__tarball }}")
              (jinja "{{ opensearch__tarball }}") ".sig"))
          
          (name "Verify release tarball")
          (ansible.builtin.command "gpg --verify /var/tmp/" (jinja "{{ opensearch__tarball }}") ".sig")
          (become "True")
          (become_user (jinja "{{ opensearch__user }}"))
          (changed_when "False")
          
          (name "Stop service")
          (ansible.builtin.service 
            (name "opensearch")
            (state "stopped"))
          
          (name "Remove old installation directory")
          (ansible.builtin.file 
            (path (jinja "{{ opensearch__installation_directory }}"))
            (state "absent"))
          
          (name "Create new installation directory")
          (ansible.builtin.file 
            (path (jinja "{{ opensearch__installation_directory }}"))
            (state "directory")
            (mode "0755"))
          
          (name "Extract release tarball")
          (ansible.builtin.unarchive 
            (src "/var/tmp/" (jinja "{{ opensearch__tarball }}"))
            (dest (jinja "{{ opensearch__installation_directory }}"))
            (remote_src "True")
            (owner "root")
            (group "root")
            (mode "u=rwX,g=rX,o=rX")
            (extra_opts (list
                "--strip-components=1")))
          (notify (list
              "Refresh host facts"
              "Restart opensearch"))
          
          (name "Install new configuration files")
          (ansible.builtin.copy 
            (src (jinja "{{ opensearch__installation_directory }}") "/config/")
            (dest "/etc/opensearch")
            (remote_src "True")
            (owner "root")
            (group (jinja "{{ opensearch__group }}"))
            (mode "0640"))))
      (when "ansible_local.opensearch.version | d(\"0.0.0\") != opensearch__version"))
    (task "Configure OpenSearch and the JVM"
      (ansible.builtin.template 
        (src "etc/opensearch/" (jinja "{{ item }}") ".j2")
        (dest "/etc/opensearch/" (jinja "{{ item }}"))
        (owner "root")
        (group (jinja "{{ opensearch__group }}"))
        (mode "0640"))
      (loop (list
          "jvm.options"
          "opensearch.yml"))
      (notify (list
          "Restart opensearch")))
    (task "Remove redundant configuration directory"
      (ansible.builtin.file 
        (path (jinja "{{ opensearch__installation_directory }}") "/config")
        (state "absent")))
    (task "Symlink log directory"
      (ansible.builtin.file 
        (path (jinja "{{ opensearch__installation_directory }}") "/logs")
        (src "/var/log/opensearch")
        (state "link")
        (force "True")))
    (task "Generate systemd configuration"
      (ansible.builtin.template 
        (src "etc/systemd/system/opensearch.service.j2")
        (dest "/etc/systemd/system/opensearch.service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload service manager")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/opensearch.fact.j2")
        (dest "/etc/ansible/facts.d/opensearch.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Flush handlers"
      (ansible.builtin.meta "flush_handlers"))
    (task "Start service"
      (ansible.builtin.service 
        (name "opensearch")
        (state "started")
        (enabled "True")))
    (task "Clean up release files"
      (ansible.builtin.file 
        (path "/var/tmp/" (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          (jinja "{{ opensearch__tarball }}")
          (jinja "{{ opensearch__tarball }}") ".sig")))))
