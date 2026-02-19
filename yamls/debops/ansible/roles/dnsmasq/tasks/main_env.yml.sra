(playbook "debops/ansible/roles/dnsmasq/tasks/main_env.yml"
  (tasks
    (task "Prepare environment for dependent Ansible roles"
      (ansible.builtin.set_fact 
        (dnsmasq__env_tcpwrappers__dependent_allow (jinja "{{ dnsmasq__tcpwrappers__dependent_allow }}"))))))
