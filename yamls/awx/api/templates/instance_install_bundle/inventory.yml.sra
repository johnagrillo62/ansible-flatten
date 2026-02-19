(playbook "awx/api/templates/instance_install_bundle/inventory.yml"
  (all 
    (hosts 
      (remote-execution 
        (ansible_host (jinja "{{ instance.hostname }}"))
        (ansible_user "<username>")
        (ansible_ssh_private_key_file "~/.ssh/id_rsa")))))
