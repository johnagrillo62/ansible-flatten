(playbook "debops/ansible/playbooks/service/hashicorp.yml"
    (play
    (name "Install HashiCorp applications")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_hashicorp"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::hashicorp"))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ hashicorp__keyring__dependent_gpg_keys }}")))
      
        (role "hashicorp")
        (tags (list
            "role::hashicorp"
            "skip::hashicorp")))))
