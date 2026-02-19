(playbook "debops/ansible/roles/tinc/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (tinc__base_packages
                              + tinc__packages)) }}"))
        (state "present"))
      (register "tinc__register_install")
      (until "tinc__register_install is succeeded"))
    (task "Create system group for VPN service"
      (ansible.builtin.group 
        (name (jinja "{{ tinc__group }}"))
        (state "present")
        (system "True")))
    (task "Create system user for VPN service"
      (ansible.builtin.user 
        (name (jinja "{{ tinc__user }}"))
        (state "present")
        (system "True")
        (comment "tinc VPN service")
        (home (jinja "{{ tinc__home }}"))
        (group (jinja "{{ tinc__group }}"))
        (shell "/bin/false")
        (createhome "False")))
    (task "Load the required kernel modules"
      (community.general.modprobe 
        (name (jinja "{{ item }}"))
        (state "present"))
      (with_items (jinja "{{ tinc__modprobe_modules }}"))
      (when "(tinc__modprobe | bool and (((ansible_system_capabilities_enforced | d()) | bool and \"cap_sys_admin\" in ansible_system_capabilities) or not (ansible_system_capabilities_enforced | d(True)) | bool))"))
    (task "Make sure that required modules are loaded on boot"
      (ansible.builtin.lineinfile 
        (dest "/etc/modules")
        (regexp "^" (jinja "{{ item }}") "$")
        (line (jinja "{{ item }}"))
        (state "present")
        (mode "0644"))
      (with_items (jinja "{{ tinc__modprobe_modules }}"))
      (when "(tinc__modprobe | bool and (((ansible_system_capabilities_enforced | d()) | bool and \"cap_sys_admin\" in ansible_system_capabilities) or not (ansible_system_capabilities_enforced | d(True)) | bool))"))
    (task "Set tincd default environment"
      (ansible.builtin.template 
        (src "etc/default/tinc.j2")
        (dest "/etc/default/tinc")
        (owner "root")
        (group "root")
        (mode "0644")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (notify (list
          "Reload tinc")))
    (task "Disable tinc networks in systemd if requested"
      (ansible.builtin.service 
        (name "tinc@" (jinja "{{ item.value.name | d(item.key) }}"))
        (enabled "False")
        (state (jinja "{{ (item.state | d(\"present\") in [\"absent\"]) | ternary(\"started\", \"stopped\") }}")))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "tinc__systemd | bool and item.value.state | d('present') == 'absent' and not tinc__register_install is changed"))
    (task "Remove tinc network configuration if requested"
      (ansible.builtin.file 
        (path "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}"))
        (state "absent"))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') == 'absent'"))
    (task "Create required directories"
      (ansible.builtin.file 
        (path "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/" (jinja "{{ (item.hostname | d(tinc__hostname))
                                                                  | replace(\"-\", \"_\") }}") ".d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') != 'absent'"))
    (task "Generate main configuration file"
      (ansible.builtin.template 
        (src "etc/tinc/network/tinc.conf.j2")
        (dest "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/tinc.conf")
        (owner "root")
        (group "root")
        (mode "0644")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') != 'absent' and item.value.tinc_options | d()")
      (notify (list
          "Reload tinc")))
    (task "Remove deprecated dhclient hook script"
      (ansible.builtin.file 
        (dest "/etc/dhcp/dhclient-enter-hooks.d/00debops-tinc")
        (state "absent")))
    (task "Generate tinc-up network scripts"
      (ansible.builtin.template 
        (src "etc/tinc/network/tinc-up.j2")
        (dest "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/tinc-up")
        (owner "root")
        (group (jinja "{{ tinc__group }}"))
        (mode "0750")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "(item.value.state | d('present') != 'absent' and item.value.generate_tinc_up | d(True) | bool)"))
    (task "Generate tinc-down network scripts"
      (ansible.builtin.template 
        (src "etc/tinc/network/tinc-down.j2")
        (dest "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/tinc-down")
        (owner "root")
        (group (jinja "{{ tinc__group }}"))
        (mode "0750")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "(item.value.state | d('present') != 'absent' and item.value.generate_tinc_up | d(True) | bool)"))
    (task "Configure which networks are started at boot"
      (ansible.builtin.template 
        (src "etc/tinc/nets.boot.j2")
        (dest "/etc/tinc/nets.boot")
        (owner "root")
        (group "root")
        (mode "0644")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}"))))
    (task "Ensure that sensitive files are excluded from version control"
      (ansible.builtin.template 
        (src "etc/tinc/gitignore.j2")
        (dest "/etc/tinc/.gitignore")
        (owner "root")
        (group "root")
        (mode "0644")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}"))))
    (task "Initialize RSA key pairs"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && sh -c 'yes || true' | tincd -n " (jinja "{{ item.value.name | d(item.key) }}") " -K " (jinja "{{ item.value.rsa_key_length | d(tinc__rsa_key_length) }}"))
      (args 
        (executable "bash")
        (creates "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/rsa_key.priv"))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') != 'absent'"))
    (task "Create persistent copy of host public key"
      (ansible.builtin.command "cp /etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/" (jinja "{{ (item.value.hostname | d(tinc__hostname))
                                                                     | replace(\"-\", \"_\") }}") " /etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/" (jinja "{{ (item.value.hostname | d(tinc__hostname))
                                                                     | replace(\"-\", \"_\") + \".d/99_rsa-public-key\" }}"))
      (args 
        (creates "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/" (jinja "{{ (item.value.hostname | d(tinc__hostname))
                                                                    | replace(\"-\", \"_\") + \".d/99_rsa-public-key\" }}")))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') != 'absent'"))
    (task "Generate host configuration file"
      (ansible.builtin.template 
        (src "etc/tinc/network/hosts/host-config.j2")
        (dest "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/" (jinja "{{ (item.value.hostname | d(tinc__hostname))
                                                                  | replace(\"-\", \"_\") }}") ".d/00_host-config")
        (owner "root")
        (group "root")
        (mode "0640")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') != 'absent'"))
    (task "Assemble host configuration file from parts"
      (ansible.builtin.assemble 
        (src "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/" (jinja "{{ (item.value.hostname | d(tinc__hostname))
                                                                 | replace(\"-\", \"_\") }}") ".d")
        (dest "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/" (jinja "{{ (item.value.hostname | d(tinc__hostname))
                                                                  | replace(\"-\", \"_\") }}"))
        (owner "root")
        (group (jinja "{{ tinc__group }}"))
        (mode "0640"))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') != 'absent'")
      (notify (list
          "Reload tinc")))
    (task "Upload public keys from hosts to Ansible Controller"
      (ansible.builtin.fetch 
        (src "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/" (jinja "{{ (item.value.hostname | d(tinc__hostname))
                                                                 | replace(\"-\", \"_\") }}"))
        (dest (jinja "{{ secret + \"/tinc/networks/\" + item.value.name | d(item.key)
              + \"/by-network/\" + item.value.name | d(item.key) + \"/hosts/\"
              + (item.value.hostname | d(tinc__hostname) | replace(\"-\", \"_\")) }}"))
        (flat "True"))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') != 'absent'"))
    (task "Download public keys per network"
      (ansible.builtin.copy 
        (src (jinja "{{ secret + \"/tinc/networks/\" + item.value.name | d(item.key)
             + \"/by-network/\" + item.value.name | d(item.key) + \"/hosts/\" }}"))
        (dest "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/")
        (owner "root")
        (group (jinja "{{ tinc__group }}"))
        (mode "0640"))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') != 'absent'")
      (notify (list
          "Reload tinc")))
    (task "Download public keys for all hosts"
      (ansible.builtin.copy 
        (src (jinja "{{ secret + \"/tinc/networks/\" + item.value.name | d(item.key) + \"/by-group/all/hosts/\" }}"))
        (dest "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/")
        (owner "root")
        (group (jinja "{{ tinc__group }}"))
        (mode "0640"))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') != 'absent'")
      (notify (list
          "Reload tinc")))
    (task "Download public keys per group"
      (ansible.builtin.copy 
        (src (jinja "{{ secret + \"/tinc/networks/\" + item.0.name + \"/by-group/\" + item.1 + \"/hosts/\" }}"))
        (dest "/etc/tinc/" (jinja "{{ item.0.name }}") "/hosts/")
        (owner "root")
        (group (jinja "{{ tinc__group }}"))
        (mode "0640"))
      (with_nested (list
          (jinja "{{ lookup(\"template\", \"lookup/tinc__network_list.j2\", convert_data=False) | from_yaml }}")
          (jinja "{{ lookup(\"template\", \"lookup/tinc__inventory_groups.j2\", convert_data=False) | from_yaml }}")))
      (when "(item.0.name | d() and item.0.state | d('present') != 'absent' and item.1 in item.0.inventory_groups | d([]) and item.1 in group_names)")
      (notify (list
          "Reload tinc")))
    (task "Download public keys per host"
      (ansible.builtin.copy 
        (src (jinja "{{ secret + \"/tinc/networks/\" + item.value.name | d(item.key)
             + \"/by-host/\" + ((item.value.inventory_hostname | d(tinc__inventory_hostname))) + \"/hosts/\" }}"))
        (dest "/etc/tinc/" (jinja "{{ item.value.name | d(item.key) }}") "/hosts/")
        (owner "root")
        (group (jinja "{{ tinc__group }}"))
        (mode "0640"))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "item.value.state | d('present') != 'absent'")
      (notify (list
          "Reload tinc")))
    (task "Configure systemd default variables"
      (ansible.builtin.template 
        (src "etc/default/tinc-network.j2")
        (dest "/etc/default/tinc-" (jinja "{{ item.value.name | d(item.key) }}"))
        (owner "root")
        (group "root")
        (mode "0644")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "tinc__systemd | bool and item.value.state | d('present') != 'absent'")
      (notify (list
          "Reload tinc")))
    (task "Configure tinc-down wrapper script"
      (ansible.builtin.template 
        (src "usr/local/lib/tinc-down-wrapper.j2")
        (dest "/usr/local/lib/tinc-down-wrapper")
        (owner "root")
        (group "root")
        (mode "0755")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (when "tinc__systemd | bool"))
    (task "Clean up old systemd configuration"
      (ansible.builtin.file 
        (path "/etc/systemd/system/network.target.wants/tinc.service")
        (state "absent")))
    (task "Configure systemd unit files"
      (ansible.builtin.template 
        (src "etc/systemd/system/" (jinja "{{ item }}") ".j2")
        (dest "/etc/systemd/system/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (with_items (list
          "tinc.service"
          "tinc@.service"))
      (register "tinc__register_systemd")
      (when "tinc__systemd | bool"))
    (task "Reload systemd daemon configuration"
      (ansible.builtin.systemd 
        (daemon_reload "True")
        (name "tinc.service")
        (enabled "True"))
      (when "tinc__register_systemd is changed"))
    (task "Start tinc VPN networks on first install"
      (ansible.builtin.service 
        (name "tinc")
        (state "restarted"))
      (when "not tinc__systemd | bool and tinc__register_install is changed"))
    (task "Configure tinc network services in systemd"
      (ansible.builtin.service 
        (name "tinc@" (jinja "{{ item.value.name | d(item.key) }}"))
        (enabled (jinja "{{ (item.value.boot | d(True)) | bool }}"))
        (state (jinja "{{ (item.value.state | d(\"present\") in [\"absent\"]) | ternary(\"stopped\", \"started\") }}")))
      (with_dict (jinja "{{ tinc__combined_networks }}"))
      (when "tinc__systemd | bool and item.value.state | d('present') != 'absent' and item.value.port | d()"))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Create local facts of tinc"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/tinc.fact.j2")
        (dest "/etc/ansible/facts.d/tinc.fact")
        (owner "root")
        (group "root")
        (mode "0644")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
