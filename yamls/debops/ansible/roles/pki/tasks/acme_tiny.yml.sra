(playbook "debops/ansible/roles/pki/tasks/acme_tiny.yml"
  (tasks
    (task "Create ACME system group"
      (ansible.builtin.group 
        (name (jinja "{{ pki_acme_group }}"))
        (state "present")
        (system "True")))
    (task "Create ACME system account"
      (ansible.builtin.user 
        (name (jinja "{{ pki_acme_user }}"))
        (group (jinja "{{ pki_acme_group }}"))
        (home (jinja "{{ pki_acme_home }}"))
        (state "present")
        (system "True")
        (createhome "False")
        (shell "/bin/false")))
    (task "Install acme-tiny from source"
      (block (list
          
          (name "Create source directory")
          (ansible.builtin.file 
            (path (jinja "{{ pki_acme_tiny_src }}"))
            (state "directory")
            (owner "root")
            (group "root")
            (mode "0755"))
          
          (name "Clone acme-tiny source code")
          (ansible.builtin.git 
            (repo (jinja "{{ pki_acme_tiny_repo }}"))
            (dest (jinja "{{ pki_acme_tiny_src + \"/acme-tiny\" }}"))
            (version (jinja "{{ pki_acme_tiny_version }}")))
          
          (name "Install acme-tiny script")
          (ansible.builtin.file 
            (path (jinja "{{ pki_acme_tiny_bin }}"))
            (src (jinja "{{ pki_acme_tiny_src }}") "/acme-tiny/acme_tiny.py")
            (state "link")
            (force "True")
            (mode "0755"))))
      (when "ansible_distribution_release in [\"stretch\", \"buster\", \"bookworm\", \"trusty\", \"xenial\", \"bionic\"]"))
    (task "Create ACME challenge path"
      (ansible.builtin.file 
        (path (jinja "{{ pki_acme_challenge_dir | dirname }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "pki_create_acme_challenge_dir"))
    (task "Create ACME challenge directory"
      (ansible.builtin.file 
        (path (jinja "{{ pki_acme_challenge_dir }}"))
        (state "directory")
        (owner (jinja "{{ pki_acme_user }}"))
        (group (jinja "{{ pki_acme_group }}"))
        (mode "0755"))
      (when "pki_create_acme_challenge_dir"))))
