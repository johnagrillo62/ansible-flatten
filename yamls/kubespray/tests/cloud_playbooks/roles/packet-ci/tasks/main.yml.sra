(playbook "kubespray/tests/cloud_playbooks/roles/packet-ci/tasks/main.yml"
  (tasks
    (task "Generate SSH keypair"
      (community.crypto.openssh_keypair 
        (size "2048")
        (path (jinja "{{ lookup('env', 'ANSIBLE_PRIVATE_KEY_FILE') }}"))
        (mode "400"))
      (register "ssh_key"))
    (task "Start vms for CI job"
      (kubernetes.core.k8s 
        (definition (jinja "{{ lookup('template', 'vm.yml.j2', template_vars=item) }}")))
      (loop (jinja "{{ cluster_layout }}"))
      (loop_control 
        (index_var "index")))
    (task "Wait for vms to have IP addresses"
      (kubernetes.core.k8s_info 
        (api_version "kubevirt.io/v1")
        (kind "VirtualMachineInstance")
        (label_selectors (list
            "ci_job_id=" (jinja "{{ ci_job_id }}")))
        (namespace (jinja "{{ pod_namespace }}")))
      (register "vmis")
      (until "vmis.resources | map(attribute='status.interfaces.0') | rejectattr('ipAddress', 'defined') == []")
      (retries "30")
      (delay "10"))
    (task "Massage VirtualMachineInstance data into an Ansible inventory structure"
      (set_fact 
        (ci_inventory (jinja "{{ ci_inventory|d({}) | combine({
                    item: {
                      'hosts': vm_hosts | selectattr('ansible_groups', 'contains', item)
                                     | rekey_on_member('inventory_name')
                      }
                    })
                  }}")))
      (vars 
        (ips (jinja "{{ vmis.resources | map(attribute='status.interfaces.0.ipAddress') }}"))
        (names (jinja "{{ vmis.resources | map(attribute='metadata.annotations.inventory_name') }}"))
        (_groups (jinja "{{ (vmis.resources | map(attribute='metadata.annotations.ansible_groups') | map('split', ','))}}"))
        (vm_hosts (jinja "{{ ips | zip(_groups, names)
                | map('zip', ['ansible_host', 'ansible_groups', 'inventory_name'])
                | map('map', 'reverse') | map('community.general.dict') }}")))
      (loop (jinja "{{ vm_hosts | map(attribute='ansible_groups') | flatten | unique }}")))
    (task "Create inventory for CI tests"
      (copy 
        (content (jinja "{{ ci_inventory | to_yaml }}"))
        (dest (jinja "{{ ansible_inventory_sources[0] }}") "/ci_inventory.yml")
        (mode "0644")))))
