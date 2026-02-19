(playbook "kubespray/roles/kubernetes-apps/scheduler_plugins/defaults/main.yml"
  (scheduler_plugins_enabled "false")
  (scheduler_plugins_namespace "scheduler-plugins")
  (scheduler_plugins_controller_replicas "1")
  (scheduler_plugins_scheduler_replicas "1")
  (scheduler_plugins_scheduler_leader_elect (jinja "{{ ((groups['kube_control_plane'] | length) > 1) }}"))
  (scheduler_plugins_enabled_plugins (list
      "Coscheduling"
      "CapacityScheduling"
      "NodeResourceTopologyMatch"
      "NodeResourcesAllocatable"))
  (scheduler_plugins_disabled_plugins (list
      "PrioritySort"))
  (scheduler_plugins_plugin_config (list
      
      (name "Coscheduling")
      (args 
        (permitWaitingTimeSeconds "10")))))
