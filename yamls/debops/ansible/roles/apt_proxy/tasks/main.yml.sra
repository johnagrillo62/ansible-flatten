(playbook "debops/ansible/roles/apt_proxy/tasks/main.yml"
  (tasks
    (task "Install requested system packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", apt_proxy__base_packages) }}"))
        (state "present"))
      (when "apt_proxy__deploy_state == 'present' and apt_proxy__temporally_avoid_unreachable | bool")
      (register "apt_proxy__register_packages")
      (until "apt_proxy__register_packages is succeeded"))
    (task "Copy get-reachable-apt-proxy to remote host"
      (ansible.builtin.copy 
        (dest (jinja "{{ apt_proxy__proxy_auto_detect }}"))
        (src "usr/local/lib/get-reachable-apt-proxy")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "apt_proxy__deploy_state == 'present' and apt_proxy__temporally_avoid_unreachable | bool"))
    (task "Remove APT proxy configuration"
      (ansible.builtin.file 
        (path "/etc/apt/apt.conf.d/" (jinja "{{ apt_proxy__filename }}"))
        (state "absent"))
      (when "apt_proxy__deploy_state == 'absent'"))
    (task "Generate APT proxy configuration"
      (ansible.builtin.template 
        (src "etc/apt/apt.conf.d/apt_proxy.conf.j2")
        (dest "/etc/apt/apt.conf.d/" (jinja "{{ apt_proxy__filename }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "apt_proxy__deploy_state == 'present'"))))
