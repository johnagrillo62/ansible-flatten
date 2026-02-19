(playbook "kubespray/roles/bootstrap_os/tasks/centos.yml"
  (tasks
    (task "Gather host facts to get ansible_distribution_version ansible_distribution_major_version"
      (setup 
        (gather_subset "!all")
        (filter "ansible_distribution_*version")))
    (task "Add proxy to yum.conf or dnf.conf if http_proxy is defined"
      (community.general.ini_file 
        (path (jinja "{{ ((ansible_distribution_major_version | int) < 8) | ternary('/etc/yum.conf', '/etc/dnf/dnf.conf') }}"))
        (section "main")
        (option "proxy")
        (value (jinja "{{ http_proxy | default(omit) }}"))
        (state (jinja "{{ http_proxy | default(False) | ternary('present', 'absent') }}"))
        (no_extra_spaces "true")
        (mode "0644"))
      (become "true")
      (when "not skip_http_proxy_on_os_packages"))
    (task "Install EPEL for Oracle Linux repo package"
      (package 
        (name "oracle-epel-release-el" (jinja "{{ ansible_distribution_major_version }}"))
        (state "present"))
      (when (list
          "use_oracle_public_repo | default(true)"
          "'ID=\"ol\"' in os_release.stdout_lines"
          "(ansible_distribution_version | float) >= 7.6")))
    (task "Enable Oracle Linux repo"
      (community.general.ini_file 
        (dest "/etc/yum.repos.d/oracle-linux-ol" (jinja "{{ ansible_distribution_major_version }}") ".repo")
        (section "ol" (jinja "{{ ansible_distribution_major_version }}") "_addons")
        (option (jinja "{{ item.option }}"))
        (value (jinja "{{ item.value }}"))
        (mode "0644"))
      (with_items (list
          
          (option "name")
          (value "ol" (jinja "{{ ansible_distribution_major_version }}") "_addons")
          
          (option "enabled")
          (value "1")
          
          (option "baseurl")
          (value "http://yum.oracle.com/repo/OracleLinux/OL" (jinja "{{ ansible_distribution_major_version }}") "/addons/$basearch/")))
      (when (list
          "use_oracle_public_repo | default(true)"
          "'ID=\"ol\"' in os_release.stdout_lines"
          "(ansible_distribution_version | float) >= 7.6")))
    (task "Enable Centos extra repo for Oracle Linux"
      (community.general.ini_file 
        (dest "/etc/yum.repos.d/centos-extras.repo")
        (section "extras")
        (option (jinja "{{ item.option }}"))
        (value (jinja "{{ item.value }}"))
        (mode "0644"))
      (with_items (list
          
          (option "name")
          (value "CentOS-" (jinja "{{ ansible_distribution_major_version }}") " - Extras")
          
          (option "enabled")
          (value "1")
          
          (option "gpgcheck")
          (value "0")
          
          (option "baseurl")
          (value "http://mirror.centos.org/centos/" (jinja "{{ ansible_distribution_major_version }}") "/extras/$basearch/os/")))
      (when (list
          "use_oracle_public_repo | default(true)"
          "'ID=\"ol\"' in os_release.stdout_lines"
          "(ansible_distribution_version | float) >= 7.6"
          "(ansible_distribution_version | float) < 9")))
    (task "Check presence of fastestmirror.conf"
      (stat 
        (path "/etc/yum/pluginconf.d/fastestmirror.conf")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "fastestmirror"))
    (task "Disable fastestmirror plugin if requested"
      (lineinfile 
        (dest "/etc/yum/pluginconf.d/fastestmirror.conf")
        (regexp "^enabled=.*")
        (line "enabled=0")
        (state "present"))
      (become "true")
      (when (list
          "fastestmirror.stat.exists"
          "not centos_fastestmirror_enabled")))))
