(playbook "kubespray/roles/bastion-ssh-config/molecule/default/converge.yml"
    (play
    (name "Converge")
    (hosts "all")
    (become "true")
    (gather_facts "false")
    (roles
      
        (role "bastion-ssh-config"))
    (tasks
      (task "Copy config to remote host"
        (copy 
          (src (jinja "{{ playbook_dir }}") "/" (jinja "{{ ssh_bastion_confing__name }}"))
          (dest (jinja "{{ ssh_bastion_confing__name }}"))
          (owner (jinja "{{ ansible_user }}"))
          (group (jinja "{{ ansible_user }}"))
          (mode "0644"))))))
