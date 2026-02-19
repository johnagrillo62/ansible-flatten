(playbook "kubespray/roles/container-engine/gvisor/molecule/default/verify.yml"
  (tasks
    (task "Test gvisor"
      (hosts "all")
      (gather_facts "false")
      (tasks (list
          
          (name "Get kubespray defaults")
          (import_role 
            (name "../../../../../kubespray_defaults"))
          
          (name "Test version")
          (command (jinja "{{ bin_dir }}") "/runsc --version")
          (register "runsc_version")
          (failed_when "runsc_version is failed or 'runsc version' not in runsc_version.stdout
"))))
    (task "Test run container"
      (import_playbook "../../../molecule/test_runtime.yml")
      (vars 
        (container_runtime "runsc")))))
