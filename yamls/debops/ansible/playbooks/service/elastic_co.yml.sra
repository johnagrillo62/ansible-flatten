(playbook "debops/ansible/playbooks/service/elastic_co.yml"
    (play
    (name "Manage Elastic APT repositories")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_elastic_co"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::elastic_co"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ elastic_co__keyring__dependent_apt_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ elastic_co__apt_preferences__dependent_list }}")))
      
        (role "elastic_co")
        (tags (list
            "role::elastic_co"
            "skip::elastic_co")))))
