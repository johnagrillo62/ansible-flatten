(playbook "debops/ansible/roles/secret/tasks/main.yml"
  (tasks
    (task "Define variables used by Ansible roles"
      (ansible.builtin.set_fact 
        (secret (jinja "{{ secret }}"))))
    (task "Create secret directories on Ansible Controller"
      (ansible.builtin.file 
        (path (jinja "{{ secret + \"/\" + item }}"))
        (state "directory")
        (mode "0755"))
      (become "False")
      (delegate_to "localhost")
      (loop (jinja "{{ [secret__directories, secret_directories | d([])] | flatten }}"))
      (when "(secret__directories or secret_directories | d()) and item")
      (changed_when "False"))))
