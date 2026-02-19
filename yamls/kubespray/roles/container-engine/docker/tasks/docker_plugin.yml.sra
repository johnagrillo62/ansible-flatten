(playbook "kubespray/roles/container-engine/docker/tasks/docker_plugin.yml"
  (tasks
    (task "Install Docker plugin"
      (command "docker plugin install --grant-all-permissions " (jinja "{{ docker_plugin | quote }}"))
      (when "docker_plugin is defined")
      (register "docker_plugin_status")
      (failed_when (list
          "docker_plugin_status.failed"
          "\"already exists\" not in docker_plugin_status.stderr")))))
