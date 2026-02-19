(playbook "tools/docker-compose-minikube/minikube/tasks/main.yml"
  (tasks
    (task "Include pre-flight checks"
      (ansible.builtin.include_tasks "preflight.yml"))
    (task "Create _sources directory"
      (ansible.builtin.file 
        (path (jinja "{{ sources_dest }}"))
        (state "directory")
        (mode "0700")))
    (task "debug minikube_setup"
      (ansible.builtin.debug 
        (var "minikube_setup")))
    (task
      (block (list
          
          (name "Download Minikube")
          (ansible.builtin.get_url 
            (url (jinja "{{ minikube_url_linux }}"))
            (dest (jinja "{{ sources_dest }}") "/minikube")
            (mode "0755"))
          
          (name "Download Kubectl")
          (ansible.builtin.get_url 
            (url (jinja "{{ kubectl_url_linux }}"))
            (dest (jinja "{{ sources_dest }}") "/kubectl")
            (mode "0755"))))
      (when (list
          "ansible_architecture == \"x86_64\""
          "ansible_system == \"Linux\""
          "minikube_setup | default(False) | bool")))
    (task
      (block (list
          
          (name "Download Minikube")
          (ansible.builtin.get_url 
            (url (jinja "{{ minikube_url_macos }}"))
            (dest (jinja "{{ sources_dest }}") "/minikube")
            (mode "0755"))
          
          (name "Download Kubectl")
          (ansible.builtin.get_url 
            (url (jinja "{{ kubectl_url_macos }}"))
            (dest (jinja "{{ sources_dest }}") "/kubectl")
            (mode "0755"))))
      (when (list
          "ansible_architecture == \"x86_64\""
          "ansible_system == \"Darwin\""
          "minikube_setup | default(False) | bool")))
    (task
      (block (list
          
          (name "Starting Minikube")
          (ansible.builtin.shell (jinja "{{ sources_dest }}") "/minikube start --driver=" (jinja "{{ driver }}") " --install-addons=true --addons=" (jinja "{{ addons | join(',') }}"))
          (register "minikube_stdout")
          
          (name "Enable Ingress Controller on Minikube")
          (ansible.builtin.shell (jinja "{{ sources_dest }}") "/minikube addons enable ingress")
          (when (list
              "minikube_stdout.rc == 0"))
          (register "_minikube_ingress")
          (ignore_errors "true")
          
          (name "Show Minikube Ingress known-issue 7332 warning")
          (ansible.builtin.pause 
            (seconds "5")
            (prompt "The Minikube Ingress addon has been disabled since it looks like you are hitting https://github.com/kubernetes/minikube/issues/7332"))
          (when (list
              "\"minikube/issues/7332\" in _minikube_ingress.stderr"
              "ansible_system == \"Darwin\""))))
      (when (list
          "minikube_setup | default(False) | bool")))
    (task "Create ServiceAccount and clusterRoleBinding"
      (k8s 
        (apply "true")
        (definition (jinja "{{ lookup('template', 'rbac.yml.j2') }}"))))
    (task "Retrieve serviceAccount secret name"
      (k8s_info 
        (kind "ServiceAccount")
        (namespace (jinja "{{ minikube_service_account_namespace }}"))
        (name (jinja "{{ minikube_service_account_name }}")))
      (register "service_account"))
    (task "Retrieve bearer_token from serviceAccount secret"
      (k8s_info 
        (kind "Secret")
        (namespace (jinja "{{ minikube_service_account_namespace }}"))
        (name (jinja "{{ minikube_service_account_name }}")))
      (register "_service_account_secret"))
    (task "Load Minikube Bearer Token"
      (ansible.builtin.set_fact 
        (service_account_token (jinja "{{ _service_account_secret[\"resources\"][0][\"data\"][\"token\"] | b64decode }}")))
      (when (list
          "_service_account_secret[\"resources\"][0][\"data\"] | length")))
    (task "Render minikube credential JSON template"
      (ansible.builtin.template 
        (src "bootstrap_minikube.py.j2")
        (dest (jinja "{{ sources_dest }}") "/bootstrap_minikube.py")
        (mode "0600")))))
