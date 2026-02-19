(playbook "debops/ansible/playbooks/service/boxbackup.yml"
    (play
    (name "Manage BoxBackup service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_boxbackup"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "pki")
        (when "boxbackup_server is defined and boxbackup_server == ansible_fqdn")
        (pki_private_groups_present (list
            "bbstored"))
        (pki_realms (list
            
            (source "boxbackup-" (jinja "{{ boxbackup_server }}") "-server")
            (destination "boxbackup-server")
            (authority "root/boxbackup-" (jinja "{{ boxbackup_server }}") "-server")
            (private_group "bbstored")
            (default (jinja "{{ ansible_fqdn }}"))
            (default_ca "CA/boxbackup-" (jinja "{{ boxbackup_server }}") "-client-CA.crt")
            (default_crl "revoked/boxbackup-" (jinja "{{ boxbackup_server }}") "-client-CA.crl")
            (ca (list
                "boxbackup-" (jinja "{{ boxbackup_server }}") "-client"))))
        (pki_authorities (list
            
            (name "root/boxbackup-" (jinja "{{ boxbackup_server }}") "-server")
            (grants "server")
            (filename "boxbackup-" (jinja "{{ boxbackup_server }}") "-server-CA")
            (policy "custom")
            (default_dn "False")
            (cn "Backup system server root")
            (lock "False")
            
            (name "root/boxbackup-" (jinja "{{ boxbackup_server }}") "-client")
            (grants "client")
            (filename "boxbackup-" (jinja "{{ boxbackup_server }}") "-client-CA")
            (policy "custom")
            (default_dn "False")
            (cn "Backup system client root")
            (lock "False")))
        (pki_routes (list
            
            (name "boxbackup-" (jinja "{{ boxbackup_server }}") "-client-ca")
            (authority "root/boxbackup-" (jinja "{{ boxbackup_server }}") "-client")
            (realm "boxbackup-" (jinja "{{ boxbackup_server }}") "-server/CA")
            (readlink "CA.crt")
            
            (name "boxbackup-" (jinja "{{ boxbackup_server }}") "-client-crl")
            (authority "root/boxbackup-" (jinja "{{ boxbackup_server }}") "-client")
            (realm "boxbackup-" (jinja "{{ boxbackup_server }}") "-server/revoked")
            (readlink "default.crl")
            
            (name "boxbackup-" (jinja "{{ ansible_fqdn }}") "-server-cert")
            (authority "root/boxbackup-" (jinja "{{ boxbackup_server }}") "-server/certs")
            (realm "boxbackup-" (jinja "{{ boxbackup_server }}") "-server/certs")
            (file (jinja "{{ ansible_fqdn }}") ".crt")))
        (pki_certificates (list
            
            (source "boxbackup-" (jinja "{{ boxbackup_server }}") "-server")
            (destination "boxbackup-server")
            (default_dn "False")
            (cn (jinja "{{ ansible_fqdn }}"))))
      
        (role "pki")
        (when "boxbackup_server is defined and boxbackup_server != ansible_fqdn")
        (pki_realms (list
            
            (source "boxbackup-" (jinja "{{ ansible_fqdn }}") "-client")
            (destination "boxbackup-client")
            (authority "root/boxbackup-" (jinja "{{ boxbackup_server }}") "-client")
            (private_group "root")
            (default (jinja "{{ ansible_fqdn + \"-\" + boxbackup_account }}"))
            (default_ca "CA/boxbackup-" (jinja "{{ boxbackup_server }}") "-server-CA.crt")
            (default_crl "revoked/boxbackup-" (jinja "{{ boxbackup_server }}") "-server-CA.crl")
            (ca (list
                "boxbackup-" (jinja "{{ boxbackup_server }}") "-server"))))
        (pki_routes (list
            
            (name "boxbackup-" (jinja "{{ ansible_fqdn }}") "-server-ca")
            (authority "root/boxbackup-" (jinja "{{ boxbackup_server }}") "-server")
            (realm "boxbackup-" (jinja "{{ ansible_fqdn }}") "-client/CA")
            (readlink "CA.crt")
            
            (name "boxbackup-" (jinja "{{ ansible_fqdn }}") "-server-crl")
            (authority "root/boxbackup-" (jinja "{{ boxbackup_server }}") "-server")
            (realm "boxbackup-" (jinja "{{ ansible_fqdn }}") "-client/revoked")
            (readlink "default.crl")
            
            (name "boxbackup-" (jinja "{{ ansible_fqdn }}") "-client-cert")
            (authority "root/boxbackup-" (jinja "{{ boxbackup_server }}") "-client/certs")
            (realm "boxbackup-" (jinja "{{ ansible_fqdn }}") "-client/certs")
            (file (jinja "{{ ansible_fqdn + \"-\" + boxbackup_account }}") ".crt")))
        (pki_authorities (list))
        (pki_certificates (list
            
            (source "boxbackup-" (jinja "{{ ansible_fqdn }}") "-client")
            (destination "boxbackup-client")
            (default_dn "False")
            (filename (jinja "{{ ansible_fqdn + \"-\" + boxbackup_account }}"))
            (cn "BACKUP-" (jinja "{{ boxbackup_account }}"))))
      
        (role "etc_services")
        (etc_services_dependency_list (list
            
            (name "boxbackup")
            (protocols (list
                "tcp"))
            (port "2201")
            (comment "BoxBackup server")))
      
        (role "ferm")
        (when "boxbackup_server is defined and boxbackup_server == ansible_fqdn")
        (ferm_input_list (list
            
            (type "dport_accept")
            (dport (list
                "boxbackup"))
            (saddr (jinja "{{ boxbackup_allow }}"))
            (accept_any "True")
            (filename "boxbackup_dependency_accept")
            (weight "20")))
      
        (role "boxbackup")
        (tags (list
            "role::boxbackup"
            "skip::boxbackup")))))
