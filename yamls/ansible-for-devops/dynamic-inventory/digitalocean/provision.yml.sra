(playbook "ansible-for-devops/dynamic-inventory/digitalocean/provision.yml"
    (play
    (hosts "localhost")
    (connection "local")
    (gather_facts "False")
    (tasks
      (task "Create new Droplet."
        (digital_ocean_droplet 
          (state "absent")
          (name "ansible-test")
          (private_networking "yes")
          (size "1gb")
          (image_id "centos-stream-9-x64")
          (region "nyc3")
          (ssh_keys (list
              "138954"))
          (unique_name "yes"))
        (register "do"))
      (task "Add new host to our inventory."
        (add_host 
          (name (jinja "{{ do.data.ip_address }}"))
          (groups "do")
          (ansible_ssh_extra_args "-o StrictHostKeyChecking=no"))
        (when "do.data is defined")
        (changed_when "False"))))
    (play
    (hosts "do")
    (remote_user "root")
    (gather_facts "False")
    (tasks
      (task "Wait for hosts to become reachable."
        (wait_for_connection null))
      (task "Install tcpdump."
        (dnf "name=tcpdump state=present")))))
