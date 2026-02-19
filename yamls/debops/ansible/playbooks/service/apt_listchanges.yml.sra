(playbook "debops/ansible/playbooks/service/apt_listchanges.yml"
    (play
    (name "Configure apt-listchanges")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_apt_listchanges"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "apt_listchanges")
        (tags (list
            "role::apt_listchanges"
            "skip::apt_listchanges")))))
