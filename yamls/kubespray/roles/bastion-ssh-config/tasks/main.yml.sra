(playbook "kubespray/roles/bastion-ssh-config/tasks/main.yml"
  (tasks
    (task "Set bastion host IP and port"
      (set_fact 
        (bastion_ip (jinja "{{ hostvars[groups['bastion'][0]]['ansible_host'] | d(hostvars[groups['bastion'][0]]['ansible_ssh_host']) }}"))
        (bastion_port (jinja "{{ hostvars[groups['bastion'][0]]['ansible_port'] | d(hostvars[groups['bastion'][0]]['ansible_ssh_port']) | d(22) }}")))
      (connection "local")
      (delegate_to "localhost"))
    (task "Store the current ansible_user in the real_user fact"
      (set_fact 
        (real_user (jinja "{{ ansible_user }}"))))
    (task "Create ssh bastion conf"
      (connection "local")
      (template 
        (src (jinja "{{ ssh_bastion_confing__name }}") ".j2")
        (dest (jinja "{{ playbook_dir }}") "/" (jinja "{{ ssh_bastion_confing__name }}"))
        (mode "0640"))
      (become "false")
      (delegate_to "localhost"))))
