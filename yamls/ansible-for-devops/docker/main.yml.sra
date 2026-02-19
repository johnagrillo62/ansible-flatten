(playbook "ansible-for-devops/docker/main.yml"
    (play
    (hosts "localhost")
    (connection "local")
    (tasks
      (task "Ensure Docker image is built from the test Dockerfile."
        (docker_image 
          (name "test")
          (source "build")
          (build 
            (path "test"))
          (state "present")))
      (task "Ensure the test container is running."
        (docker_container 
          (image "test:latest")
          (name "test")
          (state "started"))))))
