(playbook "kubespray/roles/container-engine/kata-containers/tasks/main.yml"
  (tasks
    (task "Kata-containers | Download kata binary"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.kata_containers) }}"))))
    (task "Kata-containers | Copy kata-containers binary"
      (unarchive 
        (src (jinja "{{ downloads.kata_containers.dest }}"))
        (dest "/")
        (mode "0755")
        (owner "root")
        (group "root")
        (remote_src "true")))
    (task "Kata-containers | Create config directory"
      (file 
        (path (jinja "{{ kata_containers_config_dir }}"))
        (state "directory")
        (mode "0755")))
    (task "Kata-containers | Set configuration"
      (template 
        (src (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ kata_containers_config_dir }}") "/" (jinja "{{ item }}"))
        (mode "0644"))
      (with_items (list
          "configuration-qemu.toml")))
    (task "Kata-containers | Set containerd bin"
      (template 
        (dest (jinja "{{ kata_containers_containerd_bin_dir }}") "/containerd-shim-kata-" (jinja "{{ item }}") "-v2")
        (src "containerd-shim-kata-v2.j2")
        (mode "0755"))
      (vars 
        (shim (jinja "{{ item }}")))
      (with_items (list
          "qemu")))
    (task "Kata-containers | Load vhost kernel modules"
      (community.general.modprobe 
        (state "present")
        (name (jinja "{{ item }}")))
      (with_items (list
          "vhost_vsock"
          "vhost_net")))
    (task "Kata-containers | Persist vhost kernel modules"
      (copy 
        (dest "/etc/modules-load.d/kubespray-kata-containers.conf")
        (mode "0644")
        (content "vhost_vsock
vhost_net")))))
