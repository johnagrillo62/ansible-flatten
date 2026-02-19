(playbook "kubespray/roles/container-engine/cri-o/tasks/main.yaml"
  (tasks
    (task "Cri-o | load vars"
      (import_tasks "load_vars.yml"))
    (task "Cri-o | check if fedora coreos"
      (stat 
        (path "/run/ostree-booted")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "ostree"))
    (task "Cri-o | set is_ostree"
      (set_fact 
        (is_ostree (jinja "{{ ostree.stat.exists }}"))))
    (task "Cri-o | get ostree version"
      (shell "set -o pipefail && rpm-ostree --version | awk -F\\' '/Version/{print $2}'")
      (args 
        (executable "/bin/bash"))
      (register "ostree_version")
      (when "is_ostree"))
    (task "Cri-o | Download cri-o"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.crio) }}"))))
    (task "Cri-o | special handling for amazon linux"
      (import_tasks "setup-amazon.yaml")
      (when "ansible_distribution in [\"Amazon\"]"))
    (task "Cri-o | build a list of crio runtimes with Katacontainers runtimes"
      (set_fact 
        (crio_runtimes (jinja "{{ crio_runtimes + kata_runtimes }}")))
      (when (list
          "kata_containers_enabled")))
    (task "Cri-o | build a list of crio runtimes with runc runtime"
      (set_fact 
        (crio_runtimes (jinja "{{ crio_runtimes + [runc_runtime] }}")))
      (when (list
          "runc_enabled")))
    (task "Cri-o | build a list of crio runtimes with youki runtime"
      (set_fact 
        (crio_runtimes (jinja "{{ crio_runtimes + [youki_runtime] }}")))
      (when (list
          "youki_enabled")))
    (task "Cri-o | Stop kubelet service if running"
      (service 
        (name "kubelet")
        (state "stopped"))
      (when (list
          "crio_runtime_switch"
          "ansible_facts.services['kubelet.service'] is defined and ansible_facts.services['kubelet.service'].state == 'running'")))
    (task "Cri-o | Get all pods"
      (ansible.builtin.command (jinja "{{ bin_dir }}") "/crictl pods -o json")
      (changed_when "false")
      (register "crio_pods")
      (when (list
          "crio_runtime_switch"
          "ansible_facts.services['crio.service'] is defined")))
    (task "Cri-o | Stop and remove pods not on host network"
      (ansible.builtin.command (jinja "{{ bin_dir }}") "/crictl rmp -f " (jinja "{{ item.id }}"))
      (loop (jinja "{{ (crio_pods.stdout | from_json).items | default([]) | selectattr('metadata.namespace', 'ne', 'NODE') }}"))
      (changed_when "true")
      (when (list
          "crio_runtime_switch"
          "ansible_facts.services['crio.service'] is defined"
          "crio_pods.stdout is defined")))
    (task "Cri-o | Stop and remove all remaining pods"
      (ansible.builtin.command (jinja "{{ bin_dir }}") "/crictl rmp -fa")
      (changed_when "true")
      (when (list
          "crio_runtime_switch"
          "ansible_facts.services['crio.service'] is defined")))
    (task "Cri-o | stop crio service if running"
      (service 
        (name "crio")
        (state "stopped"))
      (when (list
          "crio_runtime_switch"
          "ansible_facts.services['crio.service'] is defined and ansible_facts.services['crio.service'].state == 'running'")))
    (task "Cri-o | make sure needed folders exist in the system"
      (file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (mode "0755"))
      (with_items (list
          "/etc/crio"
          "/etc/containers"
          "/etc/systemd/system/crio.service.d")))
    (task "Cri-o | install cri-o config"
      (template 
        (src "crio.conf.j2")
        (dest "/etc/crio/crio.conf")
        (mode "0644"))
      (register "config_install"))
    (task "Cri-o | install config.json"
      (template 
        (src "config.json.j2")
        (dest "/etc/crio/config.json")
        (mode "0644"))
      (register "reg_auth_install"))
    (task "Cri-o | copy binaries"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/cri-o/bin/" (jinja "{{ item }}"))
        (dest (jinja "{{ bin_dir }}") "/" (jinja "{{ item }}"))
        (mode "0755")
        (remote_src "true"))
      (with_items (list
          (jinja "{{ crio_bin_files }}")))
      (notify "Restart crio"))
    (task "Cri-o | create directory for libexec"
      (file 
        (path (jinja "{{ crio_libexec_dir }}"))
        (state "directory")
        (owner "root")
        (mode "0755")))
    (task "Cri-o | copy libexec"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/cri-o/bin/" (jinja "{{ item }}"))
        (dest (jinja "{{ crio_libexec_dir }}") "/" (jinja "{{ item }}"))
        (mode "0755")
        (remote_src "true"))
      (with_items (list
          (jinja "{{ crio_libexec_files }}")))
      (notify "Restart crio"))
    (task "Cri-o | copy service file"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/cri-o/contrib/crio.service")
        (dest "/etc/systemd/system/crio.service")
        (mode "0755")
        (remote_src "true"))
      (notify "Restart crio"))
    (task "Cri-o | configure crio to use kube reserved cgroups"
      (ansible.builtin.copy 
        (dest "/etc/systemd/system/crio.service.d/00-slice.conf")
        (owner "root")
        (group "root")
        (mode "0644")
        (content "[Service]
Slice=" (jinja "{{ kube_reserved_cgroups_for_service_slice }}") "
"))
      (notify "Restart crio")
      (when (list
          "kube_reserved is defined and kube_reserved is true"
          "kube_reserved_cgroups_for_service_slice is defined")))
    (task "Cri-o | update the bin dir for crio.service file"
      (replace 
        (dest "/etc/systemd/system/crio.service")
        (regexp "/usr/local/bin/crio")
        (replace (jinja "{{ bin_dir }}") "/crio"))
      (notify "Restart crio"))
    (task "Cri-o | copy default policy"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/cri-o/contrib/policy.json")
        (dest "/etc/containers/policy.json")
        (mode "0755")
        (remote_src "true"))
      (notify "Restart crio"))
    (task "Cri-o | copy mounts.conf"
      (template 
        (src "mounts.conf.j2")
        (dest "/etc/containers/mounts.conf")
        (mode "0644"))
      (when (list
          "ansible_os_family == 'RedHat'"))
      (notify "Restart crio"))
    (task "Cri-o | create directory for oci hooks"
      (file 
        (path "/etc/containers/oci/hooks.d")
        (state "directory")
        (owner "root")
        (mode "0755")))
    (task "Cri-o | set overlay driver"
      (community.general.ini_file 
        (dest "/etc/containers/storage.conf")
        (section "storage")
        (option (jinja "{{ item.option }}"))
        (value (jinja "{{ item.value }}"))
        (mode "0644"))
      (with_items (list
          
          (option "driver")
          (value "\"overlay\"")
          
          (option "graphroot")
          (value "\"/var/lib/containers/storage\"")
          
          (option "runroot")
          (value "\"/var/run/containers/storage\""))))
    (task "Cri-o | set metacopy mount options correctly"
      (community.general.ini_file 
        (dest "/etc/containers/storage.conf")
        (section "storage.options.overlay")
        (option "mountopt")
        (value (jinja "{{ ''\"nodev\"'' if ansible_kernel is version((\"4.18\" if ansible_os_family == \"RedHat\" else \"4.19\"), \"<\") else ''\"nodev,metacopy=on\"'' }}"))
        (mode "0644")))
    (task "Cri-o | create directory registries configs"
      (file 
        (path "/etc/containers/registries.conf.d")
        (state "directory")
        (owner "root")
        (mode "0755")))
    (task "Cri-o | write registries configs"
      (template 
        (src "registry.conf.j2")
        (dest "/etc/containers/registries.conf.d/10-" (jinja "{{ item.prefix | default(item.location) | regex_replace(':|/', '_') }}") ".conf")
        (mode "0644"))
      (loop (jinja "{{ crio_registries }}"))
      (notify "Restart crio"))
    (task "Cri-o | configure unqualified registry settings"
      (template 
        (src "unqualified.conf.j2")
        (dest "/etc/containers/registries.conf.d/01-unqualified.conf")
        (mode "0644"))
      (notify "Restart crio"))
    (task "Cri-o | write cri-o proxy drop-in"
      (template 
        (src "http-proxy.conf.j2")
        (dest "/etc/systemd/system/crio.service.d/http-proxy.conf")
        (mode "0644"))
      (notify "Restart crio")
      (when "http_proxy is defined or https_proxy is defined"))
    (task "Cri-o | configure the uid/gid space for user namespaces"
      (lineinfile 
        (path (jinja "{{ item.path }}"))
        (line (jinja "{{ item.entry }}"))
        (regex "^\\s*" (jinja "{{ crio_remap_user }}") ":")
        (state (jinja "{{ \"present\" if crio_remap_enable | bool else \"absent\" }}")))
      (loop (list
          
          (path "/etc/subuid")
          (entry (jinja "{{ crio_remap_user }}") ":" (jinja "{{ crio_subuid_start }}") ":" (jinja "{{ crio_subuid_length }}"))
          
          (path "/etc/subgid")
          (entry (jinja "{{ crio_remap_user }}") ":" (jinja "{{ crio_subgid_start }}") ":" (jinja "{{ crio_subgid_length }}"))))
      (loop_control 
        (label (jinja "{{ item.path }}"))))
    (task "Cri-o | ensure crio service is started and enabled"
      (service 
        (name "crio")
        (daemon_reload "true")
        (enabled "true")
        (state "started"))
      (register "service_start"))
    (task "Cri-o | trigger service restart only when needed"
      (service 
        (name "crio")
        (state "restarted"))
      (when (list
          "config_install.changed or reg_auth_install.changed"
          "not service_start.changed")))
    (task "Cri-o | verify that crio is running"
      (command (jinja "{{ bin_dir }}") "/" (jinja "{{ crio_status_command }}") " info")
      (register "get_crio_info")
      (until "get_crio_info is succeeded")
      (changed_when "false")
      (retries "5")
      (delay (jinja "{{ retry_stagger | random + 3 }}")))
    (task "Cri-o | ensure kubelet service is started if present and stopped"
      (service 
        (name "kubelet")
        (state "started"))
      (when (list
          "crio_runtime_switch"
          "ansible_facts.services['kubelet.service'] is defined and ansible_facts.services['kubelet.service']['status'] != 'not-found'")))))
