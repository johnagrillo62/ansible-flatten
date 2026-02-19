(playbook "debops/docs/ansible/roles/rails_deploy/examples/ansible/inventory/host_vars/somedbhost.yml"
  (postgresql_version "9.3")
  (postgresql_pgdg "True")
  (postgresql_default_cluster (list
      
      (name "main")
      (port "5432")
      (listen_addresses "0.0.0.0")
      (hba (list
          
          (hosts (jinja "{{ rails_deploy_hosts_master }}"))))
      (allow "rails_deploy_hosts_master"))))
