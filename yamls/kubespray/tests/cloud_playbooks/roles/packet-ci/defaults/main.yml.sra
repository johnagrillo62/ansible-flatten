(playbook "kubespray/tests/cloud_playbooks/roles/packet-ci/defaults/main.yml"
  (vm_cpu_cores "2")
  (vm_cpu_sockets "1")
  (vm_cpu_threads "2")
  (vm_memory "2048")
  (releases_disk_size "2Gi")
  (cpu_allocation_ratio "0.25")
  (memory_allocation_ratio "1")
  (mode "default")
  (node_groups (list
      "all"))
  (cluster_layout (jinja "{{ molecule_yml.platforms | d(scenarios[mode]) }}")))
