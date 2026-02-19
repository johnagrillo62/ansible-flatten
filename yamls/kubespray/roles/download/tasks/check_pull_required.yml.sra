(playbook "kubespray/roles/download/tasks/check_pull_required.yml"
  (tasks
    (task "Check_pull_required |  Generate a list of information about the images on a node"
      (shell (jinja "{{ image_info_command }}"))
      (register "docker_images")
      (changed_when "false")
      (check_mode "false")
      (when "not download_always_pull"))
    (task "Check_pull_required | Set pull_required if the desired image is not yet loaded"
      (set_fact 
        (pull_required (jinja "{%- if image_reponame | regex_replace('^docker\\.io/(library/)?', '') in docker_images.stdout.split(',') %}") "false" (jinja "{%- else -%}") "true" (jinja "{%- endif -%}")))
      (when "not download_always_pull"))
    (task "Check_pull_required | Check that the local digest sha256 corresponds to the given image tag"
      (assert 
        (that (jinja "{{ download.repo }}") ":" (jinja "{{ download.tag }}") " in docker_images.stdout.split(',')"))
      (when (list
          "not download_always_pull"
          "not pull_required"
          "pull_by_digest"))
      (tags (list
          "asserts")))))
