(playbook "openshift-ansible/roles/openshift_node/tasks/ipsec.yml"
  (tasks
    (task "Enable ipsec service"
      (systemd 
        (name "ipsec")
        (enabled "yes")))
    (task "add nssdir to ipsec.conf"
      (ansible.builtin.lineinfile 
        (path "/etc/ipsec.conf")
        (insertafter "config setup")
        (line "	nssdir=/var/lib/ipsec/nss")))
    (task "create nssdir"
      (file 
        (path "/var/lib/ipsec/nss")
        (state "directory")))
    (task "check if ipsec dir is empty"
      (find 
        (paths "/var/lib/ipsec/nss")
        (file_type "any")
        (hidden "true"))
      (register "findFiles"))
    (task "determine if selinux context is set"
      (shell "semanage fcontext -l ipsec_key_file_t | grep \"/var/lib/ipsec/nss\" | wc -l")
      (register "numContextEntries"))
    (task "set nss selinux context"
      (shell "semanage fcontext -a -t ipsec_key_file_t /var/lib/ipsec/nss")
      (when "numContextEntries.stdout | int < 1"))
    (task "restore nss selinux context so it will be active"
      (command "restorecon -r /var/lib/ipsec/nss"))
    (task "initialize nss db"
      (command "ipsec initnss --nssdir /var/lib/ipsec/nss")
      (when "findFiles.matched == 0"))
    (task "make sure proper selinux label on nss db"
      (command "chcon -R -t ipsec_key_file_t /var/lib/ipsec/nss"))))
