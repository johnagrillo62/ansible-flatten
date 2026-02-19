(playbook "kubespray/roles/kubernetes-apps/metallb/tasks/main.yml"
  (tasks
    (task "Kubernetes Apps | Check cluster settings for MetalLB"
      (fail 
        (msg "MetalLB require kube_proxy_strict_arp = true, see https://github.com/danderson/metallb/issues/153#issuecomment-518651132"))
      (when (list
          "kube_proxy_mode == 'ipvs' and not kube_proxy_strict_arp")))
    (task "Kubernetes Apps | Check that the deprecated 'matallb_auto_assign' variable is not used anymore"
      (fail 
        (msg "'matallb_auto_assign' configuration variable is deprecated, please use 'metallb_auto_assign' instead"))
      (when (list
          "matallb_auto_assign is defined")))
    (task "Kubernetes Apps | Lay Down MetalLB"
      (template 
        (src "metallb.yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/metallb.yaml")
        (mode "0644"))
      (become "true")
      (register "metallb_rendering")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Apps | Install and configure MetalLB"
      (kube 
        (name "MetalLB")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/metallb.yaml")
        (state (jinja "{{ metallb_rendering.changed | ternary('latest', 'present') }}"))
        (wait "true"))
      (become "true")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Apps | Wait for MetalLB controller to be running"
      (command (jinja "{{ bin_dir }}") "/kubectl rollout status -n " (jinja "{{ metallb_namespace }}") " deployment -l app=metallb,component=controller --timeout=2m")
      (become "true")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "MetalLB | Address pools"
      (block (list
          
          (name "MetalLB | Layout address pools template")
          (ansible.builtin.template 
            (src "pools.yaml.j2")
            (dest (jinja "{{ kube_config_dir }}") "/pools.yaml")
            (mode "0644"))
          (register "pools_rendering")
          
          (name "MetalLB | Create address pools configuration")
          (kube 
            (name "MetalLB")
            (kubectl (jinja "{{ bin_dir }}") "/kubectl")
            (filename (jinja "{{ kube_config_dir }}") "/pools.yaml")
            (state (jinja "{{ pools_rendering.changed | ternary('latest', 'present') }}")))
          (become "true")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "metallb_config.address_pools is defined")))
    (task "MetalLB | Layer2"
      (block (list
          
          (name "MetalLB | Layout layer2 template")
          (ansible.builtin.template 
            (src "layer2.yaml.j2")
            (dest (jinja "{{ kube_config_dir }}") "/layer2.yaml")
            (mode "0644"))
          (register "layer2_rendering")
          
          (name "MetalLB | Create layer2 configuration")
          (kube 
            (name "MetalLB")
            (kubectl (jinja "{{ bin_dir }}") "/kubectl")
            (filename (jinja "{{ kube_config_dir }}") "/layer2.yaml")
            (state (jinja "{{ layer2_rendering.changed | ternary('latest', 'present') }}")))
          (become "true")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "metallb_config.layer2 is defined")))
    (task "MetalLB | Layer3"
      (block (list
          
          (name "MetalLB | Layout layer3 template")
          (ansible.builtin.template 
            (src "layer3.yaml.j2")
            (dest (jinja "{{ kube_config_dir }}") "/layer3.yaml")
            (mode "0644"))
          (register "layer3_rendering")
          
          (name "MetalLB | Create layer3 configuration")
          (kube 
            (name "MetalLB")
            (kubectl (jinja "{{ bin_dir }}") "/kubectl")
            (filename (jinja "{{ kube_config_dir }}") "/layer3.yaml")
            (state (jinja "{{ layer3_rendering.changed | ternary('latest', 'present') }}")))
          (become "true")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "metallb_config.layer3 is defined")))
    (task "Kubernetes Apps | Delete MetalLB ConfigMap"
      (kube 
        (name "config")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource "ConfigMap")
        (namespace (jinja "{{ metallb_namespace }}"))
        (state "absent")))))
