(playbook "openshift-ansible/roles/openshift_node/tasks/install.yml"
  (tasks
    (task "Retrieve rendered-worker name"
      (command "oc get machineconfigpool worker --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.status.configuration.name}'
")
      (delegate_to "localhost")
      (run_once "true")
      (register "rendered_worker")
      (until (list
          "rendered_worker.stdout != ''"))
      (changed_when "false"))
    (task "Check cluster FIPS status"
      (command "oc get machineconfig " (jinja "{{ rendered_worker.stdout }}") " --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.spec.fips}'
")
      (delegate_to "localhost")
      (run_once "true")
      (register "cluster_fips")
      (until (list
          "cluster_fips.stdout != ''"))
      (changed_when "false"))
    (task "Fail if host FIPS status does not match cluster FIPS status"
      (fail 
        (msg "Host FIPS status of '" (jinja "{{ ansible_fips }}") "' does not match cluster FIPS status of '" (jinja "{{ cluster_fips.stdout | bool }}") "'. Please update the host configuration before proceeding.
"))
      (when (list
          "ansible_fips != (cluster_fips.stdout | bool)")))
    (task "Update Yum Cache"
      (yum 
        (state "latest")
        (update_cache "true"))
      (become "true"))
    (task "Get cluster version"
      (command "oc get clusterversion --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.items[0].status.desired.version}'
")
      (delegate_to "localhost")
      (register "oc_get")
      (until (list
          "oc_get.stdout != ''"))
      (changed_when "false"))
    (task "Set fact l_cluster_version"
      (set_fact 
        (l_cluster_version (jinja "{{ oc_get.stdout | regex_search('^\\\\d+\\\\.\\\\d+') }}"))))
    (task "Get kubernetes server version"
      (command "oc version --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=json
")
      (delegate_to "localhost")
      (register "oc_get")
      (until (list
          "oc_get.stdout != ''"))
      (changed_when "false"))
    (task "Set fact l_kubernetes_server_version"
      (set_fact 
        (l_kubernetes_server_version (jinja "{{ (oc_get.stdout | from_json).serverVersion.major ~ '.' ~  (oc_get.stdout | from_json).serverVersion.minor | regex_search('^\\\\d+') }}"))))
    (task "Get available cri-o RPM versions"
      (package 
        (list "cri-o"))
      (register "crio_version"))
    (task "Set fact crio_latest"
      (set_fact 
        (crio_latest (jinja "{{ crio_version.results | selectattr('yumstate', 'match', 'available') | map(attribute='version') | list | last }}"))))
    (task "Fail if cri-o is less than current kubernetes server version"
      (fail 
        (msg "Latest available cri-o (" (jinja "{{ crio_latest }}") ") version is less than current kubernetes server version (" (jinja "{{ l_kubernetes_server_version }}") ").
"))
      (when (list
          "crio_latest is version(l_kubernetes_server_version, 'lt')")))
    (task "Disable container-tools:rhel" (jinja "{{ ansible_distribution_major_version }}") " modularity appstream"
      (command "dnf module disable container-tools:rhel" (jinja "{{ ansible_distribution_major_version }}") " -y")
      (ignore_errors "true"))
    (task
      (block (list
          
          (name "Install openshift packages")
          (dnf 
            (name (jinja "{{ openshift_packages }}"))
            (disablerepo "container-tools")
            (state "latest")
            (allowerasing "true")
            (disable_gpg_check "true"))
          (async "3600")
          (poll "30")
          (register "result")
          (until "result is succeeded")))
      (rescue (list
          
          (name "Package install failure message")
          (fail 
            (msg "Unable to install " (jinja "{{ openshift_packages }}") ". Please ensure repos are configured properly to provide these packages and indicated versions.
")))))
    (task "reload systemd daemons"
      (systemd 
        (daemon_reload "yes")))
    (task "gather service facts"
      (ansible.builtin.service_facts null))
    (task "Restart openvswitch"
      (systemd 
        (name "openvswitch")
        (state "restarted"))
      (when "ansible_facts.services['openvswitch.service'] is defined"))
    (task "Enable the CRI-O service"
      (systemd 
        (name "crio")
        (enabled "yes")))
    (task
      (import_tasks "ipsec.yml"))
    (task "Enable persistent storage on journal"
      (ini_file 
        (dest "/etc/systemd/journald.conf")
        (section "Journal")
        (option "Storage")
        (value "persistent")
        (no_extra_spaces "yes")))
    (task "set package facts"
      (ansible.builtin.package_facts null))
    (task "Update the network backend to Netavark"
      (lineinfile 
        (path "/usr/share/containers/containers.conf")
        (regexp "^network_backend.*")
        (line "network_backend = \"netavark\"")
        (backrefs "yes"))
      (when "ansible_facts.packages.podman[0].version.split(\".\")[0] | int >= 5"))))
