(playbook "ansible-examples/language_features/zfs.yml"
    (play
    (hosts "webservers")
    (gather_facts "no")
    (become "yes")
    (become_method "sudo")
    (vars
      (pool "rpool"))
    (tasks
      (task "Create a zfs file system"
        (zfs "name=" (jinja "{{pool}}") "/var/log/httpd state=present"))
      (task "Create a zfs file system with quota of 10GiB and visible snapdir"
        (zfs "name=" (jinja "{{pool}}") "/ansible quota='10G' snapdir=visible state=present"))
      (task "Create zfs snapshot of the above file system"
        (zfs "name=" (jinja "{{pool}}") "/ansible@mysnapshot state=present"))
      (task "Create zfs volume named smallvol with a size of 10MiB"
        (zfs "name=" (jinja "{{pool}}") "/smallvol volsize=10M state=present"))
      (task "Removes snapshot of rpool/oldfs"
        (zfs "name=" (jinja "{{pool}}") "/oldfs@oldsnapshot state=absent"))
      (task "Removes file system rpool/oldfs"
        (zfs "name=" (jinja "{{pool}}") "/oldfs state=absent")))))
