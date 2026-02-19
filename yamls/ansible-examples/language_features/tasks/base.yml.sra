(playbook "ansible-examples/language_features/tasks/base.yml"
  (tasks
    (task "no selinux"
      (command "/usr/sbin/setenforce 0"))
    (task "no iptables"
      (service "name=iptables state=stopped"))
    (task "made up task just to show variables work here"
      (command "/bin/echo release is $release"))))
