(playbook "kubespray/roles/container-engine/molecule/test_cri.yml"
    (play
    (name "Test container manager")
    (hosts "all")
    (gather_facts "false")
    (become "true")
    (tasks
      (task "Get kubespray defaults"
        (import_role 
          (name "../../kubespray_defaults")))
      (task "Collect services facts"
        (ansible.builtin.service_facts null))
      (task "Check container manager service is running"
        (assert 
          (that (list
              "ansible_facts.services[container_manager + '.service'].state == 'running'"
              "ansible_facts.services[container_manager + '.service'].status == 'enabled'"))))
      (task "Check runtime version"
        (command (jinja "{{ bin_dir }}") "/crictl --runtime-endpoint " (jinja "{{ cri_socket }}") " version")
        (register "cri_version")
        (failed_when "cri_version is failed or (\"RuntimeName:  \" + cri_name) not in cri_version.stdout")))))
