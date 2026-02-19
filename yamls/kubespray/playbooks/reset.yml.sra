(playbook "kubespray/playbooks/reset.yml"
  (tasks
    (task "Common tasks for every playbooks"
      (import_playbook "boilerplate.yml"))
    (task "Gather facts"
      (import_playbook "internal_facts.yml"))
    (task "Reset cluster"
      (hosts "etcd:k8s_cluster:calico_rr")
      (gather_facts "false")
      (pre_tasks (list
          
          (name "Reset Confirmation")
          (pause 
            (prompt "Are you sure you want to reset cluster state? Type 'yes' to reset your cluster."))
          (register "reset_confirmation_prompt")
          (run_once "true")
          (when (list
              "not (skip_confirmation | default(false) | bool)"
              "reset_confirmation is not defined"))
          
          (name "Check confirmation")
          (fail 
            (msg "Reset confirmation failed"))
          (when (list
              "not reset_confirmation | default(false) | bool"
              "not reset_confirmation_prompt.user_input | default(\"\") == \"yes\""))
          
          (name "Gather information about installed services")
          (service_facts null)))
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "kubernetes/preinstall")
          (when "dns_mode != 'none' and resolvconf_mode == 'host_resolvconf'")
          (tags "resolvconf")
          (dns_early "true")
          
          (role "reset")
          (tags "reset")))
      (environment (jinja "{{ proxy_disable_env }}")))))
