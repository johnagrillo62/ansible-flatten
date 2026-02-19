(playbook "kubespray/playbooks/internal_facts.yml"
    (play
    (name "Bootstrap hosts for Ansible")
    (hosts "k8s_cluster:etcd:calico_rr")
    (strategy "linear")
    (any_errors_fatal (jinja "{{ any_errors_fatal | default(true) }}"))
    (gather_facts "false")
    (environment (jinja "{{ proxy_disable_env }}"))
    (roles
      
        (role "bootstrap_os")
        (tags "bootstrap_os")))
    (play
    (name "Gather facts")
    (hosts "k8s_cluster:etcd:calico_rr")
    (gather_facts "false")
    (tags "always")
    (tasks
      (task "Gather and compute network facts"
        (import_role 
          (name "network_facts")))
      (task "Gather minimal facts"
        (setup 
          (gather_subset "!all")))
      (task "Gather necessary facts (network)"
        (setup 
          (gather_subset "!all,!min,network")
          (filter "ansible_*_ipv[46]*")))
      (task "Gather necessary facts (hardware)"
        (setup 
          (gather_subset "!all,!min,hardware")
          (filter "ansible_*total_mb"))))))
