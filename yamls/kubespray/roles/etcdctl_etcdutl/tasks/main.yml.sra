(playbook "kubespray/roles/etcdctl_etcdutl/tasks/main.yml"
  (tasks
    (task "Copy etcdctl and etcdutl binary from docker container"
      (command "sh -c \"" (jinja "{{ docker_bin_dir }}") "/docker rm -f etcdxtl-binarycopy; " (jinja "{{ docker_bin_dir }}") "/docker create --name etcdxtl-binarycopy " (jinja "{{ etcd_image_repo }}") ":" (jinja "{{ etcd_image_tag }}") " && " (jinja "{{ docker_bin_dir }}") "/docker cp etcdxtl-binarycopy:/usr/local/bin/" (jinja "{{ item }}") " " (jinja "{{ bin_dir }}") "/" (jinja "{{ item }}") " && " (jinja "{{ docker_bin_dir }}") "/docker rm -f etcdxtl-binarycopy\"")
      (with_items (list
          "etcdctl"
          "etcdutl"))
      (register "etcdxtl_install_result")
      (until "etcdxtl_install_result.rc == 0")
      (retries "4")
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (changed_when "false")
      (when "container_manager ==  \"docker\""))
    (task "Download etcd binary"
      (include_tasks "../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.etcd) }}")))
      (when "container_manager in ['crio', 'containerd']"))
    (task "Copy etcd binary"
      (unarchive 
        (src (jinja "{{ downloads.etcd.dest }}"))
        (dest (jinja "{{ local_release_dir }}") "/")
        (remote_src "true"))
      (when "container_manager in ['crio', 'containerd']"))
    (task "Copy etcdctl and etcdutl binary from download dir"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/etcd-v" (jinja "{{ etcd_version }}") "-linux-" (jinja "{{ host_architecture }}") "/" (jinja "{{ item }}"))
        (dest (jinja "{{ bin_dir }}") "/" (jinja "{{ item }}"))
        (mode "0755")
        (remote_src "true"))
      (with_items (list
          "etcdctl"
          "etcdutl"))
      (when "container_manager in ['crio', 'containerd']"))
    (task "Create etcdctl wrapper script"
      (template 
        (src "etcdctl.sh.j2")
        (dest (jinja "{{ bin_dir }}") "/etcdctl.sh")
        (mode "0755")))))
