(playbook "debops/ansible/roles/resolved/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Check if other resolvers are installed"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
dpkg --get-selections | grep -w -E '(" (jinja "{{ resolved__skip_packages | join(\"|\") }}") ")'
                      | awk '{print $1}' || true
")
      (environment 
        (LC_MESSAGES "C"))
      (args 
        (executable "/bin/bash"))
      (register "resolved__register_resolvers")
      (changed_when "False")
      (failed_when "False")
      (check_mode "False"))
    (task "Set resolved deployment state"
      (ansible.builtin.set_fact 
        (resolved__fact_service_state (jinja "{{ \"present\"
                                       if (not resolved__register_resolvers.stdout | d())
                                       else \"absent\" }}"))))
    (task "Create systemd-resolved configuration directory for fallback"
      (ansible.builtin.file 
        (path "/etc/systemd/resolved.conf.d")
        (state "directory")
        (mode "0755"))
      (when (list
          "resolved__enabled | bool"
          "resolved__fallback_conf != ''"
          "resolved__resolv_conf != '/etc/resolv.conf'"
          "not (ansible_local.resolved.installed | d()) | bool")))
    (task "Save existing nameservers as fallback to ensure connectivity"
      (ansible.builtin.template 
        (src "etc/systemd/resolved.conf.d/fallback-dns.conf.j2")
        (dest (jinja "{{ \"/etc/systemd/resolved.conf.d/\" + resolved__fallback_conf }}"))
        (mode "0644"))
      (when (list
          "resolved__enabled | bool"
          "resolved__fallback_conf != ''"
          "resolved__resolv_conf != '/etc/resolv.conf'"
          "not (ansible_local.resolved.installed | d()) | bool")))
    (task "Create systemd-resolved.service configuration directory"
      (ansible.builtin.file 
        (path "/etc/systemd/system/systemd-resolved.service.d")
        (state "directory")
        (mode "0755"))
      (when (list
          "resolved__enabled | bool")))
    (task "Configure synthesis of local hostname by systemd-resolved"
      (ansible.builtin.template 
        (src "etc/systemd/system/systemd-resolved.service.d/synthesize-hostname.conf.j2")
        (dest "/etc/systemd/system/systemd-resolved.service.d/synthesize-hostname.conf")
        (mode "0644"))
      (when (list
          "resolved__enabled | bool"))
      (notify (list
          "Reload systemd daemon"
          "Restart systemd-resolved service")))
    (task "Install required resolved packages"
      (ansible.builtin.package 
        (name (jinja "{{ resolved__base_packages + resolved__packages }}"))
        (state "present"))
      (register "resolved__register_packages")
      (until "resolved__register_packages is succeeded")
      (when "resolved__enabled | bool"))
    (task "Enable and start systemd-resolved service"
      (ansible.builtin.systemd 
        (name "systemd-resolved.service")
        (state "started")
        (enabled "True"))
      (when "resolved__enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755"))
      (when "resolved__enabled | bool"))
    (task "Save resolved local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/resolved.fact.j2")
        (dest "/etc/ansible/facts.d/resolved.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (when "resolved__enabled | bool")
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Remove systemd-resolved configuuration if requested"
      (ansible.builtin.file 
        (path "/etc/systemd/resolved.conf.d/ansible.conf")
        (state "absent"))
      (notify (list
          "Restart systemd-resolved service"))
      (when "resolved__enabled | bool and resolved__deploy_state == 'absent'"))
    (task "Create systemd-resolved configuration directory"
      (ansible.builtin.file 
        (path "/etc/systemd/resolved.conf.d")
        (state "directory")
        (mode "0755"))
      (when "resolved__enabled | bool and resolved__deploy_state != 'absent'"))
    (task "Generate systemd-resolved configuration"
      (ansible.builtin.template 
        (src "etc/systemd/resolved.conf.d/ansible.conf.j2")
        (dest "/etc/systemd/resolved.conf.d/ansible.conf")
        (mode "0644"))
      (notify (list
          "Restart systemd-resolved service"))
      (when "resolved__enabled | bool and resolved__deploy_state != 'absent'"))
    (task "Ensure that /etc/systemd/dnssd/ directory exists"
      (ansible.builtin.file 
        (path "/etc/systemd/dnssd")
        (state "directory")
        (mode "0755"))
      (when "resolved__enabled | bool and resolved__dnssd_enabled | bool"))
    (task "Remove dnssd units if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/dnssd/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ resolved__combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Restart systemd-resolved service"))
      (when "resolved__enabled | bool and resolved__dnssd_enabled | bool and item.state | d(\"present\") == 'absent'"))
    (task "Remove dnssd unit overrides if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/dnssd/\" + item.name + \".d\" }}"))
        (state "absent"))
      (loop (jinja "{{ resolved__combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Restart systemd-resolved service"))
      (when "resolved__enabled | bool and resolved__dnssd_enabled | bool and item.state | d(\"present\") == 'absent'"))
    (task "Create directories for dnssd units"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/systemd/dnssd/\" + (item.name | dirname) }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ resolved__combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "resolved__enabled | bool and resolved__dnssd_enabled | bool and item.raw | d() and item.state | d(\"present\") not in ['absent', 'ignore', 'init'] and (item.name | dirname).endswith('.d')"))
    (task "Generate dnssd units"
      (ansible.builtin.template 
        (src "etc/systemd/dnssd/template.j2")
        (dest (jinja "{{ \"/etc/systemd/dnssd/\" + item.name }}"))
        (mode "0644"))
      (loop (jinja "{{ resolved__combined_units | flatten | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (notify (list
          "Restart systemd-resolved service"))
      (when "resolved__enabled | bool and resolved__dnssd_enabled | bool and item.raw | d() and item.state | d(\"present\") not in ['absent', 'ignore', 'init']"))
    (task "Flush handlers when needed"
      (ansible.builtin.meta "flush_handlers"))
    (task "Manage /etc/resolv.conf configuration file"
      (ansible.builtin.file 
        (path "/etc/resolv.conf")
        (src (jinja "{{ resolved__resolv_conf }}"))
        (state "link")
        (force "True"))
      (when (list
          "resolved__enabled | bool"
          "resolved__resolv_conf != '/etc/resolv.conf'"
          "(ansible_local.networkd.state | d('disabled')) == 'enabled'"
          "(ansible_local.resolved.state | d('disabled')) == 'enabled'")))
    (task "Prepare cleanup during package removal"
      (ansible.builtin.import_role 
        (name "dpkg_cleanup"))
      (vars 
        (dpkg_cleanup__dependent_packages (list
            (jinja "{{ resolved__dpkg_cleanup__dependent_packages }}"))))
      (when "resolved__enabled | bool")
      (tags (list
          "role::dpkg_cleanup"
          "skip::dpkg_cleanup"
          "role::resolved:dpkg_cleanup")))))
