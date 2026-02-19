(playbook "kubespray/scripts/propagate_ansible_variables.yml"
    (play
    (name "Update README.md versions")
    (hosts "localhost")
    (connection "local")
    (gather_facts "false")
    (vars
      (fallback_ip "bypass tasks in kubespray_defaults"))
    (roles
      "kubespray_defaults")
    (tasks
      (task "Include versions not in kubespray_defaults"
        (include_vars (jinja "{{ item }}"))
        (loop (list
            "../roles/container-engine/docker/defaults/main.yml"
            "../roles/kubernetes/node/defaults/main.yml"
            "../roles/kubernetes-apps/argocd/defaults/main.yml")))
      (task "Render versions in README.md"
        (blockinfile 
          (marker "<!-- {mark} ANSIBLE MANAGED BLOCK -->")
          (block "
" (jinja "{{ lookup('ansible.builtin.template', 'readme_versions.md.j2') }}") "

")
          (path "../README.md")))
      (task "Render Dockerfiles"
        (template 
          (src (jinja "{{ item }}") ".j2")
          (dest "../" (jinja "{{ item }}"))
          (mode "0644"))
        (loop (list
            "pipeline.Dockerfile"
            "Dockerfile"))))))
