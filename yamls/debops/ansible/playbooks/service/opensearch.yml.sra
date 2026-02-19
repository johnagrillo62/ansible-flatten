(playbook "debops/ansible/playbooks/service/opensearch.yml"
    (play
    (name "Install and manage OpenSearch")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_opensearch"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ opensearch__keyring__dependent_gpg_keys }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ opensearch__etc_services__dependent_list }}")))
      
        (role "sysctl")
        (tags (list
            "role::sysctl"
            "skip::sysctl"))
        (sysctl__dependent_parameters (list
            (jinja "{{ opensearch__sysctl__dependent_parameters }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ opensearch__ferm__dependent_rules }}")))
      
        (role "opensearch")
        (tags (list
            "role::opensearch"
            "skip::opensearch")))))
