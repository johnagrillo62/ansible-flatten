(playbook "debops/docs/ansible/roles/gunicorn/examples/gunicorn-applications.yml"
  (gunicorn__applications (list
      
      (name "system-app")
      (working_dir "/path/to/deploy/dir")
      (binary "gunicorn3")
      (user "worker-user")
      (group "worker-group")
      (args (list
          "--bind=0.0.0.0:8000"
          "--workers=" (jinja "{{ ansible_processor_vcpus | int + 1 }}")
          "--timeout=10"
          "system-app.wsgi"))
      
      (name "virtualenv-app")
      (comment "This application is deployed in a virtualenv")
      (working_dir "/path/to/virtualenv/app/src")
      (python "/path/to/virtualenv/bin/python")
      (mode "wsgi")
      (user "custom-user")
      (group "custom-group")
      (args (list
          "--bind=unix:/run/gunicorn/virtualenv-app.sock"
          "--workers=" (jinja "{{ ansible_processor_vcpus | int + 1 }}")
          "--timeout=10"
          "virtualenv-app.wsgi"))
      
      (name "old-app")
      (state "absent"))))
