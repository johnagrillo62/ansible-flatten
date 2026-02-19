(playbook "openshift-ansible/roles/openshift_node/tasks/version_checks.yml"
  (tasks
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
    (task "Fail if not using RHEL8 beginning with version 4.10"
      (fail 
        (msg "As of v4.10, RHEL nodes must be at least version 8.4"))
      (when (list
          "l_cluster_version is version('4.10', '>=')"
          "ansible_facts['distribution'] == \"RedHat\""
          "ansible_facts['distribution_version'] is version('8.4', '<')")))
    (task "Fail if cluster version is greater than or equal to 4.19"
      (fail 
        (msg "RHEL nodes in version 4.19 and above are no longer supported"))
      (when "l_cluster_version is version('4.19', '>=')"))))
