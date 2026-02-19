(playbook "kubespray/roles/download/tasks/set_container_facts.yml"
  (tasks
    (task "Set_container_facts | Display the name of the image being processed"
      (debug 
        (msg (jinja "{{ download.repo }}"))))
    (task "Set_container_facts | Set if containers should be pulled by digest"
      (set_fact 
        (pull_by_digest (jinja "{{ download.sha256 is defined and download.sha256 }}"))))
    (task "Set_container_facts | Define by what name to pull the image"
      (set_fact 
        (image_reponame (jinja "{%- if pull_by_digest %}") (jinja "{{ download.repo }}") "@sha256:" (jinja "{{ download.sha256 }}") (jinja "{%- else -%}") (jinja "{{ download.repo }}") ":" (jinja "{{ download.tag }}") (jinja "{%- endif -%}"))))
    (task "Set_container_facts | Define file name of image"
      (set_fact 
        (image_filename (jinja "{{ image_reponame | regex_replace('/|\\0|:', '_') }}") ".tar")))
    (task "Set_container_facts | Define path of image"
      (set_fact 
        (image_path_cached (jinja "{{ download_cache_dir }}") "/images/" (jinja "{{ image_filename }}"))
        (image_path_final (jinja "{{ local_release_dir }}") "/images/" (jinja "{{ image_filename }}"))))
    (task "Set image save/load command for docker"
      (set_fact 
        (image_save_command (jinja "{{ docker_bin_dir }}") "/docker save " (jinja "{{ image_reponame }}") " | gzip -" (jinja "{{ download_compress }}") " > " (jinja "{{ image_path_final }}"))
        (image_load_command (jinja "{{ docker_bin_dir }}") "/docker load < " (jinja "{{ image_path_final }}")))
      (when "container_manager == 'docker'"))
    (task "Set image save/load command for containerd"
      (set_fact 
        (image_save_command (jinja "{{ bin_dir }}") "/nerdctl -n k8s.io image save -o " (jinja "{{ image_path_final }}") " " (jinja "{{ image_reponame }}"))
        (image_load_command (jinja "{{ bin_dir }}") "/nerdctl -n k8s.io image load < " (jinja "{{ image_path_final }}")))
      (when "container_manager == 'containerd'"))
    (task "Set image save/load command for crio"
      (set_fact 
        (image_save_command (jinja "{{ bin_dir }}") "/skopeo copy containers-storage:" (jinja "{{ image_reponame }}") " docker-archive:" (jinja "{{ image_path_final }}") " 2>/dev/null")
        (image_load_command (jinja "{{ bin_dir }}") "/skopeo copy docker-archive:" (jinja "{{ image_path_final }}") " containers-storage:" (jinja "{{ image_reponame }}") " 2>/dev/null"))
      (when "container_manager == 'crio'"))
    (task "Set image save/load command for docker on localhost"
      (set_fact 
        (image_save_command_on_localhost (jinja "{{ docker_bin_dir }}") "/docker save " (jinja "{{ image_reponame }}") " | gzip -" (jinja "{{ download_compress }}") " > " (jinja "{{ image_path_cached }}")))
      (when "container_manager_on_localhost == 'docker'"))
    (task "Set image save/load command for containerd on localhost"
      (set_fact 
        (image_save_command_on_localhost (jinja "{{ containerd_bin_dir }}") "/ctr -n k8s.io image export --platform linux/" (jinja "{{ image_arch }}") " " (jinja "{{ image_path_cached }}") " " (jinja "{{ image_reponame }}")))
      (when "container_manager_on_localhost == 'containerd'"))
    (task "Set image save/load command for crio on localhost"
      (set_fact 
        (image_save_command_on_localhost (jinja "{{ bin_dir }}") "/skopeo copy containers-storage:" (jinja "{{ image_reponame }}") " docker-archive:" (jinja "{{ image_path_final }}") " 2>/dev/null"))
      (when "container_manager_on_localhost == 'crio'"))))
