(playbook "kubespray/roles/bootstrap_os/tasks/fedora.yml"
  (tasks
    (task "Check if bootstrap is needed"
      (raw "which python")
      (register "need_bootstrap")
      (failed_when "false")
      (changed_when "false")
      (tags (list
          "facts")))
    (task "Add proxy to dnf.conf if http_proxy is defined"
      (community.general.ini_file 
        (path "/etc/dnf/dnf.conf")
        (section "main")
        (option "proxy")
        (value (jinja "{{ http_proxy | default(omit) }}"))
        (state (jinja "{{ http_proxy | default(False) | ternary('present', 'absent') }}"))
        (no_extra_spaces "true")
        (mode "0644"))
      (become "true")
      (when "not skip_http_proxy_on_os_packages"))
    (task "Install ansible requirements"
      (raw "dnf install --assumeyes python3 python3-dnf libselinux-python3")
      (become "true")
      (when (list
          "need_bootstrap.rc != 0")))))
