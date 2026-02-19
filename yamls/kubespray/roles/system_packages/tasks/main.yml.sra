(playbook "kubespray/roles/system_packages/tasks/main.yml"
  (tasks
    (task "Gather OS information"
      (setup 
        (gather_subset (list
            "distribution"
            "pkg_mgr"))))
    (task "Update package management cache (zypper) - SUSE"
      (command "zypper -n --gpg-auto-import-keys ref")
      (register "make_cache_output")
      (until "make_cache_output is succeeded")
      (retries "4")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (when (list
          "ansible_pkg_mgr == 'zypper'"))
      (tags "bootstrap_os"))
    (task "Remove legacy docker repo file"
      (file 
        (path (jinja "{{ yum_repo_dir }}") "/docker.repo")
        (state "absent"))
      (when (list
          "ansible_os_family == \"RedHat\""
          "not is_fedora_coreos")))
    (task "Install epel-release on RHEL derivatives"
      (package 
        (name "epel-release")
        (state "present"))
      (when (list
          "ansible_os_family == \"RedHat\""
          "not is_fedora_coreos"
          "epel_enabled | bool"))
      (tags (list
          "bootstrap_os")))
    (task "Install python3-libdnf5 on Fedora >= 41"
      (raw "dnf install --assumeyes python3-libdnf5
")
      (become "true")
      (retries (jinja "{{ pkg_install_retries }}"))
      (when (list
          "ansible_distribution == \"Fedora\""
          "ansible_distribution_major_version | int >= 41")))
    (task "Manage packages"
      (package 
        (name (jinja "{{ item.packages | dict2items | selectattr('value', 'ansible.builtin.all') | map(attribute='key') }}"))
        (state (jinja "{{ item.state }}"))
        (update_cache (jinja "{{ true if ansible_pkg_mgr in ['zypper', 'apt', 'dnf'] else omit }}"))
        (cache_valid_time (jinja "{{ 86400 if ansible_pkg_mgr == 'apt' else omit }}")))
      (timeout (jinja "{{ pkg_install_timeout }}"))
      (register "pkgs_task_result")
      (until "pkgs_task_result is succeeded")
      (retries (jinja "{{ pkg_install_retries }}"))
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (when "not (ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"] or is_fedora_coreos)")
      (loop (list
          
          (packages (jinja "{{ pkgs_to_remove }}"))
          (state "absent")
          (action_label "remove")
          
          (packages (jinja "{{ pkgs }}"))
          (state "present")
          (action_label "install")))
      (loop_control 
        (label (jinja "{{ item.action_label }}")))
      (tags (list
          "bootstrap_os")))))
