(playbook "kubespray/roles/kubernetes-apps/external_provisioner/local_volume_provisioner/tasks/basedirs.yml"
  (tasks
    (task "Local Volume Provisioner | Ensure base dir " (jinja "{{ delegate_host_base_dir.1 }}") " is created on " (jinja "{{ delegate_host_base_dir.0 }}")
      (file 
        (path (jinja "{{ local_volume_provisioner_storage_classes[delegate_host_base_dir.1].host_dir }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode (jinja "{{ local_volume_provisioner_directory_mode }}")))
      (delegate_to (jinja "{{ delegate_host_base_dir.0 }}")))))
