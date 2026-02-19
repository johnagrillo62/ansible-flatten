(playbook "ansible-examples/tomcat-standalone/roles/selinux/tasks/main.yml"
  (tasks
    (task "Download EPEL Repo - Centos/RHEL 6"
      (get_url "url=http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm dest=/tmp/epel-release-latest-6.noarch.rpm")
      (when "ansible_os_family == 'RedHat' and ansible_distribution_major_version == '6'"))
    (task "Install EPEL Repo - Centos/RHEL 6"
      (command "rpm -ivh /tmp/epel-release-latest-6.noarch.rpm creates=/etc/yum.repos.d/epel.repo")
      (when "ansible_os_family == 'RedHat' and ansible_distribution_major_version == '6'"))
    (task "Download EPEL Repo - Centos/RHEL 7"
      (get_url "url=http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm dest=/tmp/epel-release-latest-7.noarch.rpm")
      (when "ansible_os_family == 'RedHat' and ansible_distribution_major_version == '7'"))
    (task "Install EPEL Repo - Centos/RHEL 7"
      (command "rpm -ivh /tmp/epel-release-latest-7.noarch.rpm creates=/etc/yum.repos.d/epel.repo")
      (when "ansible_os_family == 'RedHat' and ansible_distribution_major_version == '7'"))
    (task "Install libselinux-python"
      (yum "name=libselinux-python"))))
