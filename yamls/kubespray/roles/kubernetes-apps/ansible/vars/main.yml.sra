(playbook "kubespray/roles/kubernetes-apps/ansible/vars/main.yml"
  (dns_autoscaler_manifests (list
      "dns-autoscaler-sa.yml.j2"
      "dns-autoscaler.yml.j2"
      "dns-autoscaler-clusterrole.yml.j2"
      "dns-autoscaler-clusterrolebinding.yml.j2"))
  (coredns_manifests (list
      "coredns-clusterrole.yml.j2"
      "coredns-clusterrolebinding.yml.j2"
      "coredns-config.yml.j2"
      "coredns-deployment.yml.j2"
      "coredns-sa.yml.j2"
      "coredns-svc.yml.j2"
      (jinja "{{ dns_autoscaler_manifests if enable_dns_autoscaler else [] }}")
      (jinja "{{ 'coredns-poddisruptionbudget.yml.j2' if coredns_pod_disruption_budget else [] }}")))
  (nodelocaldns_manifests (list
      "nodelocaldns-config.yml.j2"
      "nodelocaldns-daemonset.yml.j2"
      "nodelocaldns-sa.yml.j2"
      (jinja "{{ 'nodelocaldns-second-daemonset.yml.j2' if enable_nodelocaldns_secondary else [] }}"))))
