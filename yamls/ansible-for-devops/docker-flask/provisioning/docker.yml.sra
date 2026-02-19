(playbook "ansible-for-devops/docker-flask/provisioning/docker.yml"
  (tasks
    (task "Build Docker images from Dockerfiles."
      (docker_image 
        (name (jinja "{{ item.name }}"))
        (tag (jinja "{{ item.tag }}"))
        (source "build")
        (build 
          (path (jinja "{{ build_root }}") "/" (jinja "{{ item.directory }}"))
          (pull "false"))
        (state "present"))
      (with_items (list
          
          (name "data")
          (tag "latest")
          (directory "data")
          
          (name "flask")
          (tag "latest")
          (directory "www")
          
          (name "db")
          (tag "latest")
          (directory "db"))))
    (task "Run a Data container."
      (docker_container 
        (image "data:latest")
        (name "data")
        (state "present")))
    (task "Run a Flask container."
      (docker_container 
        (image "flask:latest")
        (name "www")
        (state "started")
        (command "python3 /opt/www/index.py")
        (ports "80:80")))
    (task "Run a MySQL container."
      (docker_container 
        (image "db:latest")
        (name "db")
        (state "started")
        (volumes_from "data")
        (ports "3306:3306")
        (env 
          (MYSQL_ROOT_PASSWORD "root")
          (MYSQL_DATABASE "flask")
          (MYSQL_USER "flask")
          (MYSQL_PASSWORD "flask"))))))
