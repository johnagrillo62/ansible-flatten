(playbook "kubespray/roles/kubernetes-apps/container_runtimes/kata_containers/defaults/main.yaml"
  (kata_containers_qemu_overhead "true")
  (kata_containers_qemu_overhead_fixed_cpu "250m")
  (kata_containers_qemu_overhead_fixed_memory "160Mi"))
