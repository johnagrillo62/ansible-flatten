(playbook "kubespray/roles/helm-apps/tasks/main.yml"
  (tasks
    (task "Add Helm repositories"
      (kubernetes.core.helm_repository (jinja "{{ helm_repository_defaults | combine(item) }}"))
      (loop (jinja "{{ repositories }}")))
    (task "Update Helm repositories"
      (kubernetes.core.helm 
        (state "absent")
        (binary_path (jinja "{{ bin_dir }}") "/helm")
        (release_name "dummy")
        (release_namespace "kube-system")
        (update_repo_cache "true"))
      (when (list
          "repositories != []"
          "helm_update")))
    (task "Install Helm Applications"
      (kubernetes.core.helm (jinja "{{ helm_defaults | combine(release_common_opts, item) }}"))
      (loop (jinja "{{ releases }}")))))
