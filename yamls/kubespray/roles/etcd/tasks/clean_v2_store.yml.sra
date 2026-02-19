(playbook "kubespray/roles/etcd/tasks/clean_v2_store.yml"
  (tasks
    (task "Cleanup v2 store when upgrade etcd from <3.6 to >=3.6"
      (block (list
          
          (name "Ensure etcd version is >=3.5.26")
          (when (list
              "etcd_current_version is version('3.5.26', '<')"))
          (fail 
            (msg "You need to upgrade etcd to 3.5.26 or later before upgrade to 3.6. Current version is " (jinja "{{ etcd_current_version }}") "."))
          
          (name "Change etcd configuration temporally to limit number of WALs and snapshots to clean up v2 store")
          (ansible.builtin.lineinfile 
            (path "/etc/etcd.env")
            (regexp (jinja "{{ item.regexp }}"))
            (line (jinja "{{ item.line }}")))
          (loop (list
              
              (regexp "^ETCD_SNAPSHOT_COUNT=")
              (line "ETCD_SNAPSHOT_COUNT=1")
              
              (regexp "^ETCD_MAX_WALS=")
              (line "ETCD_MAX_WALS=1")
              
              (regexp "^ETCD_MAX_SNAPSHOTS=")
              (line "ETCD_MAX_SNAPSHOTS=1")
              
              (regexp "^ETCD_ENABLE_V2=")
              (line "ETCD_ENABLE_V2=false")))
          
          (name "Stop etcd")
          (service 
            (name "etcd")
            (state "stopped"))
          
          (name "Start etcd")
          (service 
            (name "etcd")
            (state "started"))))
      (when (list
          "etcd_cluster_setup"
          "etcd_current_version != ''"
          "etcd_current_version is version('3.6.0', '<')"
          "etcd_version is version('3.6.0', '>=')")))))
