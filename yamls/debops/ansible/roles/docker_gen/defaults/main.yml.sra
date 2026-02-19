(playbook "debops/ansible/roles/docker_gen/defaults/main.yml"
  (docker_gen__repo "https://github.com/jwilder/docker-gen")
  (docker_gen__os_arch "linux-amd64")
  (docker_gen__version "0.7.4")
  (docker_gen__release (jinja "{{ docker_gen__repo }}") "/releases/download/" (jinja "{{ docker_gen__version }}") "/docker-gen-" (jinja "{{ docker_gen__os_arch }}") "-" (jinja "{{ docker_gen__version }}") ".tar.gz")
  (docker_gen__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                     + \"/docker-gen\" }}"))
  (docker_gen__lib (jinja "{{ (ansible_local.fhs.lib | d(\"/usr/local/lib\"))
                     + \"/docker-gen\" }}"))
  (docker_gen__templates (jinja "{{ docker_gen__lib + \"/templates\" }}"))
  (docker_gen__config "")
  (docker_gen__remote "False")
  (docker_gen__remote_host "")
  (docker_gen__remote_port "2375")
  (docker_gen__remote_endpoint "tcp://" (jinja "{{ docker_gen__remote_host }}") ":" (jinja "{{ docker_gen__remote_port }}"))
  (docker_gen__nginx "True")
  (docker_gen__nginx_template (jinja "{{ docker_gen__templates + \"/nginx-upstreams.conf.tmpl\" }}"))
  (docker_gen__nginx_dest "/etc/nginx/conf.d/docker-gen-upstreams.conf")
  (docker_gen__nginx_options "onlyexposed = true
watch = true

                                                                 # ]]]
")
  (docker_gen__nginx_notify (jinja "{{ docker_gen__nginx_notify_map[ansible_service_mgr] }}"))
  (docker_gen__nginx_notify_map 
    (systemd "nginx -t && systemctl reload nginx")
    (sysvinit "nginx -t && service nginx reload")
    (upstart "nginx -t && service nginx reload"))
  (docker_gen__pki (jinja "{{ ansible_local.pki.enabled | d() | bool }}"))
  (docker_gen__pki_path (jinja "{{ ansible_local.pki.base_path | d(\"/etc/pki\") }}"))
  (docker_gen__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"system\") }}"))
  (docker_gen__pki_ca "CA.crt")
  (docker_gen__pki_crt "default.crt")
  (docker_gen__pki_key "default.key"))
