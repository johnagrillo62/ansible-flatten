(playbook "debops/docs/ansible/roles/nsswitch/examples/dependent-nsswitch.yml"
    (play
    (name "Configure application with NSS service")
    (collections (list
        "debops.debops"))
    (hosts (list
        "debops_service_application"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "application")
        (tags (list
            "role::application"))
      
        (role "nsswitch")
        (tags (list
            "role::nsswitch"))
        (nsswitch__dependent_services (list
            (jinja "{{ application__nsswitch__dependent_services }}"))))))
