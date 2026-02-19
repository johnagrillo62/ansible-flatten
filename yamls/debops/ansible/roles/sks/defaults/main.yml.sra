(playbook "debops/ansible/roles/sks/defaults/main.yml"
  (sks_autoinit "False")
  (sks_contact "")
  (sks_from "PGP Key Server <pgp-public-keys@" (jinja "{{ ansible_fqdn }}") ">")
  (sks_domain (list
      "keyserver." (jinja "{{ ansible_domain }}")))
  (sks_cluster (jinja "{{ groups.debops_service_sks }}"))
  (sks_frontends (list
      (jinja "{{ sks_cluster[0] }}")))
  (sks_hkp_allow (list))
  (sks_public_list (list))
  (sks__etc_services__dependent_list (list
      
      (name (jinja "{{ sks_recon_name }}"))
      (port (jinja "{{ sks_recon_port }}"))
      (comment "SKS Keyserver Reconcilliation Service")
      
      (name (jinja "{{ sks_hkp_frontend_name }}"))
      (port (jinja "{{ sks_hkp_frontend_port }}"))
      (comment "SKS Keyserver Backend Service")))
  (sks__ferm__dependent_rules (list))
  (sks__nginx__dependent_servers (list
      (jinja "{{ sks_nginx_frontend }}")
      (jinja "{{ sks_nginx_ssl_frontend }}")))
  (sks__nginx__dependent_upstreams (list
      (jinja "{{ sks_nginx_upstreams }}"))))
