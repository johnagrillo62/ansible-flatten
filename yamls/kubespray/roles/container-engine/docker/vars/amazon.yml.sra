(playbook "kubespray/roles/container-engine/docker/vars/amazon.yml"
  (docker_versioned_pkg 
    (latest "docker")
    (18.09 "docker-18.09.9ce-2.amzn2")
    (19.03 "docker-19.03.13ce-1.amzn2")
    (20.10 "docker-20.10.7-5.amzn2")
    (24.0 "docker-24.0.5-1.amzn2")
    (25.0 "docker-25.0.3-1.amzn2"))
  (docker_version "latest")
  (docker_package_info 
    (pkgs (list
        (jinja "{{ docker_versioned_pkg[docker_version | string] }}")))
    (enablerepo "amzn2extra-docker")))
