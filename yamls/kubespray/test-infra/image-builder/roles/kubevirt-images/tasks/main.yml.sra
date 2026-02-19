(playbook "kubespray/test-infra/image-builder/roles/kubevirt-images/tasks/main.yml"
  (tasks
    (task "Create image directory"
      (file 
        (state "directory")
        (path (jinja "{{ images_dir }}"))
        (mode "0755")))
    (task "Download images files"
      (get_url 
        (url (jinja "{{ item.value.url }}"))
        (dest (jinja "{{ images_dir }}") "/" (jinja "{{ item.value.filename }}"))
        (checksum (jinja "{{ item.value.checksum }}"))
        (mode "0644"))
      (loop (jinja "{{ images | dict2items }}")))
    (task "Unxz compressed images"
      (command "unxz --force " (jinja "{{ images_dir }}") "/" (jinja "{{ item.value.filename }}"))
      (loop (jinja "{{ images | dict2items }}"))
      (when (list
          "item.value.filename.endswith('.xz')")))
    (task "Convert images which is not in qcow2 format"
      (command "qemu-img convert -O qcow2 " (jinja "{{ images_dir }}") "/" (jinja "{{ item.value.filename.rstrip('.xz') }}") " " (jinja "{{ images_dir }}") "/" (jinja "{{ item.key }}") ".qcow2")
      (loop (jinja "{{ images | dict2items }}"))
      (when (list
          "not (item.value.converted | bool)")))
    (task "Make sure all images are ending with qcow2"
      (command "cp " (jinja "{{ images_dir }}") "/" (jinja "{{ item.value.filename.rstrip('.xz') }}") " " (jinja "{{ images_dir }}") "/" (jinja "{{ item.key }}") ".qcow2")
      (loop (jinja "{{ images | dict2items }}"))
      (when (list
          "item.value.converted | bool")))
    (task "Resize images"
      (command "qemu-img resize " (jinja "{{ images_dir }}") "/" (jinja "{{ item.key }}") ".qcow2 +8G")
      (loop (jinja "{{ images | dict2items }}")))
    (task "Template default Dockerfile"
      (template 
        (src "Dockerfile")
        (dest (jinja "{{ images_dir }}") "/Dockerfile")
        (mode "0644")))
    (task "Create docker images for each OS"
      (command "docker build -t " (jinja "{{ registry }}") "/vm-" (jinja "{{ item.key }}") ":" (jinja "{{ item.value.tag }}") " --build-arg cloud_image=\"" (jinja "{{ item.key }}") ".qcow2\" " (jinja "{{ images_dir }}"))
      (loop (jinja "{{ images | dict2items }}")))
    (task "Docker login"
      (command "docker login -u=\"" (jinja "{{ docker_user }}") "\" -p=\"" (jinja "{{ docker_password }}") "\" \"" (jinja "{{ docker_host }}") "\""))
    (task "Docker push image"
      (command "docker push " (jinja "{{ registry }}") "/vm-" (jinja "{{ item.key }}") ":" (jinja "{{ item.value.tag }}"))
      (loop (jinja "{{ images | dict2items }}")))
    (task "Docker logout"
      (command "docker logout -u=\"" (jinja "{{ docker_user }}") "\" \"" (jinja "{{ docker_host }}") "\""))))
