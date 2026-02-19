(playbook "ansible-tuto/step-00/setup.yml"
    (play
    (hosts "all")
    (become "true")
    (become_user "root")
    (remote_user "vagrant")
    (gather_facts "false")
    (tasks
      (task "Wait for ssh to be up"
        (wait_for 
          (port "22")
          (delay "5")
          (connect_timeout "5")
          (timeout "360")
          (host (jinja "{{ ansible_host }}")))
        (become "false")
        (delegate_to "localhost"))
      (task "Installs python"
        (raw "apt-get update && apt-get install -y python"))
      (task "Creates destination directory"
        (file 
          (state "directory")
          (mode "0700")
          (dest "/root/.ssh/")))
      (task "Pushes user's rsa key to root's vagrant box (it's ok if this TASK fails)"
        (copy 
          (src "~/.ssh/id_rsa.pub")
          (dest "/root/.ssh/authorized_keys")
          (owner "root")
          (mode "0600"))
        (register "rsa")
        (ignore_errors "true"))
      (task "Pushes user's dsa key to root's vagrant box (it's ok if this TASK fails)"
        (copy 
          (src "~/.ssh/id_dsa.pub")
          (dest "/root/.ssh/authorized_keys")
          (owner "root")
          (mode "0600"))
        (register "dsa")
        (ignore_errors "true")
        (when "rsa is failed"))
      (task "Pushes user's ed25519 key to root's vagrant box (it's NOT ok if all TASKs fail)"
        (copy 
          (src "~/.ssh/id_ed25519.pub")
          (dest "/root/.ssh/authorized_keys")
          (owner "root")
          (mode "0600"))
        (when "dsa is failed"))
      (task "Checks if resolver is working properly (issues with some VBox/Host OS combinations)"
        (command "host -t A ansible.cc")
        (register "ns")
        (ignore_errors "true"))
      (task "Pushes new resolver configuration if resolver fails"
        (lineinfile 
          (regexp "^nameserver ")
          (line "nameserver 8.8.8.8")
          (dest "/etc/resolv.conf"))
        (when "ns is failed"))
      (task "Checks if resolver is working properly with new nameserver"
        (command "host -t A ansible.cc"))
      (task "Final greeting"
        (pause 
          (seconds "1")
          (echo "false")
          (prompt "Don't worry about all the red above; if you made it here, your Vagrant VMs are probably fine !"))))))
