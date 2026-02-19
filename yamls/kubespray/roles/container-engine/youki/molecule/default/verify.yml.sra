(playbook "kubespray/roles/container-engine/youki/molecule/default/verify.yml"
  (tasks
    (task "Test youki"
      (hosts "all")
      (gather_facts "false")
      (tasks (list
          
          (name "Get kubespray defaults")
          (import_role 
            (name "../../../../../kubespray_defaults"))
          
          (name "Test version")
          (command (jinja "{{ bin_dir }}") "/youki --version")
          (register "youki_version")
          (failed_when "youki_version is failed or 'youki' not in youki_version.stdout
"))))
    (task "Test run container"
      (import_playbook "../../../molecule/test_runtime.yml")
      (vars 
        (container_runtime "youki")))))
