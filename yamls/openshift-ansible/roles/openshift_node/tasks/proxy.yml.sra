(playbook "openshift-ansible/roles/openshift_node/tasks/proxy.yml"
  (tasks
    (task "Check for cluster http proxy"
      (command "oc get proxies.config.openshift.io cluster --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.status.httpProxy}'
")
      (register "oc_get_http_proxy")
      (delegate_to "localhost"))
    (task "Set http proxy"
      (set_fact 
        (http_proxy (jinja "{{ oc_get_http_proxy.stdout }}")))
      (when "oc_get_http_proxy.stdout | length > 0"))
    (task "Check for cluster https proxy"
      (command "oc get proxies.config.openshift.io cluster --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.status.httpsProxy}'
")
      (register "oc_get_https_proxy")
      (delegate_to "localhost"))
    (task "Set https proxy"
      (set_fact 
        (https_proxy (jinja "{{ oc_get_https_proxy.stdout }}")))
      (when "oc_get_https_proxy.stdout | length > 0"))
    (task "Check for cluster no proxy"
      (command "oc get proxies.config.openshift.io cluster --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.status.noProxy}'
")
      (register "oc_get_no_proxy")
      (delegate_to "localhost"))
    (task "Set no proxy"
      (set_fact 
        (no_proxy (jinja "{{ oc_get_no_proxy.stdout }}")))
      (when "oc_get_no_proxy.stdout | length > 0"))
    (task "Check for additional trust bundle"
      (command "oc get configmap user-ca-bundle -n openshift-config --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.data.ca-bundle\\.crt}'
")
      (register "oc_get_additional_trust_bundle")
      (delegate_to "localhost")
      (failed_when "false"))
    (task
      (block (list
          
          (name "Set additional trust bundle")
          (set_fact 
            (l_additional_trust_bundle (jinja "{{ oc_get_additional_trust_bundle.stdout }}")))
          
          (name "Copy additional trust bundle to system CA trust")
          (copy 
            (content (jinja "{{ l_additional_trust_bundle }}"))
            (dest "/etc/pki/ca-trust/source/anchors/ca-bundle.crt"))
          
          (name "Update CA trust")
          (command "update-ca-trust extract")))
      (when "oc_get_additional_trust_bundle.stdout | length > 0"))))
