(playbook "kubespray/roles/container-engine/cri-o/tasks/load_vars.yml"
  (tasks
    (task "Cri-o | include vars/v1.29.yml"
      (include_vars "v1.29.yml")
      (when "crio_version is version(\"1.29.0\", operator=\">=\")"))
    (task "Cri-o | include vars/v1.31.yml"
      (include_vars "v1.31.yml")
      (when "crio_version is version(\"1.31.0\", operator=\">=\")"))))
