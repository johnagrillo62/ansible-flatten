(playbook "debops/ansible/playbooks/service/metricbeat.yml"
    (play
    (name "Manage Metricbeat service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_metricbeat"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "extrepo")
        (tags (list
            "role::extrepo"
            "skip::extrepo"
            "role::metricbeat"))
        (extrepo__dependent_sources (list
            (jinja "{{ metricbeat__extrepo__dependent_sources }}")))
      
        (role "metricbeat")
        (tags (list
            "role::metricbeat"
            "skip::metricbeat")))))
