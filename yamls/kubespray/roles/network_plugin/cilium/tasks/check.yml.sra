(playbook "kubespray/roles/network_plugin/cilium/tasks/check.yml"
  (tasks
    (task "Cilium | Check Cilium encryption `cilium_ipsec_key` for ipsec"
      (assert 
        (that (list
            "cilium_ipsec_key is defined"))
        (msg "cilium_ipsec_key should be defined to enable encryption using ipsec"))
      (when (list
          "cilium_encryption_enabled"
          "cilium_encryption_type == \"ipsec\""
          "cilium_tunnel_mode in ['vxlan']")))
    (task "Stop if `cilium_ipsec_enabled` is defined and `cilium_encryption_type` is not `ipsec`"
      (assert 
        (that "cilium_encryption_type == 'ipsec'")
        (msg "It is not possible to use `cilium_ipsec_enabled` when `cilium_encryption_type` is set to " (jinja "{{ cilium_encryption_type }}") ".
"))
      (when (list
          "cilium_ipsec_enabled is defined"
          "cilium_ipsec_enabled"
          "kube_network_plugin == 'cilium' or cilium_deploy_additionally")))
    (task "Stop if kernel version is too low for Cilium Wireguard encryption"
      (assert 
        (that "ansible_kernel.split('-')[0] is version('5.6.0', '>=')"))
      (when (list
          "kube_network_plugin == 'cilium' or cilium_deploy_additionally"
          "cilium_encryption_enabled"
          "cilium_encryption_type == \"wireguard\""
          "not ignore_assert_errors")))
    (task "Stop if bad Cilium identity allocation mode"
      (assert 
        (that "cilium_identity_allocation_mode in ['crd', 'kvstore']")
        (msg "cilium_identity_allocation_mode must be either 'crd' or 'kvstore'")))
    (task "Stop if bad Cilium Cluster ID"
      (assert 
        (that (list
            "cilium_cluster_id <= 255"
            "cilium_cluster_id >= 0"))
        (msg "'cilium_cluster_id' must be between 1 and 255"))
      (when "cilium_cluster_id is defined"))
    (task "Stop if bad encryption type"
      (assert 
        (that "cilium_encryption_type in ['ipsec', 'wireguard']")
        (msg "cilium_encryption_type must be either 'ipsec' or 'wireguard'"))
      (when "cilium_encryption_enabled"))
    (task "Stop if cilium_version is < " (jinja "{{ cilium_min_version_required }}")
      (assert 
        (that "cilium_version is version(cilium_min_version_required, '>=')")
        (msg "cilium_version is too low. Minimum version " (jinja "{{ cilium_min_version_required }}"))))
    (task "Set `cilium_encryption_type` to \"ipsec\" and  if `cilium_ipsec_enabled` is true"
      (set_fact 
        (cilium_encryption_type "ipsec")
        (cilium_encryption_enabled "true"))
      (when (list
          "cilium_ipsec_enabled is defined"
          "cilium_ipsec_enabled")))
    (task "Stop if cilium_hubble_event_buffer_capacity is not a power of 2 minus 1 and is not between 1 and 65535"
      (assert 
        (that "cilium_hubble_event_buffer_capacity in [1, 3, 7, 15, 31, 63, 127, 255, 511, 1023, 2047, 4095, 8191, 16383, 32767, 65535]")
        (msg "Error: cilium_hubble_event_buffer_capacity:" (jinja "{{ cilium_hubble_event_buffer_capacity }}") " is not a power of 2 minus 1 and it should be between 1 and 65535."))
      (when "cilium_hubble_event_buffer_capacity is defined"))))
