(playbook "kubespray/tests/cloud_playbooks/create-kubevirt.yml"
    (play
    (name "Provision Packet VMs")
    (hosts "localhost")
    (gather_facts "false")
    (become "true")
    (tasks
      (task "Create Kubevirt VMs"
        (import_role 
          (name "packet-ci")))
      (task "Update inventory for Molecule"
        (meta "refresh_inventory"))))
    (play
    (name "Wait until SSH is available")
    (hosts "all")
    (become "false")
    (gather_facts "false")
    (tasks
      (task "Wait until SSH is available"
        (command "ssh -i \"" (jinja "{{ lookup('env', 'ANSIBLE_PRIVATE_KEY_FILE') }}") "\" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=3 \"" (jinja "{{ lookup('env', 'ANSIBLE_REMOTE_USER') }}") "@" (jinja "{{ ansible_host }}") "\"
")
        (register "ssh_command")
        (delay "0")
        (until "ssh_command.rc != 255")
        (retries "60")
        (delegate_to "localhost")))))
