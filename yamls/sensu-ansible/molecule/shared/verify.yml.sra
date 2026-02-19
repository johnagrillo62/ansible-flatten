(playbook "sensu-ansible/molecule/shared/verify.yml"
    (play
    (name "Verify")
    (hosts "all")
    (become "true")
    (vars
      (inspec_download_source_dir "/usr/local/src")
      (inspec_bin "/opt/inspec/bin/inspec")
      (inspec_test_directory "/tmp/molecule/inspec")
      (inspec_downloads 
        (el6 
          (url "https://packages.chef.io/files/stable/inspec/3.6.6/el/6/inspec-3.6.6-1.el6.x86_64.rpm")
          (sha256 "69b05dd28304b7c915381b88f035b3239d1328d891faef18aa30954266fc4da2"))
        (el7 
          (url "https://packages.chef.io/files/stable/inspec/3.6.6/el/7/inspec-3.6.6-1.el7.x86_64.rpm")
          (sha256 "2a950a2aeecf2c26b16285a2fcec244da97c636d47d5928ee181620e80472cac"))
        (ubuntu1404 
          (url "https://packages.chef.io/files/stable/inspec/3.6.6/ubuntu/14.04/inspec_3.6.6-1_amd64.deb")
          (sha256 "4294bdd3f8cd1aff3e6d912d2c48b345d0ec60ecefd92310cb3ae561b909cfec"))
        (ubuntu1604 
          (url "https://packages.chef.io/files/stable/inspec/3.6.6/ubuntu/16.04/inspec_3.6.6-1_amd64.deb")
          (sha256 "4294bdd3f8cd1aff3e6d912d2c48b345d0ec60ecefd92310cb3ae561b909cfec"))
        (ubuntu1804 
          (url "https://packages.chef.io/files/stable/inspec/3.6.6/ubuntu/18.04/inspec_3.6.6-1_amd64.deb")
          (sha256 "4294bdd3f8cd1aff3e6d912d2c48b345d0ec60ecefd92310cb3ae561b909cfec")))
      (inspec_package_deps (list
          "lsof"
          "net-tools")))
    (tasks
      (task "Install system dependencies for Inspec"
        (package 
          (name (jinja "{{ item }}"))
          (state "present"))
        (loop (jinja "{{ inspec_package_deps }}")))
      (task "Download Inspec"
        (get_url 
          (url (jinja "{{ inspec_downloads[inspec_version]['url'] }}"))
          (dest (jinja "{{ inspec_download_source_dir }}"))
          (sha256sum (jinja "{{ inspec_downloads[inspec_version]['sha256'] }}"))
          (mode "0755"))
        (register "inspec_download"))
      (task "Install Inspec"
        (yum 
          (name (jinja "{{ inspec_download.dest }}"))
          (state "latest"))
        (when "ansible_pkg_mgr == 'yum'"))
      (task "Install Inspec"
        (dnf 
          (name (jinja "{{ inspec_download.dest }}"))
          (state "latest"))
        (when "ansible_pkg_mgr == 'dnf'"))
      (task "Install Inspec"
        (apt 
          (deb (jinja "{{ inspec_download.dest }}"))
          (state "present"))
        (when "ansible_pkg_mgr == 'apt'"))
      (task "Create Molecule directory for test files"
        (file 
          (path (jinja "{{ inspec_test_directory }}"))
          (state "directory")))
      (task "Copy Inspec tests to remote"
        (copy 
          (src (jinja "{{ item }}"))
          (dest (jinja "{{ inspec_test_directory }}") "/" (jinja "{{ item | basename }}")))
        (with_fileglob (list
            (jinja "{{ playbook_dir }}") "/tests/test_*.rb")))
      (task "Register test files"
        (shell "ls " (jinja "{{ inspec_test_directory }}") "/test_*.rb")
        (register "test_files"))
      (task "Execute Inspec tests"
        (command (jinja "{{ inspec_bin }}") " exec " (jinja "{{ item }}") " --no-color --reporter progress")
        (register "test_results")
        (loop (jinja "{{ test_files.stdout_lines }}"))
        (ignore_errors "true"))
      (task "Display details about the Inspec results"
        (debug 
          (msg (jinja "{{ item.stdout_lines }}")))
        (loop (jinja "{{ test_results.results }}")))
      (task "Fail when tests fail"
        (fail 
          (msg "Inspec failed to validate"))
        (when "item.rc != 0")
        (loop (jinja "{{ test_results.results }}"))))))
