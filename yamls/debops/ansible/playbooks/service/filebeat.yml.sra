(playbook "debops/ansible/playbooks/service/filebeat.yml"
    (play
    (name "Manage Filebeat service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_filebeat"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "extrepo")
        (tags (list
            "role::extrepo"
            "skip::extrepo"
            "role::filebeat"))
        (extrepo__dependent_sources (list
            (jinja "{{ filebeat__extrepo__dependent_sources }}")))
      
        (role "filebeat")
        (tags (list
            "role::filebeat"
            "skip::filebeat")))))
