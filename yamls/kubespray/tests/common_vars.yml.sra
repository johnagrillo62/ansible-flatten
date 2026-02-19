(playbook "kubespray/tests/common_vars.yml"
  (deploy_netchecker "true")
  (dns_min_replicas "1")
  (unsafe_show_logs "true")
  (bin_dir (jinja "{{ '/opt/bin' if ansible_os_family == 'Flatcar' else '/usr/local/bin' }}"))
  (docker_registry_mirrors (list
      "https://mirror.gcr.io"))
  (containerd_registries_mirrors (list
      
      (prefix "docker.io")
      (mirrors (list
          
          (host "https://mirror.gcr.io")
          (capabilities (list
              "pull"
              "resolve"))
          (skip_verify "false")
          
          (host "https://registry-1.docker.io")
          (capabilities (list
              "pull"
              "resolve"))
          (skip_verify "false")))))
  (crio_registries (list
      
      (prefix "docker.io")
      (insecure "false")
      (blocked "false")
      (unqualified "false")
      (location "registry-1.docker.io")
      (mirrors (list
          
          (location "mirror.gcr.io")
          (insecure "false")))))
  (netcheck_agent_image_repo (jinja "{{ quay_image_repo }}") "/kubespray/k8s-netchecker-agent")
  (netcheck_server_image_repo (jinja "{{ quay_image_repo }}") "/kubespray/k8s-netchecker-server")
  (nginx_image_repo (jinja "{{ quay_image_repo }}") "/kubespray/nginx")
  (flannel_image_repo (jinja "{{ quay_image_repo }}") "/kubespray/flannel")
  (flannel_init_image_repo (jinja "{{ quay_image_repo }}") "/kubespray/flannel-cni-plugin")
  (local_release_dir (jinja "{{ '/tmp/releases' if inventory_hostname != 'localhost' else (lookup('env', 'PWD') + '/downloads') }}")))
