(playbook "kubespray/roles/container-engine/containerd-common/tasks/main.yml"
  (tasks
    (task "Containerd-common | check if fedora coreos"
      (stat 
        (path "/run/ostree-booted")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "ostree"))
    (task "Containerd-common | set is_ostree"
      (set_fact 
        (is_ostree (jinja "{{ ostree.stat.exists }}"))))
    (task "Containerd-common | gather os specific variables"
      (include_vars (jinja "{{ item }}"))
      (with_first_found (list
          
          (files (list
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_release | lower }}") "-" (jinja "{{ host_architecture }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_release | lower }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_major_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ host_architecture }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") ".yml"
              (jinja "{{ ansible_os_family | lower }}") "-" (jinja "{{ host_architecture }}") ".yml"
              (jinja "{{ ansible_os_family | lower }}") ".yml"
              "defaults.yml"))
          (paths (list
              "../vars"))
          (skip "true")))
      (tags (list
          "facts")))))
