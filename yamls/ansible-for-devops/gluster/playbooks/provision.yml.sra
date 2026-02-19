(playbook "ansible-for-devops/gluster/playbooks/provision.yml"
    (play
    (hosts "gluster")
    (become "yes")
    (vars_files (list
        "vars.yml"))
    (roles
      "geerlingguy.firewall"
      "geerlingguy.glusterfs")
    (tasks
      (task "Ensure Gluster brick and mount directories exist."
        (file 
          (path (jinja "{{ item }}"))
          (state "directory")
          (mode "0775"))
        (with_items (list
            (jinja "{{ gluster_brick_dir }}")
            (jinja "{{ gluster_mount_dir }}"))))
      (task "Configure Gluster volume."
        (gluster_volume 
          (state "present")
          (name (jinja "{{ gluster_brick_name }}"))
          (brick (jinja "{{ gluster_brick_dir }}"))
          (replicas "2")
          (cluster (jinja "{{ groups.gluster | join(',') }}"))
          (host (jinja "{{ inventory_hostname }}"))
          (force "yes"))
        (run_once "true"))
      (task "Ensure Gluster volume is mounted."
        (mount 
          (name (jinja "{{ gluster_mount_dir }}"))
          (src (jinja "{{ inventory_hostname }}") ":/" (jinja "{{ gluster_brick_name }}"))
          (fstype "glusterfs")
          (opts "defaults,_netdev")
          (state "mounted"))))))
