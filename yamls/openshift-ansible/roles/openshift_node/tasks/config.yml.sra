(playbook "openshift-ansible/roles/openshift_node/tasks/config.yml"
  (tasks
    (task "Disable swap"
      (swapoff ))
    (task "Creating NM config file"
      (copy 
        (dest "/etc/NetworkManager/conf.d/99-keyfile.conf")
        (content "[main]
plugins=keyfile,ifcfg-rh
")))
    (task "Restart service NetworkManager"
      (service 
        (name "NetworkManager")
        (state "restarted")))
    (task "Enable IP Forwarding"
      (sysctl 
        (name "net.ipv4.ip_forward")
        (value "1")
        (sysctl_file "/etc/sysctl.d/99-openshift.conf")
        (reload "yes")))
    (task "Disable firewalld service"
      (systemd 
        (name "firewalld.service")
        (enabled "false"))
      (register "service_status")
      (failed_when (list
          "service_status is failed"
          "not ('Could not find the requested service' in service_status.msg)")))
    (task "Setting sebool container_manage_cgroup"
      (seboolean 
        (name "container_manage_cgroup")
        (state "yes")
        (persistent "yes")))
    (task "Setting sebool virt_use_samba"
      (seboolean 
        (name "virt_use_samba")
        (state "yes")
        (persistent "yes")))
    (task "Setting sebool container_use_cephfs"
      (seboolean 
        (name "container_use_cephfs")
        (state "yes")
        (persistent "yes")))
    (task
      (import_tasks "selinux.yml"))
    (task "Create temp directory"
      (tempfile 
        (state "directory"))
      (register "temp_dir"))
    (task "Fetch bootstrap ignition file locally"
      (uri 
        (url (jinja "{{ openshift_node_bootstrap_endpoint }}"))
        (dest (jinja "{{ temp_dir.path }}") "/bootstrap.ign")
        (validate_certs "false")
        (headers 
          (Accept "application/vnd.coreos.ignition+json; version=3.2.0"))
        (http_agent "Ignition/0.35.0"))
      (delay "10")
      (retries "60")
      (register "bootstrap_ignition")
      (until (list
          "bootstrap_ignition.status is defined"
          "bootstrap_ignition.status == 200")))
    (task "Extract the last registries.conf file from bootstrap.ign"
      (set_fact 
        (registries_conf (jinja "{{ bootstrap_ignition.json.storage.files | selectattr('path', 'match', '/etc/containers/registries.conf') | list | last }}") "
")))
    (task "Check data URL encoding and extract source data"
      (set_fact 
        (base64encoded (jinja "{{ registries_conf.contents.source.split(',')[0].endswith('base64') }}"))
        (source_data (jinja "{{ registries_conf.contents.source.split(',')[1] }}"))))
    (task "Write /etc/containers/registries.conf"
      (copy 
        (content (jinja "{{ (source_data | b64decode) if base64encoded else (source_data | urldecode) }}"))
        (mode (jinja "{{ '0' ~ registries_conf.mode }}"))
        (dest (jinja "{{ registries_conf.path }}")))
      (register "update_registries"))
    (task "Restart the CRI-O service"
      (systemd 
        (name "crio")
        (state "restarted"))
      (when "update_registries is changed"))
    (task "Get cluster pull-secret"
      (command "oc get secret pull-secret --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --namespace=openshift-config --output=jsonpath='{.data.\\.dockerconfigjson}'
")
      (delegate_to "localhost")
      (register "oc_get")
      (until (list
          "oc_get.stdout != ''"))
      (retries "36")
      (delay "5"))
    (task "Write pull-secret to file"
      (copy 
        (content (jinja "{{ oc_get.stdout | b64decode }}"))
        (dest (jinja "{{ temp_dir.path }}") "/pull-secret.json")))
    (task "Get cluster release image"
      (command "oc get clusterversion --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.items[0].status.desired.image}'
")
      (delegate_to "localhost")
      (register "oc_get")
      (until (list
          "oc_get.stdout != ''"))
      (retries "36")
      (delay "5"))
    (task "Set l_release_image fact"
      (set_fact 
        (l_release_image (jinja "{{ oc_get.stdout }}"))))
    (task
      (import_tasks "proxy.yml"))
    (task
      (block (list
          
          (name "Pull release image")
          (command "podman pull --tls-verify=" (jinja "{{ openshift_node_tls_verify }}") " --authfile " (jinja "{{ temp_dir.path }}") "/pull-secret.json " (jinja "{{ l_release_image }}"))
          (register "podman_pull")
          (until "podman_pull.stdout != ''")
          (retries "12")
          (delay "10")
          
          (name "Get machine controller daemon image from release image")
          (command "podman run --rm " (jinja "{{ l_release_image }}") " image machine-config-operator")
          (register "release_image_mcd")))
      (environment 
        (http_proxy (jinja "{{ http_proxy | default('')}}"))
        (https_proxy (jinja "{{https_proxy | default('')}}"))
        (no_proxy (jinja "{{ no_proxy | default('')}}"))))
    (task
      (block (list
          
          (name "Pull MCD image")
          (command "podman pull --tls-verify=" (jinja "{{ openshift_node_tls_verify }}") " --authfile " (jinja "{{ temp_dir.path }}") "/pull-secret.json " (jinja "{{ release_image_mcd.stdout }}"))
          (register "podman_pull")
          (until "podman_pull.stdout != ''")
          (retries "12")
          (delay "10")
          
          (name "Apply ignition manifest")
          (command "podman run " (jinja "{{ podman_mounts }}") " " (jinja "{{ podman_flags }}") " " (jinja "{{ mcd_command }}"))
          (vars 
            (podman_flags "--pid=host --privileged --rm --entrypoint=/usr/bin/machine-config-daemon -ti " (jinja "{{ release_image_mcd.stdout }}"))
            (podman_mounts "-v /:/rootfs")
            (mcd_command "start --node-name " (jinja "{{ ansible_nodename | lower }}") " --once-from " (jinja "{{ temp_dir.path }}") "/bootstrap.ign --skip-reboot"))
          
          (name "Remove temp directory")
          (file 
            (path (jinja "{{ temp_dir.path }}"))
            (state "absent"))
          
          (name "Reboot the host and wait for it to come back")
          (reboot null)))
      (rescue (list
          
          (fail 
            (msg "Ignition apply failed"))))
      (environment 
        (http_proxy (jinja "{{ http_proxy | default('')}}"))
        (https_proxy (jinja "{{ https_proxy | default('')}}"))
        (no_proxy (jinja "{{ no_proxy | default('')}}"))))
    (task
      (block (list
          
          (name "Approve node CSRs")
          (oc_csr_approve 
            (kubeconfig (jinja "{{ openshift_node_kubeconfig_path }}"))
            (nodename (jinja "{{ ansible_nodename | lower }}")))
          (delegate_to "localhost")))
      (rescue (list
          
          (import_tasks "gather_debug.yml")
          
          (name "DEBUG - Failed to approve node CSRs")
          (fail 
            (msg "Failed to approve node-bootstrapper CSR")))))
    (task
      (block (list
          
          (name "Wait for node to report ready")
          (command "oc get node " (jinja "{{ ansible_nodename | lower }}") " --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'
")
          (delegate_to "localhost")
          (register "oc_get")
          (until (list
              "oc_get.stdout == \"True\""))
          (retries "60")
          (delay "20")
          (changed_when "false")))
      (rescue (list
          
          (import_tasks "gather_debug.yml")
          
          (name "DEBUG - Node failed to report ready")
          (fail 
            (msg "Node failed to report ready")))))))
