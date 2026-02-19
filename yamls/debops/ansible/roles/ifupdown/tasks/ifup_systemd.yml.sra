(playbook "debops/ansible/roles/ifupdown/tasks/ifup_systemd.yml"
  (tasks
    (task "Check systemd version"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && systemd --version | head -n 1 | awk '{print $2}'")
      (args 
        (executable "bash"))
      (register "ifupdown__register_systemd_version")
      (check_mode "False")
      (changed_when "False"))
    (task "Install custom ifupdown services"
      (ansible.builtin.template 
        (src "etc/systemd/system/" (jinja "{{ item }}") ".j2")
        (dest "/etc/systemd/system/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "iface@.service"
          "ifup-wait-all-auto.service"
          "ifup-allow-boot.service"))
      (register "ifupdown__register_systemd_services"))
    (task "Reload systemd services"
      (ansible.builtin.systemd 
        (daemon_reload "True"))
      (when "ifupdown__register_systemd_services is changed"))
    (task "Test if Ansible is running in check mode"
      (ansible.builtin.command "/bin/true")
      (changed_when "False")
      (register "ifupdown__register_check_mode"))
    (task "Enable custom ifupdown services"
      (ansible.builtin.service 
        (name (jinja "{{ item }}"))
        (enabled "True"))
      (with_items (list
          "ifup-wait-all-auto"
          "ifup-allow-boot"))
      (when "ifupdown__register_check_mode is not skipped"))))
