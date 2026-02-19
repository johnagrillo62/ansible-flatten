(playbook "kubespray/roles/bootstrap_os/tasks/debian.yml"
  (tasks
    (task "Check if bootstrap is needed"
      (raw "which python3")
      (register "need_bootstrap")
      (failed_when "false")
      (changed_when "false")
      (check_mode "false")
      (tags (list
          "facts")))
    (task "Check http::proxy in apt configuration files"
      (raw "apt-config dump | grep -qsi 'Acquire::http::proxy'")
      (register "need_http_proxy")
      (failed_when "false")
      (changed_when "false")
      (check_mode "false"))
    (task "Add http_proxy to /etc/apt/apt.conf if http_proxy is defined"
      (raw "echo 'Acquire::http::proxy \"" (jinja "{{ http_proxy }}") "\";' >> /etc/apt/apt.conf")
      (become "true")
      (when (list
          "http_proxy is defined"
          "need_http_proxy.rc != 0"
          "not skip_http_proxy_on_os_packages")))
    (task "Check https::proxy in apt configuration files"
      (raw "apt-config dump | grep -qsi 'Acquire::https::proxy'")
      (register "need_https_proxy")
      (failed_when "false")
      (changed_when "false")
      (check_mode "false"))
    (task "Add https_proxy to /etc/apt/apt.conf if https_proxy is defined"
      (raw "echo 'Acquire::https::proxy \"" (jinja "{{ https_proxy }}") "\";' >> /etc/apt/apt.conf")
      (become "true")
      (when (list
          "https_proxy is defined"
          "need_https_proxy.rc != 0"
          "not skip_http_proxy_on_os_packages")))
    (task "Install python3"
      (raw "apt-get update && \\ DEBIAN_FRONTEND=noninteractive apt-get install -y python3-minimal")
      (become "true")
      (when (list
          "need_bootstrap.rc != 0")))))
