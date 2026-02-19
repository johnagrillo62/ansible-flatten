(playbook "debops/ansible/roles/global_handlers/handlers/libvirtd.yml"
  (tasks
    (task "Restart libvirtd"
      (ansible.builtin.service 
        (name "libvirtd")
        (state "restarted"))
      (when "ansible_distribution_release not in ['trusty', 'xenial']"))
    (task "Restart libvirt-bin"
      (ansible.builtin.service 
        (name "libvirt-bin")
        (state "restarted"))
      (when "ansible_distribution_release in ['trusty', 'xenial']"))))
