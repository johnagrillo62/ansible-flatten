(playbook "ansible-examples/mongodb/roles/common/tasks/main.yml"
  (tasks
    (task "Create the hosts file for all machines"
      (template "src=hosts.j2 dest=/etc/hosts"))
    (task "Create the repository for 10Gen"
      (copy "src=10gen.repo.j2 dest=/etc/yum.repos.d/10gen.repo"))
    (task "Create the EPEL Repository."
      (copy "src=epel.repo.j2 dest=/etc/yum.repos.d/epel.repo"))
    (task "Create the GPG key for EPEL"
      (copy "src=RPM-GPG-KEY-EPEL-6 dest=/etc/pki/rpm-gpg"))
    (task "Create the mongod user"
      (user "name=mongod comment=\"MongoD\""))
    (task "Create the data directory for the namenode metadata"
      (file "path=" (jinja "{{ mongodb_datadir_prefix }}") " owner=mongod group=mongod state=directory"))
    (task "Install the mongodb package"
      (yum "name=" (jinja "{{ item }}") " state=installed")
      (with_items (list
          "libselinux-python"
          "mongo-10gen"
          "mongo-10gen-server"
          "bc"
          "python-pip")))
    (task "Install the latest pymongo package"
      (pip "name=pymongo state=latest use_mirrors=no"))
    (task "Create the iptables file"
      (template "src=iptables.j2 dest=/etc/sysconfig/iptables")
      (notify "restart iptables"))))
